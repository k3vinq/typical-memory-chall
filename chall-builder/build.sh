#!/bin/bash
# Compile script for chatclient.exe
# This script compiles the Windows executable on Ubuntu using MinGW

set -e  # Exit on error

echo "=========================================="
echo "Compiling chatclient.exe for Windows"
echo "=========================================="
echo

# Check if MinGW is installed
if ! command -v x86_64-w64-mingw32-gcc &> /dev/null; then
    echo "ERROR: MinGW not found!"
    echo "Please install it with:"
    echo "  sudo apt update"
    echo "  sudo apt install mingw-w64"
    exit 1
fi

echo "[*] MinGW found: $(x86_64-w64-mingw32-gcc --version | head -1)"
echo

# Navigate to source directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if source file exists
if [ ! -f "src/chatclient.c" ]; then
    echo "ERROR: src/chatclient.c not found!"
    exit 1
fi

echo "[*] Source file: src/chatclient.c"
echo "[*] Output file: bin/chatclient.exe"
echo

# Create bin directory if it doesn't exist
mkdir -p bin

# Compile
echo "[*] Compiling..."
x86_64-w64-mingw32-gcc \
    -Wall \
    -O2 \
    src/chatclient.c \
    -o bin/chatclient.exe

if [ $? -eq 0 ]; then
    echo "    ✓ Compilation successful!"
    echo
    
    # Verify binary
    echo "[*] Verifying binary..."
    file bin/chatclient.exe
    echo
    
    # Check size
    SIZE=$(du -h bin/chatclient.exe | cut -f1)
    echo "[*] Binary size: $SIZE"
    echo
    
    # Check for strings (key should be visible for easy mode)
    echo "[*] Checking for embedded strings..."
    if strings bin/chatclient.exe | grep -q "dev_secret_key"; then
        echo "    ✓ Key found in binary (good for easy difficulty)"
    else
        echo "    ⚠ Key not found in binary (may increase difficulty)"
    fi
    
    if strings bin/chatclient.exe | grep -q "Encrypted message sent"; then
        echo "    ✓ Program string found in binary"
    fi
    echo
    
    echo "=========================================="
    echo "✓ Build complete!"
    echo "=========================================="
    echo
    echo "Next steps:"
    echo "1. Test encryption logic: python3 solve/test_decrypt.py"
    echo "2. Copy bin/chatclient.exe to Windows VM"
    echo "3. Run the executable in Windows"
    echo "4. Create memory dump"
    echo
else
    echo "    ✗ Compilation failed!"
    exit 1
fi
