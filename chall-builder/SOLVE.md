# CTF Memory Forensics Challenge - Solution Writeup

**Challenge:** ez-memory (Rolling-Key XOR)  
**Category:** Memory Forensics / Reverse Engineering  
**Difficulty:** Easy-Medium  
**Author:** kevin @ INSECLAB/UIT

---

## Challenge Description

You are given a memory dump (`memory.raw`) from a Windows machine. Intelligence suggests that a suspicious chat application was running at the time of capture, and it may contain sensitive information. Your task is to analyze the memory dump, extract the binary, reverse engineer it, and recover the hidden flag.

**Files Provided:**
- `memory.raw` - Windows memory dump (several GB)
- `description.txt` - Challenge description

**Flag Format:** `inseclab{...}`

---

## Tools Required

Before starting, ensure you have these tools installed:

- **Volatility3** - Memory forensics framework
- **Ghidra** or **IDA Pro** - Binary reverse engineering
- **Python 3** - For scripting
- **strings** - Extract strings from binaries
- **file** - Identify file types
- **hex editor** (optional) - For manual binary inspection

**Installation:**
```bash
# Volatility3
pip3 install volatility3

# Ghidra
# Download from https://ghidra-sre.org/

# Other tools (usually pre-installed on Linux)
sudo apt install binutils python3
```

---

## Solution Walkthrough

### Step 1: Identify Suspicious Process

**Objective:** Find the suspicious process in the memory dump.

First, let's see what processes were running at the time of capture:

```bash
volatility3 -f memory.raw windows.pslist
```

**Expected Output:**
```
PID     PPID    ImageFileName           Offset(V)       Threads Handles
...
1234    5678    chatclient.exe          0x...           1       12
...
```

**Analysis:**

Look through the process list for anything unusual. `chatclient.exe` stands out because:
- It's not a standard Windows process
- The name suggests it's a chat application
- It matches the challenge description

**Key Finding:** Process `chatclient.exe` with PID `1234` (note: your PID will differ)

---

### Step 2: Dump the Executable

**Objective:** Extract the suspicious binary from memory.

Now that we know the PID, let's dump the executable:

```bash
volatility3 -f memory.raw windows.dumpfiles --pid 1234
```

This will extract several files. Look for the main executable:

```bash
ls -lh file.*.exe.*.dmp
```

**Verify the file:**
```bash
file file.0x*.chatclient.exe.*.dmp
```

**Expected Output:**
```
file.0x7ff...chatclient.exe.dat: PE32+ executable (console) x86-64, for MS Windows
```

**Rename for convenience:**
```bash
mv file.0x*.chatclient.exe.*.dmp chatclient.exe
chmod +x chatclient.exe
```

**Key Finding:** Extracted `chatclient.exe` binary (around 245-250KB)

---

### Step 3: Initial Binary Analysis

**Objective:** Understand what the binary contains without running it.

**Check file type:**
```bash
file chatclient.exe
```

Output: `PE32+ executable (console) x86-64, for MS Windows`

**Look for interesting strings:**
```bash
strings chatclient.exe | less
```

**Interesting findings:**
```
uit_
insec_
lab
Message processed successfully!
```

**What we notice:**
- Three short strings: `uit_`, `insec_`, `lab` - possibly key fragments?
- A generic success message
- No obvious plaintext flag
- No complete key visible

**Try searching for the flag:**
```bash
strings chatclient.exe | grep -i "inseclab"
```

Result: Nothing found. The flag is not in plaintext.

**Key Finding:** The binary contains key fragments but no plaintext flag.

---

### Step 4: Reverse Engineering with Ghidra

**Objective:** Understand the encryption algorithm.

**Load the binary:**
1. Open Ghidra
2. Create a new project
3. Import `chatclient.exe`
4. Analyze the binary (use default options)

**Find the main function:**
1. Go to Symbol Tree → Functions
2. Look for `entry` or `main`
3. Double-click to view decompiled code

**Analyzing main():**

You'll see something like this (simplified decompilation):

```c
int main(void) {
    // Key fragment concatenation
    unsigned char runtime_key[32];
    int pos = 0;
    
    // Copy k1: "uit_"
    for (i = 0; i < strlen(k1); i++) {
        runtime_key[pos++] = k1[i];
    }
    
    // Copy k2: "insec_"
    for (i = 0; i < strlen(k2); i++) {
        runtime_key[pos++] = k2[i];
    }
    
    // Copy k3: "lab"
    for (i = 0; i < strlen(k3); i++) {
        runtime_key[pos++] = k3[i];
    }
    
    int keylen = pos;
    
    // Seed calculation
    unsigned char a = 0x21;
    unsigned char b = 0x63;
    unsigned char seed = a ^ b;  // = 0x42
    
    // Call decrypt function
    decrypt_message(cipher, CIPHER_LEN, runtime_key, keylen, seed);
    
    getchar();
    return 0;
}
```

**Key observations:**
1. **Key construction:** Three fragments are concatenated: `uit_` + `insec_` + `lab` = `uit_insec_lab`
2. **Seed calculation:** `0x21 ^ 0x63 = 0x42`
3. **Cipher array:** There's a global array called `cipher` with encrypted data
4. **Decrypt function:** A function is called with these parameters

**Find decrypt_message():**

Navigate to the function called from main. You'll see:

```c
void decrypt_message(unsigned char *cipher, int len, 
                     unsigned char *key, int keylen, 
                     unsigned char seed) {
    unsigned char state = seed;
    unsigned char buffer[256];
    
    for (int i = 0; i < len; i++) {
        // Rolling-key XOR
        buffer[i] = cipher[i] ^ key[i % keylen] ^ state;
        
        // Update state
        state = (state + 13) & 0xff;
    }
    
    buffer[len] = '\0';
    
    if (buffer[0] != 0) {
        printf("Message processed successfully!\n");
    }
}
```

**Algorithm analysis:**

This is a **rolling-key XOR** with these characteristics:
- Each byte is XOR'd with both the key (repeating) and a rolling state
- Formula: `plaintext[i] = ciphertext[i] ^ key[i % keylen] ^ state`
- State increments by 13 each iteration: `state = (state + 13) % 256`
- Initial state = seed = `0x42`

**Key Finding:** Rolling-key XOR algorithm identified with seed `0x42` and key `uit_insec_lab`.

---

### Step 5: Extract the Ciphertext

**Objective:** Get the encrypted flag bytes.

**In Ghidra:**

1. Go to Symbol Tree → Data
2. Look for `cipher` array
3. Right-click → Copy Special → Byte String

You should see something like:
```
5e 48 5b 53 7c 81 82 9a b2 85 cd dd d3 ec e8 2e 
21 13 23 21 50 6f 5e 73 7e ba 85 a9 b4 83 c4 c9 
fe ff ec 2b
```

**Alternative method using command line:**

```bash
# Extract .data section
objdump -s -j .data chatclient.exe | less

# Or search for byte patterns
xxd chatclient.exe | grep "5e 48 5b"
```

**Key Finding:** Ciphertext is 36 bytes: `5e485b537c81829ab285cdddd3ece82e21132321506f5e737eba85a9b483c4c9feffec2b`

---

### Step 6: Confirm Key in Memory (Optional)

**Objective:** Verify the runtime key exists in memory as expected.

This step confirms our reverse engineering is correct by finding the complete key in RAM.

**Dump process memory:**
```bash
volatility3 -f memory.raw windows.memmap --pid 1234 --dump
```

This creates a file like `pid.1234.dmp`.

**Search for the key:**
```bash
strings pid.1234.dmp | grep "uit_insec"
```

**Expected result:**
```
uit_insec_lab
```

Perfect! The runtime-concatenated key exists in memory exactly as we reconstructed from our analysis.

**Why this matters:**

This confirms that:
- Our understanding of the key construction is correct
- The binary actually ran and created the runtime key
- Memory forensics was necessary to confidently solve this challenge

---

### Step 7: Write Decryption Script

**Objective:** Implement the decryption algorithm in Python.

Create a file called `solve.py`:

```python
#!/usr/bin/env python3

def rolling_xor_decrypt(ciphertext, key, seed):
    """
    Decrypt using rolling-key XOR algorithm.
    
    Args:
        ciphertext: bytes - encrypted data
        key: bytes - encryption key
        seed: int - initial state value (0-255)
    
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
        
        # Update rolling state
        state = (state + 13) & 0xff
    
    return bytes(plaintext)


if __name__ == "__main__":
    # Key from reverse engineering (fragments concatenated)
    key = b"uit_insec_lab"
    
    # Seed from reverse engineering (0x21 ^ 0x63)
    seed = 0x42
    
    # Ciphertext extracted from binary
    ciphertext = bytes.fromhex(
        "5e485b537c81829ab285cdddd3ece82e21132321506f5e737eba85a9b483c4c9feffec2b"
    )
    
    print("[*] Rolling-Key XOR Decryption")
    print(f"[*] Key: {key.decode()}")
    print(f"[*] Key length: {len(key)} bytes")
    print(f"[*] Seed: 0x{seed:02x}")
    print(f"[*] Ciphertext length: {len(ciphertext)} bytes")
    print()
    
    # Decrypt
    flag = rolling_xor_decrypt(ciphertext, key, seed)
    
    print("="*60)
    print("FLAG:", flag.decode())
    print("="*60)
```

**Run the script:**
```bash
chmod +x solve.py
python3 solve.py
```

**Expected output:**
```
[*] Rolling-Key XOR Decryption
[*] Key: uit_insec_lab
[*] Key length: 13 bytes
[*] Seed: 0x42
[*] Ciphertext length: 36 bytes

============================================================
FLAG: inseclab{memory_leaks_are_dangerous}
============================================================
```

**Key Finding:** Flag recovered: `inseclab{memory_leaks_are_dangerous}`

---

## Summary

### Complete Solve Path

1. **Identify suspicious process** → `chatclient.exe` (PID 1234)
2. **Dump executable** → Extract binary from memory dump
3. **Initial analysis** → Find key fragments: `uit_`, `insec_`, `lab`
4. **Reverse engineering** → Understand rolling-key XOR algorithm
5. **Extract ciphertext** → 36 bytes from binary's `.data` section
6. **Confirm key in memory** → Find `uit_insec_lab` in RAM
7. **Calculate seed** → `0x21 ^ 0x63 = 0x42`
8. **Write decryption script** → Implement algorithm in Python
9. **Recover flag** → `inseclab{memory_leaks_are_dangerous}`

### Key Concepts Learned

**Memory Forensics:**
- Using Volatility3 to analyze Windows memory dumps
- Identifying suspicious processes
- Dumping executables from memory

**Reverse Engineering:**
- Loading PE executables in Ghidra
- Reading decompiled C code
- Understanding encryption algorithms
- Extracting data from binary sections

**Cryptanalysis:**
- Understanding XOR-based encryption
- Recognizing rolling-state ciphers
- Implementing decryption algorithms

**Why Memory Forensics Was Essential:**

While some information could be found in the binary alone, memory forensics was crucial because:
- The binary had to be extracted from the memory dump (we weren't given the binary directly)
- The runtime key only exists in RAM after fragments are concatenated
- Confirming the key in memory validates our reverse engineering
- This is realistic: in real incidents, you often only have memory dumps

---

## Alternative Approaches

### Approach 1: Brute Force Seed (Not Recommended)

If you couldn't reverse engineer the seed calculation, you could brute force it:

```python
for seed in range(256):
    plaintext = rolling_xor_decrypt(ciphertext, key, seed)
    if b"inseclab{" in plaintext:
        print(f"Found seed: 0x{seed:02x}")
        print(f"Flag: {plaintext.decode()}")
        break
```

This works but defeats the purpose of the challenge.

### Approach 2: Dynamic Analysis (Dangerous)

You could theoretically run the binary in a Windows VM and observe its behavior. **However:**
- This is dangerous with unknown binaries
- The binary is designed to not reveal the flag when run
- You'd still need to analyze memory or reverse engineer

### Approach 3: Strings-Only (Fails)

Some might try:
```bash
strings memory.raw | grep "inseclab{"
```

This won't work because:
- The flag is encrypted in the binary
- Even if decrypted in memory, it might not persist as a clean string
- You'd still need to find and analyze the binary

---

## Common Pitfalls

### Mistake 1: Wrong Key Order

If you guess the key order incorrectly (e.g., `lab_insec_uit` instead of `uit_insec_lab`), your decryption will fail. Always verify with:
- Disassembly order of concatenation
- Memory dump search results

### Mistake 2: Incorrect Seed

Using `seed = 0` or other common values will produce garbage output. The seed must be calculated correctly: `0x21 ^ 0x63 = 0x42`.

### Mistake 3: Forgetting State Update

Some might implement only the XOR without the rolling state:
```python
# WRONG
plaintext[i] = cipher[i] ^ key[i % keylen]  # Missing state!
```

This will decrypt incorrectly.

### Mistake 4: Off-by-One in State Update

The state updates AFTER each byte:
```python
# CORRECT
plaintext[i] = cipher[i] ^ key[i % keylen] ^ state
state = (state + 13) & 0xff

# WRONG
state = (state + 13) & 0xff
plaintext[i] = cipher[i] ^ key[i % keylen] ^ state  # Updated too early!
```

---

## Tools Used Summary

| Tool | Purpose | Command Example |
|------|---------|----------------|
| **Volatility3** | Memory analysis | `volatility3 -f memory.raw windows.pslist` |
| **Ghidra** | Reverse engineering | GUI-based analysis |
| **strings** | Extract readable text | `strings chatclient.exe` |
| **file** | Identify file types | `file chatclient.exe` |
| **Python** | Scripting/automation | `python3 solve.py` |
| **grep** | Search patterns | `grep "inseclab"` |
| **xxd** | Hex dump | `xxd chatclient.exe` |

---

## Difficulty Analysis

**Easy aspects:**
- ✅ Rolling-key XOR is straightforward once understood
- ✅ Key fragments are visible with `strings`
- ✅ Algorithm is clear in disassembly
- ✅ Seed calculation is simple

**Medium aspects:**
- ⚠️ Requires multiple tool proficiencies
- ⚠️ Need to understand rolling state concept
- ⚠️ Must correctly reconstruct key order
- ⚠️ Multi-step process with no shortcuts

**What makes it a good challenge:**
- Teaches real memory forensics workflow
- Requires both forensics AND reverse engineering
- Has a clear intended solve path
- Educational without being frustrating

---

## Flag

```
inseclab{memory_leaks_are_dangerous}
```

---

**Congratulations on solving the challenge! 🎉**

*If you enjoyed this challenge or have feedback, please reach out to the author at INSECLAB/UIT.*
