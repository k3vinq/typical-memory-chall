#!/usr/bin/env python3
"""
Cipher Generator for CTF Memory Forensics Challenge
Generates ciphertext from plaintext using rolling-key XOR
"""

def rolling_xor_encrypt(plaintext, key, seed):
    """
    Encrypt using rolling-key XOR algorithm
    
    Args:
        plaintext: bytes - data to encrypt
        key: bytes - encryption key
        seed: int - initial seed value (0-255)
    
    Returns:
        bytes - encrypted ciphertext
    """
    cipher = bytearray()
    state = seed
    keylen = len(key)
    
    for i, byte in enumerate(plaintext):
        # XOR with key and state
        encrypted = byte ^ key[i % keylen] ^ state
        cipher.append(encrypted)
        
        # Update state (rolling)
        state = (state + 13) & 0xff
    
    return bytes(cipher)


def rolling_xor_decrypt(ciphertext, key, seed):
    """
    Decrypt using rolling-key XOR algorithm
    (Same as encrypt for XOR)
    """
    return rolling_xor_encrypt(ciphertext, key, seed)


def generate_c_array(data, name="cipher"):
    """
    Generate C array declaration from bytes
    
    Args:
        data: bytes - data to convert
        name: str - array name
    
    Returns:
        str - C array declaration
    """
    hex_values = [f"0x{b:02x}" for b in data]
    
    # Format in rows of 12 values
    rows = []
    for i in range(0, len(hex_values), 12):
        row = ", ".join(hex_values[i:i+12])
        rows.append(f"    {row}")
    
    array_content = ",\n".join(rows)
    
    return f"unsigned char {name}[] = {{\n{array_content}\n}};"


if __name__ == "__main__":
    # Configuration
    FLAG = b"inseclab{memory_leaks_are_dangerous}"
    
    # Key fragments (will be combined at runtime in C)
    K1 = b"uit_"
    K2 = b"insec_"
    K3 = b"lab"
    FULL_KEY = K1 + K2 + K3  # "uit_insec_lab"
    
    # Seed calculation (matches C runtime calculation)
    A = 0x21
    B = 0x63
    SEED = A ^ B  # = 0x42
    
    print("=" * 70)
    print("CTF Memory Forensics Challenge - Cipher Generator")
    print("=" * 70)
    print()
    
    # Display configuration
    print("[*] Configuration:")
    print(f"    Plaintext: {FLAG.decode()}")
    print(f"    Key: {FULL_KEY.decode()}")
    print(f"    Key length: {len(FULL_KEY)}")
    print(f"    Seed: 0x{SEED:02x} (calculated as 0x{A:02x} ^ 0x{B:02x})")
    print()
    
    # Encrypt
    ciphertext = rolling_xor_encrypt(FLAG, FULL_KEY, SEED)
    
    print("[*] Encryption:")
    print(f"    Ciphertext (hex): {ciphertext.hex()}")
    print(f"    Ciphertext length: {len(ciphertext)} bytes")
    print()
    
    # Verify by decrypting
    decrypted = rolling_xor_decrypt(ciphertext, FULL_KEY, SEED)
    
    print("[*] Verification:")
    print(f"    Decrypted: {decrypted.decode()}")
    print(f"    Match: {'✓ SUCCESS' if decrypted == FLAG else '✗ FAILED'}")
    print()
    
    # Generate C array
    print("=" * 70)
    print("[*] C Array Declaration (copy to chatclient.c):")
    print("=" * 70)
    print()
    print(generate_c_array(ciphertext, "cipher"))
    print()
    print(f"#define CIPHER_LEN {len(ciphertext)}")
    print()
    
    # Generate test values
    print("=" * 70)
    print("[*] Test Values:")
    print("=" * 70)
    print()
    print("First 10 bytes:")
    for i in range(min(10, len(ciphertext))):
        state_at_i = (SEED + i * 13) & 0xff
        print(f"  [{i}] plain=0x{FLAG[i]:02x} '{chr(FLAG[i])}' "
              f"key=0x{FULL_KEY[i % len(FULL_KEY)]:02x} "
              f"state=0x{state_at_i:02x} "
              f"→ cipher=0x{ciphertext[i]:02x}")
    print()
    
    print("=" * 70)
    print("[*] Summary:")
    print("=" * 70)
    print()
    print(f"✓ Algorithm: Rolling-key XOR with state += 13")
    print(f"✓ Key: {FULL_KEY.decode()}")
    print(f"✓ Seed: 0x{SEED:02x}")
    print(f"✓ Flag: {FLAG.decode()}")
    print(f"✓ Ciphertext: {len(ciphertext)} bytes")
    print()
    print("Ready to copy to chatclient.c!")
    print()
