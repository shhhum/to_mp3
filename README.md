# to-mp3

Recursively convert non-mp3 audio files to high-quality (320kbps) mp3.

Walks the current directory, finds audio files in common formats (wav, flac, aiff,
m4a, aac, ogg, opus, wma, ape, wv, mka, ...), and writes a 320kbps mp3 next to
each source. Skips files that already have an `.mp3` sibling.

## Install

```bash
brew install shhhum/tap/to-mp3
```

`ffmpeg` is pulled in as a dependency.

## Usage

```bash
to-mp3              # convert every detected file under the current dir
to-mp3 -n           # preview what would be converted (dry run)
to-mp3 -v           # convert with per-file logging
to-mp3 -f           # overwrite existing .mp3 outputs
to-mp3 --help       # full options and examples
```

- Output naming: `song.wav` → `song.mp3`, placed next to the source.
- Case-insensitive: `.FLAC`, `.WAV`, etc. are detected.
- Paths with spaces are handled correctly.
- Existing `.mp3` files are left alone unless you pass `-f`.

## Detected formats

`wav flac aiff aif aifc m4a aac ogg oga opus wma ape wv mka`

## Releasing

```bash
./release.sh              # bump patch (0.1.2 -> 0.1.3)
./release.sh 0.2.0        # explicit version
```

The script bumps `VERSION` in [`to-mp3`](to-mp3) and version/url/sha256 in
[`Formula/to-mp3.rb`](Formula/to-mp3.rb), commits, tags, pushes, fetches the
GitHub tarball to compute sha256, then syncs the formula into
`../homebrew-tap` and pushes that. Override the tap location with
`TAP_ROOT=/path/to/tap ./release.sh`.
