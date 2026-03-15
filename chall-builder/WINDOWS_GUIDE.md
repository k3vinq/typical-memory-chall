# Windows VM Setup Guide

## Hướng dẫn tạo Memory Dump trên Windows VM

Sau khi đã hoàn thành các bước trên Ubuntu, đây là hướng dẫn chi tiết cho phần Windows.

---

## Chuẩn bị Windows VM

### Option 1: VirtualBox (Recommended)

```bash
# Trên Ubuntu, cài VirtualBox
sudo apt update
sudo apt install virtualbox virtualbox-ext-pack

# Download Windows ISO
# Windows 10/11 evaluation: https://www.microsoft.com/en-us/evalcenter/
```

**VM Settings:**
- RAM: 4GB minimum (8GB recommended)
- Disk: 40GB
- Network: NAT or Bridged

### Option 2: VMware Workstation

```bash
# Download VMware Workstation Player (free for non-commercial)
# https://www.vmware.com/products/workstation-player.html
```

### Option 3: QEMU/KVM

```bash
sudo apt install qemu-kvm virt-manager
```

---

## Bước 1: Copy File vào Windows

### Method 1: Shared Folder (VirtualBox)

```bash
# Trên Ubuntu
VBoxManage sharedfolder add "Windows10" --name "challenge" \
  --hostpath "/home/kevin/UIT/Forensic/ez-memory/chall-builder/bin" --automount

# Trong Windows, access via:
# \\VBOXSVR\challenge\chatclient.exe
```

### Method 2: Python HTTP Server

```bash
# Trên Ubuntu
cd /home/kevin/UIT/Forensic/ez-memory/chall-builder/bin
python3 -m http.server 8000

# Trong Windows browser:
# http://[Ubuntu_IP]:8000/chatclient.exe
# Download file
```

### Method 3: USB / Direct Copy

- Copy `chatclient.exe` qua USB drive
- Hoặc drag & drop nếu Guest Additions đã cài

---

## Bước 2: Download Memory Dump Tool

### Option A: DumpIt (Easier, smaller)

1. Download từ: https://www.magnetforensics.com/resources/magnet-dumpit-for-windows/
2. Hoặc search "dumpit.exe download"
3. Copy vào Windows VM

**Usage:**
```cmd
DumpIt.exe
# Accept terms
# Chờ dump hoàn thành
# Output: memory.dmp hoặc memory.raw
```

### Option B: WinPMEM (More features)

1. Download: https://github.com/Velocidex/WinPmem/releases
2. Extract `winpmem.exe`

**Usage:**
```cmd
winpmem.exe memory.raw
```

### Option C: FTK Imager (GUI, Professional)

1. Download: https://www.exterro.com/ftk-imager
2. Install
3. File → Capture Memory
4. Choose destination

---

## Bước 3: Run chatclient.exe

```cmd
# Open Command Prompt or PowerShell
cd C:\Users\[YourName]\Downloads

# Run the program
chatclient.exe
```

**Expected output:**
```
Encrypted message sent!
[Program waits for input - DON'T press Enter yet!]
```

**Important:** Keep the program running! Don't press Enter, don't close it.

---

## Bước 4: Create Memory Dump

**While chatclient.exe is still running:**

### Using DumpIt:
```cmd
# Open NEW Command Prompt as Administrator
cd C:\Path\To\DumpIt
DumpIt.exe

# Accept EULA
# Wait for dump to complete (5-10 minutes)
```

### Using WinPMEM:
```cmd
# Open NEW Command Prompt as Administrator
winpmem.exe C:\memory.raw

# Wait for completion
```

**Output:** `memory.raw` (typically 2-8GB depending on VM RAM)

---

## Bước 5: Verify Memory Dump

```cmd
# Check file size
dir memory.raw

# Should be similar to your VM's RAM size
# Example: 4GB RAM → ~4GB dump file
```

---

## Bước 6: Transfer Dump Back to Ubuntu

### Method 1: Shared Folder

```cmd
# Copy to shared folder
copy memory.raw \\VBOXSVR\challenge\
```

### Method 2: Python HTTP Server (in Windows)

```cmd
# In Windows Command Prompt
cd C:\
python -m http.server 8000

# In Ubuntu browser:
# http://[Windows_IP]:8000/memory.raw
# Download the file
```

### Method 3: SCP/SSH

```cmd
# If SSH server running on Ubuntu
scp memory.raw user@ubuntu-ip:/home/kevin/UIT/Forensic/ez-memory/
```

### Method 4: USB / Direct Copy

- Copy to USB drive
- Mount USB in Ubuntu

---

## Troubleshooting

### Issue: "chatclient.exe not running"

**Check in Task Manager:**
```
Ctrl+Shift+Esc → Processes tab → Look for chatclient.exe
```

If not visible, the program crashed. Try:
- Run as Administrator
- Disable antivirus temporarily
- Check Event Viewer for errors

### Issue: "DumpIt requires Administrator"

**Solution:**
```
Right-click DumpIt.exe → Run as Administrator
```

### Issue: "Memory dump too large"

**Solutions:**
- Compress with 7-Zip: `7z a memory.7z memory.raw`
- Reduce VM RAM to 2GB
- Use external drive for storage

### Issue: "Program closes immediately"

**Check:**
- Console window may flash and close
- Run from Command Prompt to see output
- Verify exe is correct architecture (x64)

### Issue: "Can't transfer large file"

**Solutions:**
```bash
# Compress first (on Windows)
7z a -mx=9 memory.7z memory.raw

# Or split file
7z a -v1000m memory.7z memory.raw  # 1GB chunks

# Or use rsync on Ubuntu
rsync -avz --progress user@windows:/path/to/memory.raw ./
```

---

## Quick Commands Reference

### Windows Commands
```cmd
:: Check if program running
tasklist | findstr chatclient

:: Create memory dump
DumpIt.exe
:: or
winpmem.exe memory.raw

:: Compress dump
7z a memory.7z memory.raw

:: Check file hash
certutil -hashfile memory.raw MD5
```

### Verify from Ubuntu
```bash
# After transfer, verify integrity
md5sum memory.raw

# Check file type
file memory.raw

# Quick Volatility test
volatility3 -f memory.raw windows.info
```

---

## Expected Timeline

| Step | Time |
|------|------|
| Setup Windows VM | 30-60 min (first time) |
| Download DumpIt | 5 min |
| Copy chatclient.exe | 2 min |
| Run chatclient.exe | 1 min |
| Create memory dump | 5-10 min |
| Transfer to Ubuntu | 10-30 min (depending on method) |
| **Total** | **~1-2 hours** |

---

## Important Notes

1. **Keep chatclient.exe running** - Critical! Don't close it before dump
2. **Use Administrator privileges** - Required for memory dump tools
3. **Disable antivirus temporarily** - May block memory dump tools
4. **Enough disk space** - Need 2x RAM size (dump + temp files)
5. **Snapshot VM** - Before dump, so you can retry if needed

---

## Checklist

Before starting:
- [ ] Windows VM ready with 4GB+ RAM
- [ ] chatclient.exe copied to Windows
- [ ] DumpIt or WinPMEM downloaded
- [ ] Enough free disk space (10GB+)
- [ ] Ubuntu ready to receive dump file

During dump:
- [ ] chatclient.exe is running
- [ ] Visible in Task Manager
- [ ] Memory dump tool running as Admin
- [ ] No errors during dump

After dump:
- [ ] memory.raw file created
- [ ] File size ~= RAM size
- [ ] File hash recorded
- [ ] Successfully transferred to Ubuntu

---

## Next Steps

After successful transfer, return to Ubuntu for:

1. **Verify dump with Volatility3**
2. **Check for required artifacts**
3. **Test solve path**
4. **Create release package**

See: `UBUNTU_STATUS.md` and `test/checklist.md`

---

## Alternative: Pre-made Windows VM

If you want to save time, consider:

1. Use Windows Sandbox (Windows 10/11 Pro)
2. Use pre-configured CTF VM
3. Cloud VM (Azure, AWS Windows instance)

But custom VM gives you more control and learning experience.

---

Good luck! 🎯
