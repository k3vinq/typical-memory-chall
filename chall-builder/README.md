# Challenge Setup - Ubuntu Workflow

## Quick Start Guide

Toàn bộ các bước có thể thực hiện trên Ubuntu trước khi cần Windows VM.

---

## Step 1: Install Dependencies

```bash
# Update package list
sudo apt update

# Install MinGW for cross-compilation
sudo apt install -y mingw-w64

# Install Python3 (usually pre-installed)
sudo apt install -y python3 python3-pip

# Install Volatility3 (choose one method)
# Method 1: Using pip
pip3 install volatility3

# Method 2: From source
git clone https://github.com/volatilityfoundation/volatility3.git
cd volatility3
pip3 install -r requirements.txt
```

---

## Step 2: Build the Challenge

```bash
# Navigate to project directory
cd /home/kevin/UIT/Forensic/ez-memory/chall-builder

# Compile the Windows executable
x86_64-w64-mingw32-gcc src/chatclient.c -o bin/chatclient.exe

# Verify the binary
file bin/chatclient.exe
# Expected: bin/chatclient.exe: PE32+ executable (console) x86-64, for MS Windows

# Check strings in binary (should see key for easy mode)
strings bin/chatclient.exe | grep -i secret
```

---

## Step 3: Test Encryption Logic

```bash
# Test the XOR algorithm
python3 solve/test_decrypt.py

# Expected output:
# ✓ Encryption/Decryption logic is CORRECT

# Test the solve script
python3 solve/decrypt_flag.py

# Expected output:
# FLAG: flag{memory_leaks_are_dangerous}
```

---

## Step 4: Prepare Windows VM

**Note:** This step requires Windows VM (VirtualBox, VMware, or QEMU)

1. Start Windows VM
2. Copy `bin/chatclient.exe` to VM
3. Download DumpIt or WinPMEM in VM
4. Run `chatclient.exe`
5. Execute memory dump tool
6. Copy `memory.raw` back to Ubuntu

---

## Step 5: Verify Memory Dump (Ubuntu)

```bash
# Check dump file
ls -lh memory.raw

# Verify with Volatility3
volatility3 -f memory.raw windows.info

# List processes
volatility3 -f memory.raw windows.pslist | grep chatclient

# Search for key in memory
volatility3 -f memory.raw windows.strings | grep "dev_secret_key"

# Dump the process executable
volatility3 -f memory.raw windows.dumpfiles --pid <PID>
```

---

## Step 6: Create Release Package

```bash
# Create release directory
mkdir -p release/challenge

# Copy files
cp memory.raw release/challenge/
cp docs/challenge_description.md release/challenge/description.txt

# Create archive
cd release
zip -9 -r chat-application-leak.zip challenge/

# Verify archive
unzip -l chat-application-leak.zip
```

---

## Project Structure

```
chall-builder/
├── src/
│   └── chatclient.c              # Source code
├── bin/
│   └── chatclient.exe            # Compiled Windows binary
├── docs/
│   ├── challenge_description.md  # Player-facing description
│   └── author_notes.md           # Internal notes
├── solve/
│   ├── test_decrypt.py           # Test script
│   └── decrypt_flag.py           # Solution script
├── test/
│   └── checklist.md              # Testing checklist
└── README.md                     # This file
```

---

## Verification Commands

```bash
# Check if MinGW is installed
which x86_64-w64-mingw32-gcc

# Check Python version
python3 --version

# Check Volatility3
volatility3 --help

# Check compiled binary
file bin/chatclient.exe
strings bin/chatclient.exe
```

---

## Troubleshooting

### MinGW not found
```bash
sudo apt install mingw-w64
```

### Volatility3 not found
```bash
pip3 install volatility3
# or add to PATH:
export PATH=$PATH:~/.local/bin
```

### Binary won't compile
```bash
# Check GCC version
x86_64-w64-mingw32-gcc --version

# Try with explicit flags
x86_64-w64-mingw32-gcc -Wall -O2 src/chatclient.c -o bin/chatclient.exe
```

---

## Next Steps

After completing all Ubuntu steps:

1. ✓ Binary compiled and verified
2. ✓ Logic tested with Python scripts
3. ✓ Documentation prepared
4. → Move to Windows VM for memory dump creation
5. → Return to Ubuntu for verification and packaging

---

## What Can Be Done on Ubuntu

✅ Write source code
✅ Compile Windows executable
✅ Test encryption/decryption logic
✅ Prepare all documentation
✅ Install analysis tools (Volatility, Ghidra)
✅ Verify memory dump artifacts
✅ Create solve scripts
✅ Package final release

## What Requires Windows VM

❌ Run the Windows executable
❌ Create memory dump with DumpIt/WinPMEM

**Time on Ubuntu:** 90% of challenge creation
**Time on Windows:** 10% (just for memory dump)
