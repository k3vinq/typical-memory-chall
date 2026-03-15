# Installation Guide for Analysis Tools

## Volatility3 Installation

### Method 1: Using pip (Recommended)

```bash
# Install from PyPI
pip3 install volatility3

# Verify installation
volatility3 --help
vol3 --help  # Alternative command

# If command not found, add to PATH
echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
source ~/.bashrc
```

### Method 2: From Source

```bash
# Clone repository
git clone https://github.com/volatilityfoundation/volatility3.git
cd volatility3

# Install dependencies
pip3 install -r requirements.txt

# Run directly
python3 vol.py --help

# Or install globally
python3 setup.py install
```

### Method 3: Using pipx (Isolated Environment)

```bash
# Install pipx if not available
sudo apt install pipx
pipx ensurepath

# Install Volatility3
pipx install volatility3

# Verify
volatility3 --help
```

---

## Ghidra Installation

### Download and Setup

```bash
# Install Java (Ghidra requires JDK 11+)
sudo apt update
sudo apt install -y openjdk-17-jdk

# Download Ghidra from official site
# https://github.com/NationalSecurityAgency/ghidra/releases

# Example for version 10.4
cd ~/tools
wget https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.4_build/ghidra_10.4_PUBLIC_20230928.zip

# Extract
unzip ghidra_10.4_PUBLIC_20230928.zip
cd ghidra_10.4_PUBLIC

# Run Ghidra
./ghidraRun

# Optional: Create desktop shortcut or symlink
sudo ln -s ~/tools/ghidra_10.4_PUBLIC/ghidraRun /usr/local/bin/ghidra
```

### Alternative: Using apt (if available in your distro)

```bash
# Some distributions have Ghidra in repos
sudo apt install ghidra
```

---

## Alternative to Ghidra: Cutter (Free, Open Source)

```bash
# Download from GitHub releases
# https://github.com/rizinorg/cutter/releases

# Or install via AppImage
cd ~/tools
wget https://github.com/rizinorg/cutter/releases/download/v2.3.0/Cutter-v2.3.0-Linux-x86_64.AppImage
chmod +x Cutter-v2.3.0-Linux-x86_64.AppImage
./Cutter-v2.3.0-Linux-x86_64.AppImage
```

---

## Additional Useful Tools

### strings (usually pre-installed)

```bash
# Check if available
which strings

# Install if needed
sudo apt install binutils
```

### hexdump / xxd

```bash
# Usually pre-installed
which xxd
which hexdump

# Install if needed
sudo apt install bsdmainutils
```

### binwalk (for binary analysis)

```bash
sudo apt install binwalk
```

### radare2 (alternative disassembler)

```bash
# Install from package manager
sudo apt install radare2

# Or from source for latest version
git clone https://github.com/radareorg/radare2
cd radare2
sys/install.sh
```

---

## Verification Commands

After installation, verify all tools:

```bash
# Volatility3
volatility3 --version
# Expected: Volatility 3 Framework X.X.X

# Ghidra
which ghidra
# or just check the directory exists
ls ~/tools/ghidra_*/ghidraRun

# Python
python3 --version
# Expected: Python 3.8+

# MinGW
x86_64-w64-mingw32-gcc --version
# Expected: x86_64-w64-mingw32-gcc (...) X.X.X

# strings
strings --version

# hexdump
hexdump -V
```

---

## Creating Analysis Workspace

```bash
# Create a dedicated workspace for memory analysis
mkdir -p ~/forensics-workspace/{dumps,tools,cases}

# Set environment variables (optional)
echo 'export FORENSICS_WORKSPACE=~/forensics-workspace' >> ~/.bashrc
source ~/.bashrc
```

---

## Common Issues and Solutions

### Issue: volatility3 command not found

```bash
# Find where it was installed
pip3 show volatility3

# Add to PATH
export PATH=$PATH:~/.local/bin

# Make permanent
echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
```

### Issue: Ghidra won't start (missing Java)

```bash
# Check Java version
java -version

# Install if needed
sudo apt install openjdk-17-jdk

# Set JAVA_HOME if needed
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
```

### Issue: Permission denied for Volatility symbols

```bash
# Volatility3 needs symbol tables
# They're downloaded automatically, but might need write permissions

# Check symbols directory
ls -la ~/.cache/volatility3/

# Fix permissions if needed
chmod -R 755 ~/.cache/volatility3/
```

---

## Testing the Setup

Create a test script to verify everything works:

```bash
# Create test script
cat > ~/test-forensics-tools.sh << 'EOF'
#!/bin/bash

echo "Testing Forensics Tools Setup"
echo "=============================="
echo

# Test Volatility3
echo "[*] Testing Volatility3..."
if command -v volatility3 &> /dev/null; then
    echo "    ✓ Volatility3 is installed"
    volatility3 --version
else
    echo "    ✗ Volatility3 not found"
fi
echo

# Test Python
echo "[*] Testing Python..."
python3 --version
echo

# Test MinGW
echo "[*] Testing MinGW..."
if command -v x86_64-w64-mingw32-gcc &> /dev/null; then
    echo "    ✓ MinGW is installed"
    x86_64-w64-mingw32-gcc --version | head -1
else
    echo "    ✗ MinGW not found"
fi
echo

# Test Ghidra
echo "[*] Testing Ghidra..."
if [ -f ~/tools/ghidra_*/ghidraRun ]; then
    echo "    ✓ Ghidra is installed"
else
    echo "    ✗ Ghidra not found in ~/tools/"
fi
echo

echo "=============================="
echo "Setup test complete!"
EOF

chmod +x ~/test-forensics-tools.sh
~/test-forensics-tools.sh
```

---

## Quick Reference

| Tool | Purpose | Command |
|------|---------|---------|
| Volatility3 | Memory analysis | `volatility3 -f dump.raw windows.pslist` |
| Ghidra | Reverse engineering | `ghidraRun` or `ghidra` |
| MinGW | Cross-compile to Windows | `x86_64-w64-mingw32-gcc` |
| strings | Extract strings from binary | `strings file.exe` |
| xxd | Hex dump | `xxd file.bin` |

---

## Ready to Start!

Once all tools are installed and verified, you're ready to:

1. ✓ Compile Windows binaries on Ubuntu
2. ✓ Analyze memory dumps
3. ✓ Reverse engineer executables
4. ✓ Create and solve CTF forensics challenges
