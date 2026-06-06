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

1. Bump `VERSION` in [`to-mp3`](to-mp3) and `version` / `url` in
   [`Formula/to-mp3.rb`](Formula/to-mp3.rb).
2. Tag and push:
   ```bash
   git tag v0.1.1 && git push origin v0.1.1
   ```
3. Compute the new tarball sha256 and update `Formula/to-mp3.rb` in the tap repo:
   ```bash
   curl -sL https://github.com/shhhum/to_mp3/archive/refs/tags/v0.1.1.tar.gz | shasum -a 256
   ```
