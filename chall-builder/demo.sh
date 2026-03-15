#!/bin/bash
# Demo script - Shows what has been created
# This is a read-only demo, won't modify anything

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║     CTF Memory Forensics Challenge - Project Demo             ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}[*] Project Structure:${NC}"
echo
cat STRUCTURE.txt | head -25
echo

echo -e "${BLUE}[*] Checking files...${NC}"
echo

# Count files
TOTAL_FILES=$(find . -type f | wc -l)
MD_FILES=$(find . -name "*.md" | wc -l)
SH_FILES=$(find . -name "*.sh" | wc -l)
PY_FILES=$(find . -name "*.py" | wc -l)
C_FILES=$(find . -name "*.c" | wc -l)

echo "  Total files created: $TOTAL_FILES"
echo "  Markdown docs: $MD_FILES"
echo "  Shell scripts: $SH_FILES"
echo "  Python scripts: $PY_FILES"
echo "  C source files: $C_FILES"
echo

# Show source code
echo -e "${BLUE}[*] Source Code Preview:${NC}"
echo
echo "File: src/chatclient.c"
echo "─────────────────────────────────────────"
head -15 src/chatclient.c
echo "... (see full file for complete code)"
echo

# Show test script in action
echo -e "${BLUE}[*] Testing Encryption Logic:${NC}"
echo
python3 solve/test_decrypt.py 2>&1
echo

# Check tools
echo -e "${BLUE}[*] Required Tools Status:${NC}"
echo

# Python
if command -v python3 &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Python3: $(python3 --version)"
else
    echo -e "  ${YELLOW}⚠${NC} Python3: Not found"
fi

# MinGW
if command -v x86_64-w64-mingw32-gcc &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} MinGW: $(x86_64-w64-mingw32-gcc --version | head -1)"
else
    echo -e "  ${YELLOW}⚠${NC} MinGW: Not installed (run: sudo apt install mingw-w64)"
fi

# Volatility
if command -v volatility3 &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Volatility3: Installed"
elif command -v vol3 &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Volatility3: Installed (as vol3)"
else
    echo -e "  ${YELLOW}⚠${NC} Volatility3: Not installed (run: pip3 install volatility3)"
fi

echo

# Show what binary will look like
echo -e "${BLUE}[*] Binary Status:${NC}"
echo
if [ -f "bin/chatclient.exe" ]; then
    echo -e "  ${GREEN}✓${NC} bin/chatclient.exe exists"
    file bin/chatclient.exe
    SIZE=$(du -h bin/chatclient.exe | cut -f1)
    echo "  Size: $SIZE"
    echo
    echo "  Strings in binary:"
    strings bin/chatclient.exe | grep -E "(dev_secret|Encrypted)" | head -5
else
    echo -e "  ${YELLOW}⚠${NC} bin/chatclient.exe not yet compiled"
    echo "  Run: ./build.sh"
fi

echo

# Show documentation
echo -e "${BLUE}[*] Documentation Available:${NC}"
echo
echo "  📖 Main Guides:"
echo "     - INDEX.md (navigation)"
echo "     - QUICKSTART.md (5-min start)"
echo "     - README.md (full workflow)"
echo "     - PROJECT_SUMMARY.md (what's done)"
echo
echo "  📚 Detailed Docs:"
echo "     - UBUNTU_STATUS.md (Ubuntu progress)"
echo "     - WINDOWS_GUIDE.md (Windows setup)"
echo "     - docs/author_notes.md (design doc)"
echo "     - docs/install_tools.md (tools setup)"
echo "     - test/checklist.md (testing)"
echo

# Next steps
echo -e "${BLUE}[*] Next Steps:${NC}"
echo
if [ -f "bin/chatclient.exe" ]; then
    echo "  ✅ Binary compiled - Ready for Windows VM!"
    echo
    echo "  1. Setup Windows VM (see WINDOWS_GUIDE.md)"
    echo "  2. Copy bin/chatclient.exe to Windows"
    echo "  3. Run chatclient.exe"
    echo "  4. Create memory dump"
    echo "  5. Analyze with Volatility3"
else
    echo "  📋 Todo:"
    echo
    if ! command -v x86_64-w64-mingw32-gcc &> /dev/null; then
        echo "  1. Install MinGW:"
        echo "     sudo apt install mingw-w64"
        echo
    fi
    echo "  2. Compile binary:"
    echo "     ./build.sh"
    echo
    echo "  3. Verify everything:"
    echo "     ./verify.sh"
    echo
    echo "  4. Then move to Windows phase"
fi

echo
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    Demo Complete!                              ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo
echo "To see full verification: ./verify.sh"
echo "To read docs: cat INDEX.md"
echo
