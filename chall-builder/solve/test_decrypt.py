#!/usr/bin/env python3
"""
Test script for rolling-key XOR encryption/decryption
Verifies the algorithm logic is correct
"""

def rolling_xor_encrypt(plaintext, key, seed):
    """Encrypt using rolling-key XOR"""
    cipher = bytearray()
    state = seed
    keylen = len(key)
    
    for i, byte in enumerate(plaintext):
        encrypted = byte ^ key[i % keylen] ^ state
        cipher.append(encrypted)
        state = (state + 13) & 0xff
    
    return bytes(cipher)


def rolling_xor_decrypt(ciphertext, key, seed):
    """Decrypt using rolling-key XOR (same as encrypt)"""
    return rolling_xor_encrypt(ciphertext, key, seed)


if __name__ == "__main__":
    print("=" * 70)
    print("Rolling-Key XOR Algorithm Test")
    print("=" * 70)
    print()
    
    # Test configuration
    key = b"uit_insec_lab"
    msg = b"inseclab{memory_leaks_are_dangerous}"
    seed = 0x42
    
    print("[*] Test Configuration:")
    print(f"    Plaintext: {msg.decode()}")
    print(f"    Key: {key.decode()}")
    print(f"    Seed: 0x{seed:02x}")
    print()
    
    # Encrypt
    cipher = rolling_xor_encrypt(msg, key, seed)
    print("[*] Encryption:")
    print(f"    Ciphertext (hex): {cipher.hex()}")
    print(f"    Ciphertext (len): {len(cipher)} bytes")
    print()
    
    # Decrypt
    plain = rolling_xor_decrypt(cipher, key, seed)
    print("[*] Decryption:")
    print(f"    Plaintext: {plain.decode()}")
    print()
    
    # Verify
    print("=" * 70)
    if plain == msg:
        print("✓ Encryption/Decryption logic is CORRECT")
        print("✓ Algorithm verified!")
    else:
        print("✗ ERROR: Decryption failed!")
        print(f"Expected: {msg}")
        print(f"Got: {plain}")
    print("=" * 70)
    print()
    
    # Show first few bytes for debugging
    print("[*] Byte-by-byte verification (first 10 bytes):")
    print()
    for i in range(min(10, len(msg))):
        state_at_i = (seed + i * 13) & 0xff
        print(f"  [{i:2d}] plain=0x{msg[i]:02x} '{chr(msg[i])}' "
              f"key=0x{key[i % len(key)]:02x} "
              f"state=0x{state_at_i:02x} "
              f"→ cipher=0x{cipher[i]:02x}")
    print()
