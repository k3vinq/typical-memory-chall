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
    ciphertext = bytes.fromhex("020917380808061f0a062634091c050e05001217062d0115310c000b0b100522")
    
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
