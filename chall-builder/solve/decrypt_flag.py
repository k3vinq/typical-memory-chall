#!/usr/bin/env python3
"""
Script giải mã flag từ memory dump
Sử dụng sau khi đã tìm được key và ciphertext từ memory
"""

def xor_decrypt(ciphertext, key):
    """
    Decrypt ciphertext using XOR with repeating key
    
    Args:
        ciphertext: bytes - encrypted data
        key: bytes - encryption key
    
    Returns:
        bytes - decrypted plaintext
    """
    plaintext = bytearray()
    key_len = len(key)
    
    for i, byte in enumerate(ciphertext):
        plaintext.append(byte ^ key[i % key_len])
    
    return bytes(plaintext)


if __name__ == "__main__":
    # Key recovered from memory (dev_secret_key)
    key = b"dev_secret_key"
    
    # Encrypted message recovered from memory
    # Thay đổi giá trị này sau khi extract từ memory dump
    ciphertext = bytes.fromhex("0d0b053a100902101e193a060a0b1d3a1a3a120e102d04063a3401180a02132d1c10100f")
    
    # Decrypt
    flag = xor_decrypt(ciphertext, key)
    
    print("=" * 60)
    print("Memory Forensics Challenge - Flag Decryption")
    print("=" * 60)
    print()
    print(f"Key: {key.decode()}")
    print(f"Ciphertext (hex): {ciphertext.hex()}")
    print()
    print(f"FLAG: {flag.decode()}")
    print()
    print("=" * 60)
