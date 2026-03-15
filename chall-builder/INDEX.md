# 📚 Challenge Documentation Index

## 🎯 Start Here

Bạn muốn làm gì?

### 1️⃣ Mới bắt đầu - Chưa có gì
→ Đọc: **[QUICKSTART.md](QUICKSTART.md)**
   - Setup nhanh 5 phút
   - Compile và test
   - Tất cả trên Ubuntu

### 2️⃣ Đã có binary - Cần tạo memory dump
→ Đọc: **[WINDOWS_GUIDE.md](WINDOWS_GUIDE.md)**
   - Setup Windows VM
   - Run chatclient.exe
   - Create memory dump
   - Transfer về Ubuntu

### 3️⃣ Đã có memory dump - Cần verify
→ Đọc: **[test/checklist.md](test/checklist.md)**
   - Checklist đầy đủ
   - Verify với Volatility3
   - Test solve path

### 4️⃣ Muốn hiểu thiết kế challenge
→ Đọc: **[docs/author_notes.md](docs/author_notes.md)**
   - Challenge concept
   - Intended solution
   - Difficulty tuning

### 5️⃣ Cần cài tools phân tích
→ Đọc: **[docs/install_tools.md](docs/install_tools.md)**
   - Volatility3
   - Ghidra
   - MinGW
   - Python tools

---

## 📋 File Organization

```
chall-builder/
│
├── 🚀 QUICKSTART.md              ← BẮT ĐẦU TẠI ĐÂY
├── 📊 UBUNTU_STATUS.md           ← Trạng thái & tiến độ
├── 🪟 WINDOWS_GUIDE.md           ← Hướng dẫn phần Windows
├── 📖 README.md                  ← Workflow Ubuntu đầy đủ
├── 🔍 INDEX.md                   ← File này (navigation)
│
├── 🛠️ Scripts
│   ├── setup_ubuntu.sh           ← Cài đặt tools tự động
│   ├── build.sh                  ← Compile binary
│   └── verify.sh                 ← Kiểm tra mọi thứ
│
├── 📁 src/
│   └── chatclient.c              ← Source code
│
├── 📦 bin/
│   └── chatclient.exe            ← Binary (sau khi compile)
│
├── 🧪 solve/
│   ├── test_decrypt.py           ← Test thuật toán
│   └── decrypt_flag.py           ← Solve script
│
├── 📚 docs/
│   ├── description.txt           ← Cho player (plaintext)
│   ├── challenge_description.md  ← Cho player (markdown)
│   ├── author_notes.md           ← Ghi chú thiết kế
│   └── install_tools.md          ← Hướng dẫn cài tools
│
└── ✅ test/
    └── checklist.md              ← Testing checklist
```

---

## ⚡ Quick Commands

### Verification
```bash
./verify.sh                      # Kiểm tra mọi thứ
```

### Build
```bash
./setup_ubuntu.sh                # Cài tools (lần đầu)
./build.sh                       # Compile binary
```

### Test
```bash
python3 solve/test_decrypt.py    # Test XOR logic
python3 solve/decrypt_flag.py    # Test solve script
file bin/chatclient.exe          # Check binary type
strings bin/chatclient.exe       # Check strings
```

---

## 🎓 Learning Path

### Phase 1: Ubuntu Development (2 giờ)
1. Read: `QUICKSTART.md`
2. Run: `./setup_ubuntu.sh`
3. Run: `./build.sh`
4. Run: `python3 solve/test_decrypt.py`
5. Run: `./verify.sh`

**✅ Result:** Binary ready, logic tested, docs complete

### Phase 2: Windows VM (1 giờ)
1. Read: `WINDOWS_GUIDE.md`
2. Setup Windows VM
3. Copy `bin/chatclient.exe` to Windows
4. Run chatclient.exe
5. Create memory dump
6. Transfer memory.raw back

**✅ Result:** Memory dump created

### Phase 3: Analysis & Release (1 giờ)
1. Read: `test/checklist.md`
2. Analyze with Volatility3
3. Verify artifacts exist
4. Test solve path
5. Package release files

**✅ Result:** Challenge ready for distribution

---

## 📖 Documentation by Audience

### For Challenge Author (You)
- **[docs/author_notes.md](docs/author_notes.md)** - Design decisions
- **[test/checklist.md](test/checklist.md)** - Testing guide
- **[UBUNTU_STATUS.md](UBUNTU_STATUS.md)** - Current status

### For Challenge Players
- **[docs/description.txt](docs/description.txt)** - Challenge description
- (They only get `description.txt` and `memory.raw`)

### For Challenge Testers
- **[docs/challenge_description.md](docs/challenge_description.md)** - Full description
- **[docs/author_notes.md](docs/author_notes.md)** - Expected solution

---

## 🔧 Technical Details

### Challenge Specifications
- **Name:** Chat Application Leak
- **Category:** Memory Forensics
- **Difficulty:** Easy-Medium
- **Flag:** `flag{memory_leaks_are_dangerous}`
- **Key:** `dev_secret_key`
- **Algorithm:** XOR encryption

### Files for Distribution
```
release/
└── chat-application-leak/
    ├── memory.raw          # Memory dump
    └── description.txt     # Challenge description
```

### Tools Required (Ubuntu)
- MinGW (cross-compile)
- Python 3
- Volatility3 (analysis)
- Ghidra (optional RE)

### Tools Required (Windows)
- DumpIt or WinPMEM (memory dump)

---

## 🐛 Troubleshooting

### "MinGW not found"
```bash
sudo apt install mingw-w64
```

### "Binary won't compile"
```bash
./build.sh
# Or manual:
x86_64-w64-mingw32-gcc src/chatclient.c -o bin/chatclient.exe
```

### "Test scripts fail"
```bash
python3 --version  # Should be 3.6+
python3 solve/test_decrypt.py
```

### "Can't find volatility3"
```bash
pip3 install volatility3
export PATH=$PATH:~/.local/bin
```

---

## 📞 Quick Reference

| Task | Command |
|------|---------|
| Setup everything | `./setup_ubuntu.sh` |
| Compile binary | `./build.sh` |
| Test encryption | `python3 solve/test_decrypt.py` |
| Test solution | `python3 solve/decrypt_flag.py` |
| Verify all | `./verify.sh` |
| Check binary | `file bin/chatclient.exe` |
| List processes (Volatility) | `volatility3 -f memory.raw windows.pslist` |

---

## 🎯 Current Status

Run `./verify.sh` to check current status.

**Expected output if everything ready:**
```
✅ ALL CHECKS PASSED!
Ubuntu phase complete. Ready for Windows VM.
```

---

## 📅 Timeline

| Phase | Time | Status |
|-------|------|--------|
| Design & Planning | 30 min | ✅ Done |
| Ubuntu Development | 2 hours | ✅ Done |
| Windows Memory Dump | 1 hour | ⏳ TODO |
| Analysis & Verification | 1 hour | ⏳ TODO |
| **Total** | **~4-5 hours** | **50% Complete** |

---

## 💡 Tips

1. **Start with verification**
   ```bash
   ./verify.sh
   ```

2. **Read in order**
   - QUICKSTART.md (5 min)
   - README.md (10 min)
   - WINDOWS_GUIDE.md (when ready for VM)

3. **Use the scripts**
   - Don't do manual setup
   - Scripts handle everything

4. **Check documentation**
   - Everything is documented
   - If confused, check INDEX.md (this file)

---

## 🎉 Success Criteria

### Ubuntu Phase Complete When:
- ✅ Binary compiles successfully
- ✅ Test scripts pass
- ✅ `./verify.sh` shows no errors
- ✅ Documentation reviewed

### Windows Phase Complete When:
- ✅ Memory dump created
- ✅ chatclient.exe was running during dump
- ✅ File transferred to Ubuntu

### Challenge Complete When:
- ✅ Volatility finds chatclient.exe process
- ✅ Key found in memory
- ✅ Can solve following intended path
- ✅ Flag recovered correctly

---

**Current Location:** You are here → Ubuntu Development Phase

**Next Step:** Run `./verify.sh` to check status

**Need Help?** Read the appropriate guide above ☝️

---

Good luck! 🚀
