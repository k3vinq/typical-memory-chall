# Solution Walkthrough: ez-memory Challenge

**Challenge:** ez-memory (Rolling-Key XOR Memory Forensics)  
**Category:** Forensics / Memory Analysis  
**Difficulty:** Easy-Medium  
**Tools Required:** Volatility3, Ghidra/IDA, Python3, strings, grep

---

## Overview

You are given a Windows memory dump (`memory.raw`). Somewhere in this memory, a suspicious process is running with an encrypted message. Your goal is to extract the flag through memory forensics and reverse engineering.

**Flag format:** `inseclab{...}`

---

## Step 1: Identify Suspicious Process

First, let's see what processes were running when the memory dump was captured.

**Command:**
```bash
volatility3 -f memory.raw windows.pslist
```

**What to look for:**

Scan through the process list. You're looking for processes that seem out of place or suspicious. Pay attention to:
- Unusual process names
- Processes running from unusual locations
- Non-standard Windows processes

**Expected finding:**

You should spot a process named `chatclient.exe`. This is not a standard Windows process, which makes it highly suspicious.

**Note the PID** - you'll need it for the next steps. Let's say the PID is `1234` (yours will be different).

---

## Step 2: Extract the Binary

Now that we've identified the suspicious process, let's extract its executable from memory.

**Command:**
```bash
volatility3 -f memory.raw windows.dumpfiles --pid 1234
```

Replace `1234` with the actual PID you found.

**What happens:**

Volatility will dump various files associated with this process. You'll see output like:
```
Dumping file.0x....chatclient.exe.dat
```

**Rename the file:**
```bash
mv file.0x*.chatclient.exe.dat chatclient.exe
```

**Verify it's a valid executable:**
```bash
file chatclient.exe
```

You should see: `PE32+ executable (console) x86-64, for MS Windows`

---

## Step 3: Initial Analysis with Strings

Before diving into reverse engineering, let's do some quick reconnaissance with `strings`.

**Command:**
```bash
strings chatclient.exe | less
```

**What to look for:**

- Any plaintext strings that might be interesting
- Function names
- Error messages
- Potential keys or data

**Key findings:**

You should notice:
- `uit_` - looks like a fragment
- `insec_` - another fragment
- `lab` - yet another fragment
- `Message processed successfully!` - an output message

**Important observation:** Notice that these look like fragments of a larger key. There's no complete key visible. Also, you won't see the flag in plaintext - it must be encrypted.

---

## Step 4: Reverse Engineering with Ghidra

Now it's time to understand what this program actually does.

**Load the binary:**
1. Open Ghidra
2. Create a new project
3. Import `chatclient.exe`
4. Let Ghidra analyze it (use default options)

**Find the main function:**
1. Go to Symbol Tree → Functions
2. Look for `main` or `entry`
3. Double-click to view the decompiled code

**What you'll see in main():**

The decompiled code will show something like this (variable names may differ):

1. **Key fragment concatenation:**
   - Three arrays: `k1`, `k2`, `k3`
   - A loop copying each fragment into `runtime_key`
   - This builds the complete key at runtime

2. **Seed calculation:**
   - Two variables: `a = 0x21` and `b = 0x63`
   - Seed computed as `a ^ b`
   - This gives `seed = 0x42`

3. **Function call:**
   - A call to another function (likely `decrypt_message`)
   - Parameters passed: cipher array, length, runtime_key, keylen, seed

**Navigate to decrypt_message():**

Double-click on the function call to jump to its definition.

**Algorithm analysis:**

You'll see a loop that does something like:
```c
for (i = 0; i < len; i++) {
    buffer[i] = cipher[i] ^ key[i % keylen] ^ state;
    state = (state + 13) & 0xff;
}
```

**Key observations:**
1. Each ciphertext byte is XORed with a key byte
2. Each byte is also XORed with a `state` variable
3. The state changes after each byte: `state += 13` (mod 256)
4. This is a **rolling-key XOR** algorithm

---

## Step 5: Extract the Key from Memory

We know the key is built from three fragments: `uit_`, `insec_`, and `lab`. But what's the complete key, and in what order?

**Dump process memory:**
```bash
volatility3 -f memory.raw windows.memmap --pid 1234 --dump
```

This creates a file like `pid.1234.dmp` containing the process's memory.

**Search for the runtime key:**
```bash
strings pid.1234.dmp | grep -i "uit_insec"
```

**Expected result:**

You should find the string: `uit_insec_lab`

This confirms:
- The complete key is `uit_insec_lab`
- The order is: k1 + k2 + k3 = `uit_` + `insec_` + `lab`

**Why is this important?**

While we could guess the order from the fragments, finding it in memory confirms our understanding and eliminates ambiguity.

---

## Step 6: Extract the Ciphertext

We need the encrypted data to decrypt.

**Method 1: From Ghidra**

In the main function's decompiled view, look for the `cipher` array. You'll see something like:
```
unsigned char cipher[36] = {
    0x5e, 0x48, 0x5b, 0x53, 0x7c, ...
};
```

Copy these hex values.

**Method 2: From binary dump**

If you prefer, you can also extract it using Ghidra's data view:
1. Find the `.data` section
2. Look for a 36-byte array
3. Export or copy the bytes

**The ciphertext (36 bytes):**
```
5e485b537c81829ab285cdddd3ece82e21132321506f5e737eba85a9b483c4c9feffec2b
```

---

## Step 7: Understand the Algorithm Parameters

Let's summarize what we've learned:

**Algorithm:** Rolling-Key XOR
```python
state = seed
for each byte i:
    plaintext[i] = ciphertext[i] ^ key[i % keylen] ^ state
    state = (state + 13) & 0xff
```

**Parameters we've extracted:**
- **Key:** `uit_insec_lab` (13 bytes)
- **Seed:** `0x42` (calculated from `0x21 ^ 0x63`)
- **Ciphertext:** 36 bytes (hex string above)
- **State update:** `+13 mod 256`

---

## Step 8: Write the Decryption Script

Now we have everything we need to decrypt the flag.

**Create `solve.py`:**

```python
#!/usr/bin/env python3

def rolling_xor_decrypt(ciphertext, key, seed):
    """
    Decrypt using rolling-key XOR algorithm
    
    Args:
        ciphertext: bytes - encrypted data
        key: bytes - encryption key
        seed: int - initial seed value
    
    Returns:
        bytes - decrypted plaintext
    """
    plaintext = bytearray()
    state = seed
    keylen = len(key)
    
    for i, cipher_byte in enumerate(ciphertext):
        # Decrypt: XOR with key and state
        plain_byte = cipher_byte ^ key[i % keylen] ^ state
        plaintext.append(plain_byte)
        
        # Update state (rolling)
        state = (state + 13) & 0xff
    
    return bytes(plaintext)


# Parameters extracted from analysis
key = b"uit_insec_lab"
seed = 0x42

# Ciphertext extracted from binary
ciphertext = bytes.fromhex(
    "5e485b537c81829ab285cdddd3ece82e21132321506f5e737eba85a9b483c4c9feffec2b"
)

# Decrypt
flag = rolling_xor_decrypt(ciphertext, key, seed)

# Display result
print("=" * 60)
print("DECRYPTED FLAG:")
print("=" * 60)
print(flag.decode())
print("=" * 60)
```

**Make it executable:**
```bash
chmod +x solve.py
```

---

## Step 9: Get the Flag

**Run the script:**
```bash
python3 solve.py
```

**Output:**
```
============================================================
DECRYPTED FLAG:
============================================================
inseclab{memory_leaks_are_dangerous}
============================================================
```

**🎉 Flag captured!**

---

## Alternative Approaches

### Approach 1: Brute Force the Seed (Not Recommended)

If you couldn't find the seed calculation in reverse engineering, you could brute force it since it's only 0-255:

```python
for seed in range(256):
    result = rolling_xor_decrypt(ciphertext, key, seed)
    if result.startswith(b'inseclab{'):
        print(f"Found seed: {seed:#x}")
        print(f"Flag: {result.decode()}")
        break
```

### Approach 2: Guess Key Order (Risky)

If memory dump failed, you could try all permutations of the fragments:

```python
from itertools import permutations

fragments = [b"uit_", b"insec_", b"lab"]
for perm in permutations(fragments):
    key = b"".join(perm)
    result = rolling_xor_decrypt(ciphertext, key, 0x42)
    if result.startswith(b'inseclab{'):
        print(f"Found key order: {key.decode()}")
        print(f"Flag: {result.decode()}")
        break
```

---

## Key Takeaways

**What you learned:**

1. **Memory Forensics:** Using Volatility3 to analyze Windows memory dumps
2. **Process Analysis:** Identifying suspicious processes in pslist
3. **Binary Extraction:** Dumping executables from memory
4. **Reverse Engineering:** Using Ghidra to understand program logic
5. **Cryptanalysis:** Understanding rolling-key XOR encryption
6. **Runtime Analysis:** Extracting artifacts from process memory
7. **Scripting:** Writing Python to automate decryption

**Why memory forensics was crucial:**

- The flag wasn't in the binary (only ciphertext)
- The full key only existed in RAM after runtime concatenation
- Understanding the process behavior required memory context

**Tools mastered:**

- ✅ Volatility3 (pslist, dumpfiles, memmap)
- ✅ Ghidra (binary analysis, decompilation)
- ✅ Python (algorithm implementation)
- ✅ Unix tools (strings, grep, file)

---

## Challenge Difficulty Analysis

**Easy aspects:**
- Clear process name to identify
- Simple algorithm (XOR-based)
- Key fragments visible in strings
- Standard Volatility workflow

**Medium aspects:**
- Rolling state adds complexity to XOR
- Need to understand algorithm from assembly
- Runtime key construction requires memory analysis
- Multiple steps needed (can't shortcuts)

**Why it's a good learning challenge:**

This challenge teaches real forensics techniques without overwhelming complexity. The rolling-key XOR is simple enough to understand but complex enough to require actual analysis. You can't just `strings` your way to victory!

---

## Common Mistakes to Avoid

❌ **Mistake 1:** Assuming simple repeating-key XOR
- The state variable is crucial - don't ignore it!

❌ **Mistake 2:** Wrong key order
- Always confirm with memory dump or careful reverse engineering

❌ **Mistake 3:** Forgetting the state update
- `state = (state + 13) & 0xff` - the `& 0xff` ensures mod 256

❌ **Mistake 4:** Using wrong seed value
- Seed is `0x42`, not `0x21` or `0x63` individually

❌ **Mistake 5:** Skipping memory analysis
- While you might guess correctly, intended path involves memory forensics

---

## Next Steps

**Want more challenge?**

Try these variations:
1. Find the plaintext in memory dump (if it exists)
2. Write a script to automate the entire solve process
3. Create your own similar challenge with a different algorithm
4. Try solving without the seed (brute force 0-255)
5. Analyze the binary with IDA instead of Ghidra

**Further learning:**

- Study more complex XOR variants (CBC-mode XOR, stream ciphers)
- Learn about memory forensics for other OSes (Linux, macOS)
- Practice with real malware samples (in safe environments)
- Study anti-forensics techniques

---

## Solution Summary

```
1. volatility3 pslist           → Find chatclient.exe (PID: 1234)
2. volatility3 dumpfiles        → Extract binary
3. strings chatclient.exe       → Find key fragments: uit_, insec_, lab
4. Ghidra analysis              → Understand rolling-key XOR algorithm
5. Ghidra analysis              → Find seed calculation: 0x21 ^ 0x63 = 0x42
6. volatility3 memmap           → Dump process memory
7. strings + grep               → Confirm full key: uit_insec_lab
8. Ghidra data view             → Extract ciphertext (36 bytes)
9. Python script                → Implement decryption
10. Run script                  → Get flag: inseclab{memory_leaks_are_dangerous}
```

**Time estimate:**
- First time: 30-60 minutes
- Experienced: 15-20 minutes

---

**Congratulations on solving the challenge! 🎯**

*Flag: `inseclab{memory_leaks_are_dangerous}`*
