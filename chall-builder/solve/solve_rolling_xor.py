#!/usr/bin/env python3
"""
Solution script for CTF Memory Forensics Challenge
Implements rolling-key XOR decryption
"""

def rolling_xor_decrypt(ciphertext, key, seed):
    """
    Decrypt using rolling-key XOR algorithm
    
    Args:
        ciphertext: bytes - encrypted data
        key: bytes - encryption key
        seed: int - initial seed value (0-255)
    
    Returns:
        bytes - decrypted plaintext
    """
    plaintext = bytearray()
    state = seed
    keylen = len(key)
    
    for i, byte in enumerate(ciphertext):
        # Decrypt: cipher XOR key XOR state
        decrypted = byte ^ key[i % keylen] ^ state
        plaintext.append(decrypted)
        
        # Update state (rolling)
        state = (state + 13) & 0xff
    
    return bytes(plaintext)


if __name__ == "__main__":
    print("=" * 70)
    print("CTF Memory Forensics Challenge - Solution")
    print("=" * 70)
    print()
    
    # Key recovered from memory or reverse engineering
    # (Combined from fragments: "uit_" + "insec_" + "lab")
    key = b"uit_insec_lab"
    
    # Seed calculated from reverse engineering
    # Found: a = 0x21, b = 0x63, seed = a ^ b
    seed = 0x42
    
    # Ciphertext extracted from binary
    ciphertext = bytes.fromhex(
        "5e485b537c81829ab285cdddd3ece82e21132321506f5e737eba85a9b483c4c9feffec2b"
    )
    
    print("[*] Configuration:")
    print(f"    Key: {key.decode()}")
    print(f"    Key length: {len(key)}")
    print(f"    Seed: 0x{seed:02x}")
    print(f"    Ciphertext length: {len(ciphertext)} bytes")
    print()
    
    print("[*] Ciphertext (hex):")
    print(f"    {ciphertext.hex()}")
    print()
    
    # Decrypt
    flag = rolling_xor_decrypt(ciphertext, key, seed)
    
    print("=" * 70)
    print("[*] DECRYPTED FLAG:")
    print("=" * 70)
    print()
    print(f"    {flag.decode()}")
    print()
    print("=" * 70)
    
    # Verify format
    if flag.startswith(b"inseclab{") and flag.endswith(b"}"):
        print("✓ Flag format valid!")
    else:
        print("✗ Warning: Unexpected flag format")
    print()
