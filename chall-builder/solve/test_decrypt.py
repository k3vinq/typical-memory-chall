#!/usr/bin/env python3
"""
Test script để verify logic XOR encryption/decryption
Sử dụng để kiểm tra thuật toán trước khi tạo memory dump
"""

key = b"dev_secret_key"
msg = b"inseclab{memory_leaks_are_dangerous}"

print("=" * 60)
print("Testing XOR Encryption/Decryption Logic")
print("=" * 60)
print()

# Encrypt
cipher = bytearray()
for i, b in enumerate(msg):
    cipher.append(b ^ key[i % len(key)])

print(f"Original message: {msg.decode()}")
print(f"Key: {key.decode()}")
print(f"Encrypted (hex): {cipher.hex()}")
print()

# Decrypt
plain = bytearray()
for i, b in enumerate(cipher):
    plain.append(b ^ key[i % len(key)])

print(f"Decrypted message: {plain.decode()}")
print()

# Verify
if plain == msg:
    print("✓ Encryption/Decryption logic is CORRECT")
else:
    print("✗ ERROR: Decryption failed!")
    
print()
print("=" * 60)
