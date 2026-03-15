# CTF Memory Forensics Challenge - ez-memory

## 🎯 Quick Start

```bash
cd chall-builder
./setup_ubuntu.sh    # Install tools
./build.sh           # Compile binary  
./verify.sh          # Verify everything
```

---

## 📂 Project Structure

```
ez-memory/
├── chall-builder/           ← MAIN FOLDER (Work here)
│   ├── INDEX.md            ← START HERE (navigation)
│   ├── QUICKSTART.md       ← 5-minute quick start
│   ├── PROJECT_SUMMARY.md  ← Complete summary
│   ├── README.md           ← Full Ubuntu workflow
│   ├── UBUNTU_STATUS.md    ← Current status
│   └── WINDOWS_GUIDE.md    ← Windows VM guide
│
└── description.md          ← Original challenge concept
```

---

## 🚀 What to Do

### Step 1: Navigate to Work Directory
```bash
cd chall-builder
```

### Step 2: Read the Navigation Guide
```bash
cat INDEX.md
```

### Step 3: Follow Quick Start
```bash
cat QUICKSTART.md
```

Or just run:
```bash
./verify.sh
```

---

## 📚 Documentation

Everything is documented in `chall-builder/`:

- **INDEX.md** - Complete navigation guide
- **QUICKSTART.md** - Get started in 5 minutes
- **PROJECT_SUMMARY.md** - What's been completed
- **README.md** - Full Ubuntu workflow
- **WINDOWS_GUIDE.md** - Windows VM instructions

---

## ✅ Current Status

**Ubuntu Phase: 95% Complete**

What's done:
- ✅ Source code written
- ✅ Test scripts created
- ✅ Documentation complete
- ✅ Build scripts ready

What's needed:
- ⚠️ Install MinGW: `sudo apt install mingw-w64`
- ⚠️ Compile binary: `./build.sh`
- ⏳ Windows VM setup (see WINDOWS_GUIDE.md)

---

## 🎓 Challenge Info

- **Name:** Chat Application Leak
- **Category:** Memory Forensics
- **Difficulty:** Easy-Medium
- **Flag:** `flag{memory_leaks_are_dangerous}`

---

## 💡 Quick Commands

```bash
# Everything happens in chall-builder/
cd chall-builder

# Install tools
./setup_ubuntu.sh

# Compile Windows binary
./build.sh

# Test encryption logic
python3 solve/test_decrypt.py

# Verify everything
./verify.sh
```

---

## 📖 Read First

Go to `chall-builder/` and read:
1. **INDEX.md** - Navigation (start here)
2. **QUICKSTART.md** - Quick start guide
3. **PROJECT_SUMMARY.md** - What's completed

---

**All work is in `chall-builder/` directory. Start there!**

```bash
cd chall-builder && cat INDEX.md
```
