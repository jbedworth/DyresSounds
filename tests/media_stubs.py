"""Small stand-in media for release fixtures.

The builder only checks each sound's header and size, so fixtures use these
few-byte files instead of copying every real sound (24 MB) into each test.
The real sounds are still checked: test_release reads them from the
repository, and CI builds the real package.
"""

import struct

# A PCM WAV header: 16-bit mono at 22050 Hz, with an empty data chunk.
WAV = (b"RIFF" + struct.pack("<I", 36) + b"WAVEfmt "
       + struct.pack("<IHHIIHH", 16, 1, 1, 22050, 44100, 2, 16)
       + b"data" + struct.pack("<I", 0))
# An MP3 that starts with an ID3 tag.
MP3 = b"ID3" + bytes(16)
# An uncompressed 32-bit 16 x 16 TGA.
TGA = (bytes((0, 0, 2)) + bytes(9) + struct.pack("<HH", 16, 16)
       + bytes((32, 0x28)) + bytes(16 * 16 * 4))


def stub(name):
    """Return valid stand-in bytes for the media file `name`."""
    if name.endswith(".wav"):
        return WAV
    if name.endswith(".mp3"):
        return MP3
    return TGA


def write_stubs(source, names):
    """Write a stand-in for each media file in `names` under `source`."""
    for name in names:
        path = source / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(stub(name))
