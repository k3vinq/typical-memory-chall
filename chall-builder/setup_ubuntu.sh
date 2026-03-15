#!/bin/bash
# Complete setup script for the challenge on Ubuntu
# This installs all necessary tools and prepares the environment

set -e

echo "============================================"
echo "CTF Memory Forensics Challenge Setup"
echo "============================================"
echo

# Function to check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to check if package is installed (Debian/Ubuntu)
package_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q "^ii"
}

echo "[*] Checking system requirements..."
echo

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "WARNING: Don't run this script as root!"
    echo "It will prompt for sudo when needed."
    exit 1
fi

# Update package list
echo "[*] Updating package list..."
sudo apt update

echo
echo "[*] Installing MinGW (for Windows cross-compilation)..."
if command_exists x86_64-w64-mingw32-gcc; then
    echo "    ✓ MinGW already installed"
else
    sudo apt install -y mingw-w64
    echo "    ✓ MinGW installed"
fi

echo
echo "[*] Installing Python3 and pip..."
if command_exists python3; then
    echo "    ✓ Python3 already installed ($(python3 --version))"
else
    sudo apt install -y python3 python3-pip
    echo "    ✓ Python3 installed"
fi

if command_exists pip3; then
    echo "    ✓ pip3 already installed"
else
    sudo apt install -y python3-pip
    echo "    ✓ pip3 installed"
fi

echo
echo "[*] Installing Volatility3..."
if command_exists volatility3 || command_exists vol3; then
    echo "    ✓ Volatility3 already installed"
else
    echo "    Installing via pip3..."
    pip3 install volatility3
    
    # Add to PATH if not already there
    if ! grep -q ".local/bin" ~/.bashrc; then
        echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
        export PATH=$PATH:~/.local/bin
    fi
    
    echo "    ✓ Volatility3 installed"
fi

echo
echo "[*] Installing additional utilities..."

# strings (from binutils)
if command_exists strings; then
    echo "    ✓ strings already installed"
else
    sudo apt install -y binutils
    echo "    ✓ strings installed"
fi

# file command
if command_exists file; then
    echo "    ✓ file command already installed"
else
    sudo apt install -y file
    echo "    ✓ file command installed"
fi

# zip/unzip
if command_exists zip; then
    echo "    ✓ zip already installed"
else
    sudo apt install -y zip unzip
    echo "    ✓ zip installed"
fi

echo
echo "============================================"
echo "Setup Complete!"
echo "============================================"
echo

# Verify installation
echo "[*] Verifying installation..."
echo

echo "MinGW:"
x86_64-w64-mingw32-gcc --version | head -1
echo

echo "Python:"
python3 --version
echo

echo "Volatility3:"
if command_exists volatility3; then
    volatility3 --version 2>/dev/null || echo "Volatility 3 Framework (installed)"
elif command_exists vol3; then
    vol3 --version 2>/dev/null || echo "Volatility 3 Framework (installed)"
else
    echo "NOTE: Volatility3 installed but may need PATH update"
    echo "Run: source ~/.bashrc"
fi
echo

echo "============================================"
echo "Ready to build the challenge!"
echo "============================================"
echo
echo "Next steps:"
echo "1. Review the challenge design in docs/author_notes.md"
echo "2. Compile the binary: ./build.sh"
echo "3. Test encryption: python3 solve/test_decrypt.py"
echo "4. Prepare Windows VM for memory dump creation"
echo
echo "For detailed instructions, see:"
echo "  - README.md (Ubuntu workflow)"
echo "  - docs/install_tools.md (tool installation details)"
echo "  - test/checklist.md (testing checklist)"
echo
