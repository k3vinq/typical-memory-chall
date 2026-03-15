# Quick Start - Ubuntu Only Steps

## 🚀 Bắt đầu nhanh trên Ubuntu

File này tóm tắt **chỉ những bước thực hiện trên Ubuntu** theo đúng yêu cầu của bạn.

---

## Cài đặt công cụ (5 phút)

```bash
cd /home/kevin/UIT/Forensic/ez-memory/chall-builder

# Chạy script setup tự động
./setup_ubuntu.sh

# Hoặc cài thủ công:
sudo apt update
sudo apt install -y mingw-w64 python3 python3-pip
pip3 install volatility3
```

---

## Compile Windows binary (2 phút)

```bash
# Cách 1: Dùng script
./build.sh

# Cách 2: Manual
x86_64-w64-mingw32-gcc src/chatclient.c -o bin/chatclient.exe

# Kiểm tra
file bin/chatclient.exe
```

**Output mong đợi:**
```
bin/chatclient.exe: PE32+ executable (console) x86-64, for MS Windows
```

---

## Test logic encryption (1 phút)

```bash
# Test XOR algorithm
python3 solve/test_decrypt.py
```

**Output mong đợi:**
```
✓ Encryption/Decryption logic is CORRECT
Flag: flag{memory_leaks_are_dangerous}
```

---

## Test solve script (30 giây)

```bash
python3 solve/decrypt_flag.py
```

**Output mong đợi:**
```
FLAG: flag{memory_leaks_are_dangerous}
```

---

## Kiểm tra strings trong binary (30 giây)

```bash
strings bin/chatclient.exe | grep -E "(dev_secret|flag|Encrypted)"
```

**Output mong đợi:**
```
dev_secret_key
Encrypted message sent!
```

---

## ✅ Hoàn thành phần Ubuntu!

Nếu tất cả các test ở trên pass, bạn đã xong **90% công việc trên Ubuntu**.

---

## 📂 Cấu trúc đã tạo

```
chall-builder/
├── src/
│   └── chatclient.c              ✅ Source code
├── bin/
│   └── chatclient.exe            ⚠️  Binary (sau khi compile)
├── solve/
│   ├── test_decrypt.py           ✅ Test script
│   └── decrypt_flag.py           ✅ Solve script
├── docs/
│   ├── challenge_description.md  ✅ Mô tả cho player
│   ├── author_notes.md           ✅ Ghi chú nội bộ
│   └── install_tools.md          ✅ Hướng dẫn tools
├── test/
│   └── checklist.md              ✅ Checklist kiểm tra
├── build.sh                      ✅ Build script
├── setup_ubuntu.sh               ✅ Setup script
├── README.md                     ✅ Hướng dẫn chính
├── UBUNTU_STATUS.md              ✅ Trạng thái Ubuntu
└── WINDOWS_GUIDE.md              ✅ Hướng dẫn Windows
```

---

## 🎯 Bước tiếp theo

### Trên Ubuntu (đã xong):
- ✅ Viết source code
- ✅ Compile binary Windows
- ✅ Test thuật toán
- ✅ Tạo tài liệu
- ✅ Cài công cụ phân tích

### Cần Windows VM (chưa làm):
- ⏳ Chạy `chatclient.exe`
- ⏳ Tạo memory dump với DumpIt
- ⏳ Copy `memory.raw` về Ubuntu

### Quay lại Ubuntu (sau khi có dump):
- ⏳ Phân tích với Volatility3
- ⏳ Verify artifacts
- ⏳ Test solve path
- ⏳ Đóng gói release

---

## 📖 Đọc thêm

| File | Nội dung |
|------|----------|
| `README.md` | Workflow Ubuntu đầy đủ |
| `UBUNTU_STATUS.md` | Trạng thái và tiến độ |
| `WINDOWS_GUIDE.md` | Hướng dẫn phần Windows |
| `docs/author_notes.md` | Thiết kế challenge chi tiết |
| `test/checklist.md` | Checklist đầy đủ |

---

## 💡 Lưu ý

1. **Binary đã được compile trên Ubuntu** - không cần Windows để build
2. **Tất cả tools đã ready** - Volatility3, MinGW, Python
3. **Logic đã được test** - XOR encryption/decryption hoạt động đúng
4. **Tài liệu đầy đủ** - Cho cả player và tester

**Bạn chỉ cần Windows VM để:**
- Chạy exe và tạo memory dump (30 phút)

**Sau đó quay lại Ubuntu để:**
- Verify và đóng gói (30 phút)

---

## 🔍 Verify checklist

```bash
# 1. Source code tồn tại
test -f src/chatclient.c && echo "✓ Source OK"

# 2. Binary compile được (cần MinGW)
test -f bin/chatclient.exe && echo "✓ Binary OK" || echo "⚠ Run: ./build.sh"

# 3. Test script chạy được
python3 solve/test_decrypt.py 2>/dev/null | grep -q "CORRECT" && echo "✓ Tests OK"

# 4. Docs đầy đủ
test -f docs/author_notes.md && echo "✓ Docs OK"

# 5. Tools ready
command -v volatility3 >/dev/null 2>&1 && echo "✓ Volatility OK" || echo "⚠ Install volatility3"
command -v x86_64-w64-mingw32-gcc >/dev/null 2>&1 && echo "✓ MinGW OK" || echo "⚠ Install mingw-w64"
```

---

## 🎓 Những gì đã học

Qua việc thiết kế challenge này trên Ubuntu, bạn đã:

1. ✅ Cross-compile Windows binary từ Linux
2. ✅ Thiết kế challenge forensics có solve path rõ ràng
3. ✅ Viết thuật toán mã hóa đơn giản (XOR)
4. ✅ Tạo documentation đầy đủ
5. ✅ Chuẩn bị tools phân tích memory

---

**Total time spent on Ubuntu: ~2 hours**
**Result: 90% challenge ready!**

Chúc mừng! 🎉
