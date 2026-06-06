#!/usr/bin/env bash
#
# release.sh — cut a new to-mp3 release.
#
# Bumps VERSION in `to-mp3` and `Formula/to-mp3.rb`, commits, tags, pushes,
# fetches the GitHub tarball, fills in the sha256, then syncs the formula
# to ../homebrew-tap and pushes that too.
#
# Usage:
#   ./release.sh              # bump patch (0.1.2 -> 0.1.3)
#   ./release.sh 0.2.0        # explicit version
#
# Env:
#   TAP_ROOT=/path/to/homebrew-tap   # override tap location (default: ../homebrew-tap)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_PATH="$REPO_ROOT/to-mp3"
FORMULA_PATH="$REPO_ROOT/Formula/to-mp3.rb"

if [[ -z "${TAP_ROOT:-}" ]]; then
  TAP_ROOT=$(cd "$REPO_ROOT/../homebrew-tap" 2>/dev/null && pwd || true)
fi

die() { echo "release: $*" >&2; exit 1; }
log() { echo "release: $*"; }

# --- preflight ---------------------------------------------------------------

[[ -f "$SCRIPT_PATH" ]]  || die "to-mp3 not found at $SCRIPT_PATH"
[[ -f "$FORMULA_PATH" ]] || die "formula not found at $FORMULA_PATH"
[[ -n "$TAP_ROOT" && -d "$TAP_ROOT/Formula" ]] \
  || die "tap repo not found at ../homebrew-tap (override with TAP_ROOT=...)"
command -v git    >/dev/null || die "git not in PATH"
command -v curl   >/dev/null || die "curl not in PATH"
command -v shasum >/dev/null || die "shasum not in PATH"

cd "$REPO_ROOT"
[[ -z "$(git status --porcelain)" ]] \
  || die "source repo has uncommitted changes; clean first"
( cd "$TAP_ROOT" && [[ -z "$(git status --porcelain)" ]] ) \
  || die "tap repo has uncommitted changes; clean first"

# --- determine version -------------------------------------------------------

current=$(sed -n 's/^VERSION="\(.*\)"/\1/p' "$SCRIPT_PATH")
[[ -n "$current" ]] || die "couldn't parse VERSION from $SCRIPT_PATH"

if [[ $# -ge 1 ]]; then
  new_version="$1"
else
  IFS=. read -r maj min pat <<<"$current"
  new_version="${maj}.${min}.$((pat + 1))"
fi

[[ "$new_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] \
  || die "version must look like MAJOR.MINOR.PATCH (got '$new_version')"
[[ "$new_version" != "$current" ]] \
  || die "version $new_version is already current"
git rev-parse "v$new_version" >/dev/null 2>&1 \
  && die "tag v$new_version already exists locally"

log "bumping $current -> $new_version"

# --- patch files -------------------------------------------------------------

patch_file() {
  local file="$1" expr="$2" tmp
  tmp=$(mktemp)
  sed -E "$expr" "$file" > "$tmp" && mv "$tmp" "$file"
}

# Escape dots in $current so sed treats them as literal.
current_esc=${current//./\\.}

patch_file "$SCRIPT_PATH"  "s/^VERSION=\"$current_esc\"/VERSION=\"$new_version\"/"
chmod +x "$SCRIPT_PATH"

patch_file "$FORMULA_PATH" "s|/archive/refs/tags/v$current_esc\\.tar\\.gz|/archive/refs/tags/v$new_version.tar.gz|"
patch_file "$FORMULA_PATH" "s/version \"$current_esc\"/version \"$new_version\"/"
patch_file "$FORMULA_PATH" 's/^  sha256 "[^"]*"/  sha256 "REPLACE_AFTER_RELEASE"/'

# --- commit, tag, push -------------------------------------------------------

branch=$(git rev-parse --abbrev-ref HEAD)
git add "$SCRIPT_PATH" "$FORMULA_PATH"
git commit -m "v$new_version"
git tag "v$new_version"
log "pushing $branch + v$new_version to origin"
git push origin "$branch" "v$new_version"

# --- fetch tarball, compute sha256 ------------------------------------------

tarball_url=$(sed -nE 's/^  url "([^"]+)".*/\1/p' "$FORMULA_PATH")
log "fetching $tarball_url"

sha=""
for i in 1 2 3 4 5 6; do
  sha=$(curl -sSL --fail "$tarball_url" 2>/dev/null | shasum -a 256 | awk '{print $1}') || sha=""
  [[ ${#sha} -eq 64 ]] && break
  log "tarball not ready (attempt $i), waiting 2s..."
  sleep 2
done
[[ ${#sha} -eq 64 ]] || die "couldn't fetch tarball sha256 after retries"
log "sha256 = $sha"

# --- patch sha256 in source, commit, push -----------------------------------

patch_file "$FORMULA_PATH" "s/REPLACE_AFTER_RELEASE/$sha/"
git add "$FORMULA_PATH"
git commit -m "Formula sha256 for v$new_version"
git push origin "$branch"

# --- sync to tap, commit, push ----------------------------------------------

cp "$FORMULA_PATH" "$TAP_ROOT/Formula/to-mp3.rb"
cd "$TAP_ROOT"
git add Formula/to-mp3.rb
git commit -m "to-mp3 $new_version"
log "pushing tap"
git push

echo
echo "released v$new_version. run: brew upgrade to-mp3"
