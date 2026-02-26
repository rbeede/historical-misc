# Converts vernemq sha512 hash to sha512crypt compatible format
# Useful with hashcat -m 1800

# https://github.com/vernemq/vernemq/blob/main/apps/vmq_passwd/c_src/vmq_passwd.c#L159
#    Documented that it used a different base64 alphabet than the sha512crypt alphabet

# Rodney Beede
# 2026-02-26

# Vibe coding with Claude AI but with modifications to accept CLI options for salt and hash
#   "Write code to take a base64 encoded string, decode it, and then re-encode it using the Base64 alphabet used by sha512crypt"

# Pass the salt b645 value by itself and then call again with the hash b64 value

import base64
import sys

# sha512crypt uses a custom Base64 alphabet (defined in glibc/crypt):
# './0-9A-Za-z'  (64 chars, index 0–63)
# Compare to standard Base64: 'A-Za-z0-9+/'
SHA512CRYPT_CHARS = "./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

def encode_sha512crypt(data: bytes) -> str:
    """Encode raw bytes using sha512crypt's custom Base64 alphabet (no padding)."""
    result = []
    # Process 3 bytes at a time → 4 characters (like standard Base64)
    # but sha512crypt emits only as many chars as needed and uses no '=' padding.
    for i in range(0, len(data), 3):
        chunk = data[i:i+3]
        b0 = chunk[0]
        b1 = chunk[1] if len(chunk) > 1 else 0
        b2 = chunk[2] if len(chunk) > 2 else 0

        result.append(SHA512CRYPT_CHARS[b0 & 0x3f])
        result.append(SHA512CRYPT_CHARS[((b0 >> 6) | (b1 << 2)) & 0x3f])
        if len(chunk) > 1:
            result.append(SHA512CRYPT_CHARS[((b1 >> 4) | (b2 << 4)) & 0x3f])
        if len(chunk) > 2:
            result.append(SHA512CRYPT_CHARS[(b2 >> 2) & 0x3f])

    return "".join(result)


def decode_sha512crypt(s: str) -> bytes:
    """Decode a sha512crypt Base64 encoded string back to raw bytes."""
    char_to_idx = {c: i for i, c in enumerate(SHA512CRYPT_CHARS)}
    result = []
    i = 0
    while i < len(s):
        c0 = char_to_idx[s[i]]; i += 1
        c1 = char_to_idx[s[i]] if i < len(s) else 0; i += 1
        b0 = c0 | ((c1 & 0x3) << 6)
        result.append(b0)
        if i < len(s):
            c2 = char_to_idx[s[i]]; i += 1
            b1 = (c1 >> 2) | ((c2 & 0xf) << 4)
            result.append(b1)
        if i < len(s):
            c3 = char_to_idx[s[i]]; i += 1
            b2 = (c2 >> 4) | (c3 << 2)
            result.append(b2)
    return bytes(result)


def std_b64_to_sha512crypt(std_b64: str) -> str:
    """Convert a standard Base64 string to sha512crypt Base64."""
    raw = base64.b64decode(std_b64)
    return encode_sha512crypt(raw)


if __name__ == "__main__":
    std = sys.argv[1]

    converted = std_b64_to_sha512crypt(std)
    print(f"Standard Base64:       {std}")
    print(f"sha512crypt Base64:    {converted}")

    # Round-trip check
    raw_original = base64.b64decode(std)
    raw_roundtrip = decode_sha512crypt(converted)
    print(f"Round-trip match:      {raw_original == raw_roundtrip}")