# Chat Application Leak - CTF Memory Forensics Challenge

## Overview

**Category:** Memory Forensics + Reverse Engineering  
**Difficulty:** Easy-Medium  
**Flag:** `flag{memory_leaks_are_dangerous}`

A developer created an experimental chat client that encrypts messages before sending them to a server. During testing, the application crashed. A memory dump was collected for debugging.

Your task: Analyze the memory dump and recover the secret message.

---

## Challenge Files

Players receive:
- `memory.raw` - Memory dump from Windows machine
- `description.txt` - Challenge description

---

## Expected Solution Path

### Step 1: Identify Suspicious Process

Use Volatility3 to list running processes:

```bash
volatility3 -f memory.raw windows.pslist
```

Look for suspicious process: `chatclient.exe`

### Step 2: Dump the Executable

```bash
volatility3 -f memory.raw windows.dumpfiles --pid <PID>
```

Extract `chatclient.exe` from memory.

### Step 3: Reverse Engineer the Binary

Open the binary in Ghidra or IDA Pro.

Analyze the encryption function to identify:
- XOR-based encryption
- Key location
- Message location

### Step 4: Extract Encryption Key

Search memory for strings:

```bash
volatility3 -f memory.raw windows.strings
```

or scan memory regions of the process.

Expected key: `dev_secret_key`

### Step 5: Extract Encrypted Message

Locate encrypted message bytes in memory dump within the process memory region.

### Step 6: Decrypt the Flag

Use XOR decryption with recovered key:

```python
key = b"dev_secret_key"
cipher = b"...encrypted bytes..."

plain = bytearray()
for i, b in enumerate(cipher):
    plain.append(b ^ key[i % len(key)])

print(plain.decode())
```

**Flag:** `flag{memory_leaks_are_dangerous}`

---

## Learning Objectives

This challenge teaches:
- Memory dump analysis with Volatility
- Process identification and dumping
- Basic binary reverse engineering
- Simple cryptanalysis (XOR)
- RAM data leakage concepts

---

## Tools Required

- Volatility3
- Ghidra or IDA Pro
- Python 3
- Hex editor (optional)

---

## Author Notes

This challenge demonstrates how sensitive data can leak through memory when applications crash. Players must combine forensics skills with reverse engineering to solve it.
