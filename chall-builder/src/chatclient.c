#include <stdio.h>
#include <string.h>

// Key fragments (combined at runtime)
unsigned char k1[] = "uit_";
unsigned char k2[] = "insec_";
unsigned char k3[] = "lab";

// Ciphertext (encrypted flag)
unsigned char cipher[] = {
    0x5e, 0x48, 0x5b, 0x53, 0x7c, 0x81, 0x82, 0x9a, 0xb2, 0x85, 0xcd, 0xdd,
    0xd3, 0xec, 0xe8, 0x2e, 0x21, 0x13, 0x23, 0x21, 0x50, 0x6f, 0x5e, 0x73,
    0x7e, 0xba, 0x85, 0xa9, 0xb4, 0x83, 0xc4, 0xc9, 0xfe, 0xff, 0xec, 0x2b
};

#define CIPHER_LEN 36

// Rolling-key XOR decrypt function
void decrypt_message(unsigned char *cipher, int len, unsigned char *key, int keylen, unsigned char seed) {
    unsigned char state = seed;
    unsigned char buffer[256];
    
    for (int i = 0; i < len; i++) {
        // Decrypt: cipher XOR key XOR state
        buffer[i] = cipher[i] ^ key[i % keylen] ^ state;
        
        // Update state (rolling)
        state = (state + 13) & 0xff;
    }
    
    buffer[len] = '\0';
    
    // Verify decryption (without revealing plaintext)
    if (buffer[0] != 0) {
        printf("Message processed successfully!\n");
    }
}

int main() {
    // Combine key fragments at runtime
    unsigned char runtime_key[32];
    int pos = 0;
    
    // Concatenate k1 + k2 + k3
    for (int i = 0; i < strlen((char*)k1); i++) {
        runtime_key[pos++] = k1[i];
    }
    for (int i = 0; i < strlen((char*)k2); i++) {
        runtime_key[pos++] = k2[i];
    }
    for (int i = 0; i < strlen((char*)k3); i++) {
        runtime_key[pos++] = k3[i];
    }
    
    int keylen = pos;
    
    // Calculate seed at runtime (obfuscated)
    unsigned char a = 0x21;
    unsigned char b = 0x63;
    unsigned char seed = a ^ b;  // = 0x42
    
    // Decrypt and display
    decrypt_message(cipher, CIPHER_LEN, runtime_key, keylen, seed);
    
    // Keep process running for memory dump
    getchar();
    
    return 0;
}
