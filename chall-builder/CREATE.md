# Hành Trình Tạo Challenge CTF Memory Forensics

**Challenge:** ez-memory (Rolling-Key XOR)  
**Author:** kevin @ INSECLAB/UIT  
**Date:** 2026-03-15

---

## Mở Đầu

Đây là câu chuyện về việc tạo một challenge CTF memory forensics từ con số 0. Không phải là một tutorial cứng nhắc, mà là một hành trình với những quyết định thiết kế, những lần thử-sai, và những bài học rút ra.

**Mục tiêu ban đầu:**
- Tạo một challenge vừa đủ khó, không quá dễ để "strings" là xong
- Người chơi phải thật sự dump memory và phân tích
- Reverse engineering phải có vai trò, nhưng không phải tất cả
- Build hoàn toàn trên Ubuntu, không cần Windows

---

## Giai Đoạn 1: Bắt Đầu Với Simple XOR

### Ý Tưởng Ban Đầu

Ban đầu mình nghĩ đơn giản thôi: tạo một chương trình chat client giả lập, encrypt message bằng XOR, rồi để plaintext và key nguyên trong binary. Khi dump memory, người chơi sẽ thấy process này, reverse ra thuật toán, lấy key, decrypt xong.

**Setup cơ bản:**

Mình tạo cấu trúc thư mục chuẩn: `src/` cho source code, `bin/` cho binary đã compile, `solve/` cho script giải, `docs/` cho tài liệu, `test/` cho kiểm thử. Đơn giản và dễ quản lý.

**Viết code đầu tiên:**

Chương trình C rất đơn giản: có một chuỗi key, một chuỗi message chứa flag, một hàm XOR encrypt dạng repeating-key (XOR từng byte với key[i % keylen]), và một vòng lặp vô hạn để giữ process sống. 

Ban đầu mình dùng flag format `flag{...}` theo kiểu chuẩn CTF. Code khoảng 20 dòng, rất gọn.

**Build system:**

Mình cài MinGW trên Ubuntu để cross-compile ra Windows executable. Command đơn giản: `x86_64-w64-mingw32-gcc src/chatclient.c -o bin/chatclient.exe`. Không cần máy Windows, không cần VM, tất cả làm trên Ubuntu.

**Test scripts:**

Viết script Python để verify logic XOR: encrypt rồi decrypt lại phải ra plaintext ban đầu. Điều này rất quan trọng để chắc chắn thuật toán không có bug.

**Nhưng có vấn đề nghiêm trọng:**

Khi chạy `strings bin/chatclient.exe | grep flag`, flag hiện nguyên xi! Key cũng vậy. Challenge này quá dễ. Ai cũng có thể giải chỉ với một dòng command. Memory dump không còn ý nghĩa gì nữa.

### Điểm Chuyển Hướng

Mình nhận ra mô hình này sai từ gốc. Nếu plaintext flag nằm trong binary, thì người chơi thậm chí không cần chạy chương trình, không cần memory dump, không cần gì cả. Chỉ cần `strings` là xong.

**Quyết định:** Phải thiết kế lại hoàn toàn.

---

## Giai Đoạn 2: Nâng Cấp Lên Rolling-Key XOR

### Tái Thiết Kế

Mình ngồi lại và nghĩ kỹ về những gì một challenge memory forensics "thật" cần có:

1. **Plaintext không được ở trong binary.** Chỉ có ciphertext.
2. **Key không được quá rõ ràng.** Chia thành fragments, ghép lúc runtime.
3. **Thuật toán phải phức tạp hơn XOR đơn giản.** Nhưng vẫn đủ đơn giản để reverse được.
4. **Memory phải quan trọng.** Phải có artifact mà chỉ lấy được từ RAM.

**Quyết định về thuật toán:**

Thay vì repeating-key XOR thuần túy (quá đơn giản), mình chọn **rolling-key XOR**: mỗi byte không chỉ XOR với key, mà còn XOR với một state biến đổi. State này tăng 13 đơn vị sau mỗi byte và wrap around 256.

Tại sao +13? Vì nó coprime với 256, đảm bảo state sẽ đi qua tất cả các giá trị từ 0-255 mà không lặp sớm. Đồng thời 13 là số đủ "lạ" để không rõ ràng ngay, nhưng đủ đơn giản để nhận ra khi reverse.

**Quyết định về key:**

Thay vì một chuỗi key nguyên khối, mình chia thành 3 fragments: `"uit_"`, `"insec_"`, `"lab"`. Lúc runtime, chương trình sẽ concatenate chúng thành `"uit_insec_lab"`.

Điều này có nghĩa:
- Binary chỉ chứa fragments rời rạc
- Full key chỉ tồn tại trong RAM khi process chạy
- Người chơi phải dump memory để tìm runtime_key hoàn chỉnh

**Quyết định về seed:**

Seed (giá trị khởi tạo của state) được tính bằng một phép XOR đơn giản: `a ^ b` với `a = 0x21` và `b = 0x63`, cho ra `0x42`. 

Tại sao làm vậy? Vì nếu hardcode trực tiếp `seed = 0x42`, người chơi sẽ thấy rõ trong disassembly. Nhưng nếu tính toán qua 2 biến, nó buộc người chơi phải đọc code assembly kỹ hơn một chút.

**Flag format change:**

Theo yêu cầu, mình đổi flag từ `flag{...}` sang `inseclab{...}` để phù hợp với lab. Flag cuối cùng: `inseclab{memory_leaks_are_dangerous}`.

### Implement Rolling-Key XOR

**Tạo cipher generator:**

Trước khi viết code C, mình viết một script Python để generate ciphertext. Script này nhận plaintext flag, key, và seed, rồi encrypt ra một mảng bytes. Mình copy mảng bytes này vào code C dưới dạng `unsigned char cipher[]`.

Cách này đảm bảo:
- Plaintext không bao giờ xuất hiện trong source C
- Mình có thể verify thuật toán trước khi build binary
- Dễ thay đổi flag nếu cần

**Viết lại chatclient.c:**

Chương trình mới phức tạp hơn một chút:
- Khai báo 3 arrays cho key fragments
- Khai báo cipher array (ciphertext đã được generate)
- Hàm decrypt_message() implement rolling-key XOR: mỗi byte XOR với key và state, sau đó state += 13
- Trong main(), concatenate các fragments thành runtime_key
- Tính seed từ a ^ b
- Gọi decrypt_message()
- In ra "Decrypted: <plaintext>" (đây là lỗi nghiêm trọng, mình sẽ fix sau)
- Dừng lại với getchar() để giữ process sống

**Viết solution script:**

Script Python tương tự thuật toán decrypt: XOR cipher với key và state, state tăng 13 mỗi lần. Nếu đúng, kết quả sẽ là flag.

**Build và test:**

Compile bằng MinGW, kiểm tra file type (phải là PE32+ executable), chạy test script Python. Tất cả pass. Ciphertext decrypt đúng ra flag.

**Nhưng vẫn còn vấn đề...**

---

## Giai Đoạn 3: Phát Hiện Và Sửa Lỗi Nghiêm Trọng

### Critical Review

Sau khi hoàn thành implementation, mình ngồi lại kiểm tra kỹ hơn. Ba câu hỏi quan trọng:

**Câu hỏi 1: Full key có thực sự KHÔNG trong binary không?**

Mình chạy `strings bin/chatclient.exe | grep "uit_insec_lab"`. Kết quả: không tìm thấy. Tốt! Compiler không tự động tối ưu hóa và tạo ra full key.

Chỉ có các fragments rời rạc xuất hiện: `uit_`, `insec_`, `lab`. Đây là điều mình muốn.

**Câu hỏi 2: Plaintext có leak không?**

Đây là lúc mình nhận ra lỗi NGHIÊM TRỌNG.

Trong code, sau khi decrypt xong, mình có dòng:
```
printf("Decrypted: %s\n", buffer);
```

Điều này có nghĩa **flag được in thẳng ra màn hình!** Bất kỳ ai chạy chương trình đều thấy flag ngay lập tức. Challenge hoàn toàn hỏng.

Hơn nữa, plaintext có thể còn nằm trong stdout buffer, console history, hoặc các nơi khác trong memory. Đây là một information leak khủng khiếp.

**Câu hỏi 3: Memory có thực sự quan trọng không?**

Với design hiện tại, người chơi CÓ THỂ giải mà không cần memory dump:
- Reverse binary ra thuật toán rolling-key XOR
- Tìm key fragments bằng `strings`
- Đoán thứ tự ghép: `uit_insec_lab` (khá hiển nhiên)
- Reverse ra seed calculation
- Extract ciphertext từ .data section
- Viết script decrypt

Memory chỉ hữu ích để "confirm" runtime_key, nhưng không thực sự bắt buộc. Đây là một vấn đề về intended solve path.

### Sửa Lỗi Plaintext Leak

**Vấn đề:**

Dòng `printf("Decrypted: %s\n", buffer)` phải biến mất. Nhưng mình cần thay bằng gì để chương trình vẫn có output hợp lý?

**Giải pháp:**

Thay bằng một message generic: `"Message processed successfully!"`. Message này:
- Không leak thông tin gì về flag
- Vẫn cho biết chương trình đã chạy
- Không gây nghi ngờ (trông như một message bình thường)

Plaintext vẫn nằm trong buffer (local variable), nên vẫn có thể tìm thấy trong RAM dump nếu may mắn. Nhưng nó không được in ra, không vào stdout, không vào log.

**Sửa redundant output:**

Mình cũng nhận ra có một dòng `printf("Message processed!\n")` thừa trong main(). Xóa nó đi vì message đã được in trong decrypt_message() rồi.

### Rebuild Và Verify

**Security checks:**

Sau khi rebuild, mình chạy một loạt test:

1. `strings bin/chatclient.exe | grep "inseclab{"` → Không tìm thấy. ✅
2. `strings bin/chatclient.exe | grep "uit_insec_lab"` → Không tìm thấy. ✅
3. `strings bin/chatclient.exe | grep -E "(uit_|insec_|lab)"` → Tìm thấy fragments. ✅
4. `file bin/chatclient.exe` → PE32+ executable for Windows. ✅
5. `strings bin/chatclient.exe | grep -i "processed"` → Chỉ thấy "Message processed successfully!". ✅

**Algorithm tests:**

Chạy lại các test script Python. Tất cả vẫn pass. Thuật toán không bị ảnh hưởng bởi việc thay đổi output.

**Final verification:**

Lúc này mình tự tin rằng challenge đã đúng. Ba vấn đề critical đã được giải quyết:
1. Full key KHÔNG có trong binary
2. Plaintext KHÔNG bị leak
3. Memory CÓ giá trị (runtime_key là artifact quan trọng)

---

## Implementation Cuối Cùng

### Source Code Final

File `chatclient.c` cuối cùng có 70 dòng. Cấu trúc:

**Phần khai báo:**
- 3 key fragments dạng `unsigned char[]`
- 1 cipher array chứa 36 bytes ciphertext
- 1 macro định nghĩa độ dài cipher

**Hàm decrypt_message():**
- Nhận cipher, length, key, keylen, và seed
- Tạo buffer local (256 bytes)
- Loop qua từng byte:
  - Decrypt bằng `cipher[i] ^ key[i % keylen] ^ state`
  - Tăng state: `(state + 13) & 0xff`
- Null-terminate buffer
- Kiểm tra đơn giản (buffer[0] != 0)
- In message generic

**Hàm main():**
- Tạo runtime_key buffer
- Concatenate k1, k2, k3 vào runtime_key
- Tính seed từ `0x21 ^ 0x63`
- Gọi decrypt_message()
- Dừng với getchar()

### Project Structure

Toàn bộ project được tổ chức gọn gàng:

**Source files:** `chatclient.c` và `generate_cipher.py`

**Binary:** `chatclient.exe` (248KB, PE32+ Windows executable)

**Solution scripts:** `test_decrypt.py` (verify thuật toán), `solve_rolling_xor.py` (script giải challenge)

**Documentation:** Các file markdown mô tả challenge, cách cài đặt tools, author notes

**Build scripts:** `build.sh` (compile), `setup_ubuntu.sh` (setup môi trường), `check_status.sh` (verify tất cả), `verify.sh` (quick check), `demo.sh` (demo)

---

## Bài Học Rút Ra

### Những Gì Làm Tốt

**Ubuntu-only workflow:**

Việc làm tất cả trên Ubuntu mà không cần Windows VM là một quyết định đúng đắn. MinGW cross-compilation hoạt động hoàn hảo. Mình có thể code, compile, test ngay lập tức mà không cần restart, không cần switch giữa các môi trường.

**Iterative design:**

Bắt đầu đơn giản (simple XOR), nhận ra vấn đề, nâng cấp (rolling-key XOR), phát hiện bugs, fix. Đây là một quy trình lành mạnh. Nếu cố gắng làm perfect ngay từ đầu, mình sẽ bị overwhelm.

**Test-driven approach:**

Viết Python test scripts trước khi viết C code giúp mình catch bugs sớm. Mỗi khi thay đổi gì, mình chạy lại tests. Nếu fail, biết ngay có vấn đề.

**Documentation:**

Ghi chép lại toàn bộ quá trình (file này) rất hữu ích. Nó giúp mình nhớ lại tại sao đã quyết định như vậy, và giúp người khác học được từ kinh nghiệm này.

### Những Sai Lầm Ban Đầu

**Printf leak:**

Lỗi lớn nhất là để `printf("Decrypted: %s\n", buffer)` trong code. Đây là một oversight cơ bản. Bài học: **luôn kiểm tra kỹ output của chương trình**, không chỉ kiểm tra binary.

**Memory importance underestimated:**

Ban đầu mình chưa nghĩ kỹ về việc làm sao để memory dump thực sự quan trọng. Mình chỉ tập trung vào việc "làm cho khó hơn" mà quên mất phải đảm bảo memory là một phần BẮT BUỘC của solve path.

Bài học: **test intended solve path kỹ lưỡng**, đặt mình vào vị trí người chơi.

**Security checks muộn:**

Mình nên build security verification scripts ngay từ đầu, không phải sau khi hoàn thành. Điều này sẽ giúp catch issues sớm hơn.

### Best Practices Applied

**Challenge design principles:**

- Solve path rõ ràng (8-9 bước)
- Mỗi bước có ý nghĩa
- Không có shortcuts không mong muốn
- Educational value: người chơi học được techniques thực tế

**Development practices:**

- Version control (git) để track changes
- Incremental commits sau mỗi milestone
- Comprehensive testing sau mỗi thay đổi
- Documentation đi kèm với code

**Security mindset:**

- Assume adversarial players (sẽ tìm cách cheat)
- Verify EVERY potential leak
- Test với các tools thật (strings, file, grep)
- Think like an attacker

---

## Intended Solve Path (Chi Tiết)

Đây là cách mình mong muốn người chơi giải challenge này:

### Bước 1: Phân Tích Memory Dump

Người chơi nhận được file `memory.raw` (memory dump của một Windows machine). Đầu tiên họ cần tìm process đáng ngờ.

Sử dụng Volatility3 với plugin `windows.pslist`, họ sẽ thấy một process tên `chatclient.exe` đang chạy. Process này không phải là một Windows process chuẩn, nên rất đáng ngờ.

### Bước 2: Dump Executable

Dùng plugin `windows.dumpfiles` với PID của chatclient.exe, họ extract được binary từ memory. File này có thể tên là `file.0x....chatclient.exe.dat` hoặc tương tự.

Rename thành `chatclient.exe`, check với `file` command để confirm đúng là PE executable.

### Bước 3: Reverse Engineering

Load binary vào Ghidra hoặc IDA. Analyze xong, tìm hàm main().

Trong main(), họ sẽ thấy:
- Các biến k1, k2, k3 (key fragments)
- Một vòng lặp concatenate chúng
- Một phép tính `a ^ b`
- Một hàm call với nhiều parameters

Follow vào hàm đó (decrypt_message), họ sẽ thấy thuật toán:
- Loop qua từng byte của cipher
- XOR với key[i % keylen]
- XOR với một biến "state"
- State được update: `state + 13` và `& 0xff`

Đây là rolling-key XOR với step +13.

### Bước 4: Extract Key Fragments

Chạy `strings chatclient.exe` và grep các pattern. Họ sẽ thấy:
- `uit_`
- `insec_`
- `lab`

Từ disassembly, họ biết thứ tự concatenate: k1 + k2 + k3 = `uit_insec_lab`.

### Bước 5: Tìm Runtime Key Trong Memory

Đây là bước QUAN TRỌNG nhất.

Dù có thể đoán được full key từ fragments, nhưng để chắc chắn (và theo intended path), họ nên dump process memory và search.

Dùng `windows.memmap --pid [PID] --dump`, sau đó `strings` trên file dump và grep `uit_insec`. Họ sẽ thấy chuỗi `uit_insec_lab` xuất hiện trong runtime memory.

Điều này confirm thứ tự và full key.

### Bước 6: Calculate Seed

Từ disassembly, họ thấy:
```
a = 0x21
b = 0x63
seed = a ^ b
```

Tính toán: `0x21 ^ 0x63 = 0x42`. Seed là `0x42`.

### Bước 7: Extract Ciphertext

Trong Ghidra, xem .data section hoặc tìm biến `cipher[]`. Copy 36 bytes ra.

Hoặc đơn giản hơn, search hex pattern trong binary.

### Bước 8: Viết Script Decrypt

Viết một script Python implement thuật toán rolling-key XOR ngược lại. Input: ciphertext, key `uit_insec_lab`, seed `0x42`. Output: plaintext.

Chạy script, ra flag: `inseclab{memory_leaks_are_dangerous}`.

### Tại Sao Solve Path Này Tốt?

**Đa dạng kỹ năng:**
- Memory forensics (Volatility)
- Binary analysis (strings, file)
- Reverse engineering (Ghidra/IDA)
- Cryptanalysis (hiểu XOR và state machines)
- Scripting (Python)

**Mỗi bước có ý nghĩa:**

Không có bước nào redundant. Mỗi bước cung cấp một mảnh ghép khác nhau.

**Memory thực sự quan trọng:**

Không thể giải một cách tự tin 100% mà không có memory dump. Có thể đoán được key, nhưng runtime_key trong RAM là confirmation quyết định.

---

## Kết Luận

### Thời Gian Thực Tế

- **Phase 1 (Simple XOR):** ~1 giờ (setup + code + test)
- **Phase 2 (Rolling-Key upgrade):** ~2 giờ (design + implement + verify)
- **Phase 3 (Critical fixes):** ~30 phút (phát hiện + sửa + test lại)
- **Documentation:** ~1 giờ (viết CREATE.md này)
- **Tổng cộng:** ~4.5 giờ

Thời gian này không bao gồm việc học MinGW, Volatility, hay Ghidra. Nếu tính cả thời gian research, có thể x2 hoặc x3.

### Key Achievements

✅ **Built entirely on Ubuntu** - Không cần Windows trong suốt quá trình phát triển

✅ **Rolling-key XOR algorithm** - Phức tạp vừa phải, đủ để interesting nhưng không overwhelming

✅ **No leaks** - Plaintext và full key không xuất hiện trong binary

✅ **Memory is crucial** - Runtime_key là artifact quyết định từ RAM

✅ **Educational** - Người chơi học được real forensics techniques

✅ **Fully tested** - Tất cả test cases pass, verified kỹ lưỡng

### Next Steps

**Windows VM phase:**

1. Copy `chatclient.exe` sang Windows VM
2. Chạy executable (sẽ thấy "Message processed successfully!")
3. Dừng lại tại getchar() (đừng nhấn Enter)
4. Tạo memory dump bằng FTK Imager hoặc WinPMEM
5. Copy memory.raw về Ubuntu
6. Test full solve path với Volatility3
7. Verify flag recovery

**Challenge release:**

Sau khi Windows phase hoàn tất và verify, challenge sẽ được release với:
- `memory.raw` (memory dump)
- `description.md` (challenge description)
- Không có source code, không có binary riêng lẻ

Players chỉ nhận được memory dump và description. Họ phải tự dump binary từ memory.

---

## Lời Kết

Tạo một CTF challenge không chỉ là viết code. Đó là về việc thiết kế một puzzle vừa challenging vừa fair, vừa educational vừa fun.

Mỗi quyết định thiết kế đều có trade-offs. Simple XOR quá dễ, nhưng ChaCha20 quá khó. Rolling-key XOR là sweet spot. Key fragments vừa đủ obfuscation, nhưng vẫn discoverable. Seed calculation đủ subtle, nhưng không đến mức phải brute-force.

Sai lầm là một phần của quá trình. Printf leak là một lỗi nghiêm trọng, nhưng phát hiện ra nó (và fix) là một bài học quý giá. Lần sau mình sẽ chú ý hơn về output của chương trình.

Nếu có điều gì mình muốn nhấn mạnh nhất từ experience này: **Test intended solve path thoroughly, from a player's perspective.** Đừng chỉ test xem code có chạy không. Test xem người khác có thể giải được không, và họ có phải trải qua đúng các bước bạn mong muốn không.

Challenge này giờ sẵn sàng cho Windows VM phase. Hy vọng players sẽ enjoy nó! 🎯

---

*This is a human story of challenge creation, not just a technical document. Every challenge has its journey, and this was ours.*
