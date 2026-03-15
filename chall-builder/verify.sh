#!/bin/bash
# Final verification script - check everything is ready

echo "=========================================="
echo "CTF Memory Forensics Challenge"
echo "Final Verification"
echo "=========================================="
echo

SUCCESS=0
WARNINGS=0
ERRORS=0

# Function to check file
check_file() {
    if [ -f "$1" ]; then
        echo "  ✓ $1"
        SUCCESS=$((SUCCESS + 1))
    else
        echo "  ✗ $1 (MISSING)"
        ERRORS=$((ERRORS + 1))
    fi
}

# Function to check command
check_command() {
    if command -v "$1" &> /dev/null; then
        echo "  ✓ $1 ($($1 --version 2>&1 | head -1))"
        SUCCESS=$((SUCCESS + 1))
    else
        echo "  ✗ $1 (NOT INSTALLED)"
        ERRORS=$((ERRORS + 1))
    fi
}

# Check source files
echo "[*] Checking source files..."
check_file "src/chatclient.c"
echo

# Check binary
echo "[*] Checking compiled binary..."
if [ -f "bin/chatclient.exe" ]; then
    FILE_TYPE=$(file bin/chatclient.exe)
    if echo "$FILE_TYPE" | grep -q "PE32"; then
        echo "  ✓ bin/chatclient.exe (Valid Windows PE)"
        SUCCESS=$((SUCCESS + 1))
    else
        echo "  ⚠ bin/chatclient.exe (Invalid format)"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo "  ✗ bin/chatclient.exe (NOT COMPILED)"
    echo "    Run: ./build.sh"
    ERRORS=$((ERRORS + 1))
fi
echo

# Check solve scripts
echo "[*] Checking solve scripts..."
check_file "solve/test_decrypt.py"
check_file "solve/decrypt_flag.py"
echo

# Check documentation
echo "[*] Checking documentation..."
check_file "docs/challenge_description.md"
check_file "docs/author_notes.md"
check_file "docs/description.txt"
check_file "docs/install_tools.md"
check_file "test/checklist.md"
check_file "README.md"
echo

# Check scripts
echo "[*] Checking build scripts..."
check_file "build.sh"
check_file "setup_ubuntu.sh"
echo

# Check tools
echo "[*] Checking required tools..."
check_command "python3"
check_command "x86_64-w64-mingw32-gcc"
echo

# Check optional tools
echo "[*] Checking optional analysis tools..."
if command -v volatility3 &> /dev/null; then
    echo "  ✓ volatility3 (installed)"
    SUCCESS=$((SUCCESS + 1))
else
    echo "  ⚠ volatility3 (not installed - needed for analysis phase)"
    WARNINGS=$((WARNINGS + 1))
fi
echo

# Test Python scripts
echo "[*] Testing Python scripts..."
if python3 solve/test_decrypt.py 2>&1 | grep -q "CORRECT"; then
    echo "  ✓ test_decrypt.py works correctly"
    SUCCESS=$((SUCCESS + 1))
else
    echo "  ✗ test_decrypt.py failed"
    ERRORS=$((ERRORS + 1))
fi

if python3 solve/decrypt_flag.py 2>&1 | grep -q "flag{memory_leaks_are_dangerous}"; then
    echo "  ✓ decrypt_flag.py works correctly"
    SUCCESS=$((SUCCESS + 1))
else
    echo "  ✗ decrypt_flag.py failed"
    ERRORS=$((ERRORS + 1))
fi
echo

# Check strings in binary
if [ -f "bin/chatclient.exe" ]; then
    echo "[*] Checking binary contents..."
    if strings bin/chatclient.exe | grep -q "dev_secret_key"; then
        echo "  ✓ Encryption key found in binary"
        SUCCESS=$((SUCCESS + 1))
    else
        echo "  ⚠ Encryption key not found (may be stripped)"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    if strings bin/chatclient.exe | grep -q "Encrypted message sent"; then
        echo "  ✓ Program strings found in binary"
        SUCCESS=$((SUCCESS + 1))
    else
        echo "  ⚠ Program strings not found"
        WARNINGS=$((WARNINGS + 1))
    fi
    echo
fi

# Summary
echo "=========================================="
echo "Verification Summary"
echo "=========================================="
echo "  ✓ Success: $SUCCESS"
echo "  ⚠ Warnings: $WARNINGS"
echo "  ✗ Errors: $ERRORS"
echo

if [ $ERRORS -eq 0 ]; then
    echo "✅ ALL CHECKS PASSED!"
    echo
    echo "Ubuntu phase complete. Ready for Windows VM."
    echo
    echo "Next steps:"
    echo "1. Setup Windows VM (see WINDOWS_GUIDE.md)"
    echo "2. Copy bin/chatclient.exe to Windows"
    echo "3. Run chatclient.exe"
    echo "4. Create memory dump with DumpIt"
    echo "5. Transfer memory.raw back to Ubuntu"
    echo "6. Analyze with Volatility3"
    echo "7. Package final release"
    echo
    exit 0
elif [ $ERRORS -le 2 ] && [ $WARNINGS -gt 0 ]; then
    echo "⚠️  CHECKS PASSED WITH WARNINGS"
    echo
    echo "Some optional components missing but core challenge is ready."
    echo
    exit 0
else
    echo "❌ VERIFICATION FAILED"
    echo
    echo "Please fix the errors above before proceeding."
    echo
    exit 1
fi
