# Author Internal Notes

## Challenge Metadata

- **Name:** Chat Application Leak
- **Category:** Forensics / Memory Analysis
- **Difficulty:** Easy-Medium
- **Author:** [Your Name]
- **Flag:** `flag{memory_leaks_are_dangerous}`
- **Points:** 200-300

---

## Challenge Design

### Core Concept
Memory forensics challenge combining:
1. Process identification
2. Binary extraction
3. Reverse engineering
4. Simple crypto (XOR)

### Key Components

**Encryption Key:** `dev_secret_key`
- Stored as global variable in binary
- Visible in memory dump
- Plain ASCII (for easy difficulty)

**Flag:** `flag{memory_leaks_are_dangerous}`
- Encrypted in-place using XOR
- Remains in process memory after encryption
- Format follows standard CTF convention

**Binary:** `chatclient.exe`
- Windows PE executable
- Small size (~50KB)
- No obfuscation (easy mode)
- Contains visible strings

---

## Required Memory Artifacts

When creating memory dump, ensure these are present:

✓ Process `chatclient.exe` appears in process list
✓ Binary can be dumped using `windows.dumpfiles`
✓ Key string `dev_secret_key` exists in memory
✓ Encrypted message bytes exist in process memory
✓ No other processes interfere with challenge

---

## Intended Solution Path

1. **Discovery** (5 min)
   - Run `volatility3 -f memory.raw windows.pslist`
   - Identify `chatclient.exe` as suspicious

2. **Extraction** (10 min)
   - Dump process using `windows.dumpfiles --pid <PID>`
   - Extract executable from output

3. **Reverse Engineering** (15-20 min)
   - Load binary in Ghidra/IDA
   - Find `encrypt()` function
   - Identify XOR algorithm
   - Locate key and message variables

4. **Memory Forensics** (10 min)
   - Use `windows.strings` or `windows.vadinfo`
   - Find key: `dev_secret_key`
   - Extract encrypted message bytes

5. **Decryption** (5 min)
   - Write Python XOR decrypt script
   - Recover flag

**Total Expected Solve Time:** 45-60 minutes for intermediate player

---

## Testing Checklist

### Before Creating Memory Dump

- [ ] `chatclient.c` compiles without warnings
- [ ] `chatclient.exe` is valid PE32/PE32+ executable
- [ ] Running `strings chatclient.exe` shows key (for easy mode)
- [ ] XOR logic verified with `test_decrypt.py`
- [ ] Flag format is correct

### After Creating Memory Dump

- [ ] Process visible in `windows.pslist`
- [ ] Binary dumpable via `windows.dumpfiles`
- [ ] Key findable via `windows.strings` or memory scan
- [ ] Encrypted message located in process memory
- [ ] Can solve using intended path
- [ ] File size reasonable (<500MB compressed)

### Before Release

- [ ] Source code NOT included in release package
- [ ] Only `memory.raw` and `description.txt` provided
- [ ] Challenge description doesn't leak solution
- [ ] Flag verified to match intended
- [ ] Tested on clean VM

---

## Difficulty Adjustment Options

### To Make Harder

1. **Hide Key**
   - Allocate key on heap instead of .data section
   - Encode key (base64, hex)
   - Split key across memory regions

2. **Obfuscate Binary**
   - Strip symbols
   - Use UPX packing
   - Add anti-debugging checks

3. **Complex Crypto**
   - Use AES instead of XOR
   - Multi-stage encryption
   - Key derivation function

4. **Add Noise**
   - Run multiple processes
   - Add decoy strings
   - Larger memory dump

### To Make Easier (Current State)

- ✓ Key as plain ASCII string
- ✓ Simple XOR encryption
- ✓ No obfuscation
- ✓ Strings visible in binary
- ✓ Clean memory dump

---

## Potential Issues & Solutions

### Issue: Key not found in memory
**Solution:** Ensure program is paused (getchar) before dump

### Issue: Binary too stripped
**Solution:** Compile without `-s` flag

### Issue: Encrypted message overwritten
**Solution:** Message must be global/static, not stack variable

### Issue: Process terminated before dump
**Solution:** Add `getchar()` to keep process alive

---

## Validation Commands

```bash
# Check binary type
file chatclient.exe

# Check strings in binary
strings chatclient.exe | grep -i key

# Test Volatility
volatility3 -f memory.raw windows.info

# List processes
volatility3 -f memory.raw windows.pslist | grep chat

# Dump files
volatility3 -f memory.raw windows.dumpfiles --pid <PID>

# Search strings
volatility3 -f memory.raw windows.strings | grep dev_secret
```

---

## Release Package Structure

```
chat-application-leak/
├── memory.raw          # Memory dump (400-800MB)
└── description.txt     # Challenge description
```

**Compressed size:** ~100-200MB (zip with compression)

---

## Flag Verification

Final flag must be exactly:
```
flag{memory_leaks_are_dangerous}
```

No spaces, all lowercase, standard CTF format.
