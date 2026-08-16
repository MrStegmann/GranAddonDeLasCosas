# LibDeflate

A pure Lua compressor and decompressor with high compression ratio. It supports Deflate, Zlib, and gzip formats. It also provides string encoding/decoding suitable for WoW addon communication channels or copy/paste strings (Base64).

## Usage

```lua
local LibDeflate = LibStub("LibDeflate")

-- Data to compress
local str = "Hello World! Hello World! Hello World!"

-- Compress
local compressed = LibDeflate:CompressDeflate(str)

-- If we want to send it over SendAddonMessage or put it in an EditBox:
-- WoW addon comms cannot contain NULL bytes, so we encode it.
-- Use EncodeForWoWAddonChannel for SendAddonMessage
local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)

-- To decode and decompress:
local decoded = LibDeflate:DecodeForWoWAddonChannel(encoded)
local decompressed = LibDeflate:DecompressDeflate(decoded)
```
