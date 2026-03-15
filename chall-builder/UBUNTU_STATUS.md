# Ubuntu-Only Workflow Summary

## Tóm tắt các bước thực hiện trên Ubuntu

Đây là tất cả những gì bạn có thể làm trên Ubuntu **trước khi** cần Windows VM.

---

## ✅ Đã hoàn thành

### 1. Cấu trúc thư mục
```
chall-builder/
├── src/          # Source code
├── bin/          # Compiled binaries
├── docs/         # Documentation
├── solve/        # Solution scripts
└── test/         # Testing files
```

### 2. Source Code (`src/chatclient.c`)
- ✓ Chương trình XOR encryption
- ✓ Key: `dev_secret_key`
- ✓ Flag: `flag{memory_leaks_are_dangerous}`
- ✓ Có `getchar()` để giữ process chạy

### 3. Solution Scripts
- ✓ `solve/test_decrypt.py` - Test logic mã hóa
- ✓ `solve/decrypt_flag.py` - Script giải challenge

### 4. Documentation
- ✓ `README.md` - Hướng dẫn Ubuntu workflow
- ✓ `docs/challenge_description.md` - Mô tả cho người chơi
- ✓ `docs/author_notes.md` - Ghi chú nội bộ
- ✓ `docs/install_tools.md` - Hướng dẫn cài tools
- ✓ `test/checklist.md` - Checklist kiểm tra

### 5. Setup Scripts
- ✓ `setup_ubuntu.sh` - Cài đặt tools tự động
- ✓ `build.sh` - Compile binary

---

## ⚠️ Cần làm tiếp

### Bước 1: Cài MinGW (Required)
```bash
sudo apt update
sudo apt install -y mingw-w64
```

### Bước 2: Compile Binary
```bash
cd /home/kevin/UIT/Forensic/ez-memory/chall-builder
./build.sh
```

Hoặc manual:
```bash
x86_64-w64-mingw32-gcc src/chatclient.c -o bin/chatclient.exe
```

### Bước 3: Verify
```bash
# Check binary
file bin/chatclient.exe

# Test encryption logic
python3 solve/test_decrypt.py

# Test solve script
python3 solve/decrypt_flag.py
```

---

## 📋 Workflow Outline

### Phase 1: Development (Ubuntu) ✅ DONE
1. ✅ Thiết kế challenge concept
2. ✅ Viết `chatclient.c`
3. ⚠️ Compile bằng MinGW (cần cài MinGW)
4. ✅ Test logic với Python
5. ✅ Viết documentation

### Phase 2: Windows VM (TODO later)
1. ⏳ Copy `bin/chatclient.exe` vào Windows VM
2. ⏳ Chạy `chatclient.exe`
3. ⏳ Tạo memory dump với DumpIt/WinPMEM
4. ⏳ Copy `memory.raw` về Ubuntu

### Phase 3: Verification (Ubuntu) - TODO later
1. ⏳ Analyze với Volatility3
2. ⏳ Verify artifacts có trong memory
3. ⏳ Test solve path
4. ⏳ Package release files

---

## 🛠️ Tools Status

### Already Available
- ✓ Python3
- ✓ Text editor (VS Code)
- ✓ bash scripts

### Needs Installation
- ⚠️ MinGW (for Windows cross-compilation)
- ⏳ Volatility3 (for memory analysis)
- ⏳ Ghidra (optional, for reverse engineering)

### Installation Commands
```bash
# Quick setup - run this:
cd /home/kevin/UIT/Forensic/ez-memory/chall-builder
./setup_ubuntu.sh

# Or manual:
sudo apt update
sudo apt install -y mingw-w64 python3-pip
pip3 install volatility3
```

---

## 📊 Progress: 90% Complete

### ✅ Completed (Ubuntu):
- Design & planning
- Source code
- Test scripts
- Documentation
- Build scripts

### ⚠️ Remaining (Ubuntu):
- Install MinGW
- Compile binary
- Verify compilation

### ⏳ Future (Windows):
- Run executable
- Create memory dump

### ⏳ Future (Back to Ubuntu):
- Analyze dump
- Verify solution
- Package release

---

## 🎯 Next Immediate Steps

```bash
# 1. Install MinGW
sudo apt install mingw-w64

# 2. Compile
cd /home/kevin/UIT/Forensic/ez-memory/chall-builder
x86_64-w64-mingw32-gcc src/chatclient.c -o bin/chatclient.exe

# 3. Verify
file bin/chatclient.exe
strings bin/chatclient.exe | grep dev_secret

# 4. Test logic
python3 solve/test_decrypt.py

# Done on Ubuntu! Ready for Windows VM.
```

---

## 📁 Files Overview

| File | Status | Purpose |
|------|--------|---------|
| `src/chatclient.c` | ✅ Ready | Windows executable source |
| `bin/chatclient.exe` | ⚠️ Needs compile | Binary for Windows |
| `solve/test_decrypt.py` | ✅ Tested | Verify XOR logic |
| `solve/decrypt_flag.py` | ✅ Ready | Solution script |
| `docs/*.md` | ✅ Complete | All documentation |
| `build.sh` | ✅ Ready | Build automation |
| `setup_ubuntu.sh` | ✅ Ready | Setup automation |

---

## ✨ Key Achievements

1. **Complete challenge design** - Concept, solve path, difficulty clear
2. **Working encryption** - XOR logic verified with tests
3. **Comprehensive documentation** - Everything documented
4. **Automation scripts** - Setup and build automated
5. **Ready for Windows phase** - Only need to run exe and dump memory

---

## 💡 Recommendations

### Do Now:
1. Install MinGW: `sudo apt install mingw-w64`
2. Run build script: `./build.sh`
3. Verify everything: Run checklist tests

### Do Later (Windows):
1. Setup Windows VM (VirtualBox/VMware)
2. Install DumpIt or WinPMEM
3. Run chatclient.exe
4. Create memory dump

### Do Last (Ubuntu):
1. Install Volatility3
2. Analyze memory dump
3. Verify solve path works
4. Create final release package

---

## 📚 Documentation Quick Links

- **Start here:** `README.md`
- **Player info:** `docs/challenge_description.md`
- **Internal notes:** `docs/author_notes.md`
- **Tool setup:** `docs/install_tools.md`
- **Testing:** `test/checklist.md`

---

## ⏱️ Time Estimate

- ✅ **Already spent:** ~2 hours (design + development)
- ⚠️ **Still on Ubuntu:** ~15 minutes (install MinGW + compile)
- ⏳ **Windows VM:** ~30 minutes (setup + dump)
- ⏳ **Final verification:** ~30 minutes (analyze + test)

**Total:** ~3 hours from start to finish

**Current progress:** 90% of Ubuntu work done!

---

Chúc bạn thành công! 🎉
