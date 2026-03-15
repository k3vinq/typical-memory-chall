# Testing Checklist for Challenge Creation

## Phase 1: Development (Ubuntu)

### Source Code
- [ ] Created `chatclient.c` with XOR encryption
- [ ] Key defined: `dev_secret_key`
- [ ] Message defined: `flag{memory_leaks_are_dangerous}`
- [ ] `encrypt()` function uses repeating-key XOR
- [ ] `main()` calls encrypt then blocks with `getchar()`

### Compilation
- [ ] mingw-w64 installed on Ubuntu
- [ ] Compiled with: `x86_64-w64-mingw32-gcc chatclient.c -o chatclient.exe`
- [ ] Binary type verified with `file chatclient.exe`
- [ ] Binary shows "PE32" or "PE32+ executable"
- [ ] No compilation warnings

### Logic Verification
- [ ] Created `test_decrypt.py`
- [ ] Script successfully encrypts test message
- [ ] Script successfully decrypts back to original
- [ ] Hex output matches expected format
- [ ] Created `decrypt_flag.py` solve script

---

## Phase 2: Windows VM Setup

### VM Preparation
- [ ] Windows VM running
- [ ] Copied `chatclient.exe` to VM
- [ ] DumpIt.exe or WinPMEM ready
- [ ] VM has at least 4GB RAM

### Program Execution
- [ ] Run `chatclient.exe` in VM
- [ ] Program displays "Encrypted message sent!"
- [ ] Program waiting at `getchar()` prompt
- [ ] Process visible in Task Manager

---

## Phase 3: Memory Dump Creation

### Dump Process
- [ ] Execute DumpIt.exe or WinPMEM
- [ ] Memory dump created: `memory.raw`
- [ ] File size reasonable (500MB-2GB)
- [ ] Transfer dump back to Ubuntu

### Initial Verification
- [ ] File transferred successfully
- [ ] MD5/SHA256 checksum recorded
- [ ] File not corrupted

---

## Phase 4: Artifact Verification (Ubuntu)

### Volatility Analysis
- [ ] Volatility3 installed
- [ ] `windows.info` shows correct Windows version
- [ ] `windows.pslist` shows `chatclient.exe`
- [ ] Process PID identified
- [ ] `windows.dumpfiles --pid <PID>` extracts binary
- [ ] Extracted binary matches original

### Memory Artifacts
- [ ] `windows.strings` shows `dev_secret_key`
- [ ] Encrypted message bytes findable
- [ ] No unexpected artifacts
- [ ] Key location noted for writeup

### Reverse Engineering
- [ ] Ghidra installed (optional, for verification)
- [ ] Binary loads in Ghidra without errors
- [ ] `encrypt()` function decompiles cleanly
- [ ] XOR algorithm clearly visible
- [ ] Key and message variables identified

---

## Phase 5: Solve Validation

### Manual Solve
- [ ] Followed intended solve path
- [ ] All steps work as expected
- [ ] Key recovered successfully
- [ ] Ciphertext extracted successfully
- [ ] `decrypt_flag.py` produces correct flag
- [ ] Flag format: `flag{memory_leaks_are_dangerous}`

### Time Tracking
- [ ] Recorded time for each solve step
- [ ] Total solve time reasonable (30-90 min)
- [ ] No dead ends or impossible steps

---

## Phase 6: Documentation

### Player-Facing
- [ ] Created `description.txt` for players
- [ ] Description clear and not misleading
- [ ] No accidental hints or leaks
- [ ] Tools list provided
- [ ] Flag format specified

### Internal Documentation
- [ ] `author_notes.md` complete
- [ ] Solution path documented
- [ ] Alternative solve methods considered
- [ ] Known issues documented
- [ ] Difficulty level justified

---

## Phase 7: Release Preparation

### File Organization
- [ ] Created release directory
- [ ] Copied `memory.raw` to release
- [ ] Copied `description.txt` to release
- [ ] NO source code in release
- [ ] NO solve scripts in release

### Packaging
- [ ] Compressed with `zip` or `tar.gz`
- [ ] File size acceptable for distribution
- [ ] Archive tested (extract and verify)
- [ ] Challenge name in filename

### Metadata
- [ ] Challenge name finalized
- [ ] Category confirmed (Forensics)
- [ ] Difficulty set (Easy-Medium)
- [ ] Point value decided (200-300)
- [ ] Author info added

---

## Phase 8: Final Testing

### Clean Environment Test
- [ ] Tested on different machine
- [ ] Tester has no prior knowledge
- [ ] Tester successfully solves
- [ ] Feedback collected
- [ ] Issues fixed

### Quality Checks
- [ ] No unintended solutions
- [ ] No guessing required
- [ ] Logical progression maintained
- [ ] Fair difficulty level

---

## Sign-off

**Challenge Creator:** ________________  
**Date:** ________________  
**Version:** 1.0  

**Status:** [ ] Ready for Release  [ ] Needs Revision

---

## Quick Reference Commands

```bash
# Compile on Ubuntu
x86_64-w64-mingw32-gcc chatclient.c -o chatclient.exe

# Check binary
file chatclient.exe

# Test decrypt logic
python3 solve/test_decrypt.py

# Volatility - list processes
volatility3 -f memory.raw windows.pslist

# Volatility - dump files
volatility3 -f memory.raw windows.dumpfiles --pid <PID>

# Volatility - search strings
volatility3 -f memory.raw windows.strings | grep "dev_secret"

# Create release package
cd release && zip -r chat-application-leak.zip challenge/
```
