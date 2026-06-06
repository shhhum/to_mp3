class ToMp3 < Formula
  desc "Recursively convert audio files to high-quality 320kbps MP3"
  homepage "https://github.com/shhhum/to_mp3"
  url "https://github.com/shhhum/to_mp3/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "REPLACE_AFTER_RELEASE"
  version "0.1.2"

  depends_on "ffmpeg"

  def install
    bin.install "to-mp3"
  end

  test do
    assert_match "to-mp3 #{version}", shell_output("#{bin}/to-mp3 --version")
  end
end
