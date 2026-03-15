#!/bin/bash
# Status check script - Run without sudo needed

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         CTF Challenge - Current Status Check                   ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. CHECKING PYTHON SCRIPTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Test encryption
echo -n "Testing encryption logic... "
if python3 solve/test_decrypt.py 2>&1 | grep -q "CORRECT"; then
    echo -e "${GREEN}✓ PASS${NC}"
    PASS=$((PASS+1))
else
    echo -e "${RED}✗ FAIL${NC}"
    FAIL=$((FAIL+1))
fi

# Test solve script
echo -n "Testing solve script... "
if python3 solve/decrypt_flag.py 2>&1 | grep -q "inseclab{memory_leaks_are_dangerous}"; then
    echo -e "${GREEN}✓ PASS${NC}"
    PASS=$((PASS+1))
else
    echo -e "${RED}✗ FAIL${NC}"
    FAIL=$((FAIL+1))
fi

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2. CHECKING SOURCE CODE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check source exists
echo -n "Source code exists... "
if [ -f "src/chatclient.c" ]; then
    echo -e "${GREEN}✓ PASS${NC}"
    PASS=$((PASS+1))
else
    echo -e "${RED}✗ FAIL${NC}"
    FAIL=$((FAIL+1))
fi

# Check key in source
echo -n "Key in source code... "
if grep -q "dev_secret_key" src/chatclient.c; then
    echo -e "${GREEN}✓ PASS${NC}"
    PASS=$((PASS+1))
else
    echo -e "${RED}✗ FAIL${NC}"
    FAIL=$((FAIL+1))
fi

# Check flag in source
echo -n "Flag in source code... "
if grep -q "inseclab{memory_leaks_are_dangerous}" src/chatclient.c; then
    echo -e "${GREEN}✓ PASS${NC}"
    PASS=$((PASS+1))
else
    echo -e "${RED}✗ FAIL${NC}"
    FAIL=$((FAIL+1))
fi

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3. CHECKING TOOLS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Python
echo -n "Python 3... "
if command -v python3 &> /dev/null; then
    VERSION=$(python3 --version 2>&1)
    echo -e "${GREEN}✓ PASS${NC} ($VERSION)"
    PASS=$((PASS+1))
else
    echo -e "${RED}✗ FAIL${NC}"
    FAIL=$((FAIL+1))
fi

# MinGW
echo -n "MinGW compiler... "
if command -v x86_64-w64-mingw32-gcc &> /dev/null; then
    VERSION=$(x86_64-w64-mingw32-gcc --version | head -1)
    echo -e "${GREEN}✓ PASS${NC} ($VERSION)"
    PASS=$((PASS+1))
else
    echo -e "${RED}✗ FAIL${NC} - NOT INSTALLED"
    FAIL=$((FAIL+1))
fi

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4. CHECKING BINARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Binary exists
echo -n "Binary exists... "
if [ -f "bin/chatclient.exe" ]; then
    echo -e "${GREEN}✓ PASS${NC}"
    PASS=$((PASS+1))
    
    # Check binary type
    echo -n "Binary is PE executable... "
    if file bin/chatclient.exe | grep -q "PE32"; then
        echo -e "${GREEN}✓ PASS${NC}"
        PASS=$((PASS+1))
    else
        echo -e "${RED}✗ FAIL${NC}"
        FAIL=$((FAIL+1))
    fi
    
    # Check strings
    echo -n "Key in binary... "
    if strings bin/chatclient.exe | grep -q "dev_secret_key"; then
        echo -e "${GREEN}✓ PASS${NC}"
        PASS=$((PASS+1))
    else
        echo -e "${YELLOW}⚠ WARN${NC} - Key not found (may be stripped)"
        WARN=$((WARN+1))
    fi
else
    echo -e "${RED}✗ FAIL${NC} - NOT COMPILED YET"
    FAIL=$((FAIL+1))
    echo -e "${YELLOW}⚠ Binary not compiled${NC}"
    echo -e "${YELLOW}⚠ Key check skipped${NC}"
    WARN=$((WARN+2))
fi

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5. CHECKING DOCUMENTATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

DOCS=("INDEX.md" "QUICKSTART.md" "README.md" "START_HERE.txt" "docs/author_notes.md")
for doc in "${DOCS[@]}"; do
    echo -n "Checking $doc... "
    if [ -f "$doc" ]; then
        echo -e "${GREEN}✓ PASS${NC}"
        PASS=$((PASS+1))
    else
        echo -e "${RED}✗ FAIL${NC}"
        FAIL=$((FAIL+1))
    fi
done

echo
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                        SUMMARY                                 ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo
echo -e "  ${GREEN}✓ PASSED:${NC}  $PASS"
echo -e "  ${RED}✗ FAILED:${NC}  $FAIL"
echo -e "  ${YELLOW}⚠ WARNINGS:${NC} $WARN"
echo

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                  ✓ ALL TESTS PASSED!                           ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo "Ubuntu phase is COMPLETE! ✅"
    echo
    echo "Next: Setup Windows VM (see WINDOWS_GUIDE.md)"
    exit 0
elif [ $FAIL -eq 1 ] && command -v x86_64-w64-mingw32-gcc &> /dev/null; then
    # Only binary missing but compiler exists
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║              ⚠ ALMOST COMPLETE - NEEDS BUILD                   ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo "Run: ./build.sh"
    exit 1
else
    echo -e "${RED}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                    ✗ INCOMPLETE                                ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo
    if ! command -v x86_64-w64-mingw32-gcc &> /dev/null; then
        echo "❌ MinGW not installed!"
        echo
        echo "Install with:"
        echo "  sudo apt update"
        echo "  sudo apt install -y mingw-w64"
        echo
    fi
    if [ ! -f "bin/chatclient.exe" ]; then
        echo "❌ Binary not compiled!"
        echo
        echo "After installing MinGW, run:"
        echo "  ./build.sh"
        echo
    fi
    exit 1
fi
