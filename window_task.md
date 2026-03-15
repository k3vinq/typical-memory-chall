# Windows Phase Task Guide

## Purpose

This document describes **everything you need to do on Windows** to finish building and validating the memory forensics challenge.

At this stage, the Ubuntu side is considered ready:
- the binary has been rebuilt
- plaintext is no longer printed to stdout
- the full runtime key is not directly present in the binary
- the intended solve path now requires both **reverse engineering** and **memory forensics**

Your goal on Windows is to:

1. Run the challenge binary in a Windows environment
2. Keep the target process alive
3. Create a memory dump
4. Verify that the required artifacts are actually present in RAM
5. Test the intended solve path end-to-end
6. Package the final challenge release

---

## Final Challenge Design Reminder

### Binary contains
- ciphertext
- the rolling-key XOR algorithm
- key fragments:
  - `uit_`
  - `insec_`
  - `lab`

### Runtime creates
- full key: `uit_insec_lab`
- seed: `0x42` (computed at runtime)
- working buffers in memory

### Intended player flow
1. Analyze memory dump
2. Find `chatclient.exe`
3. Dump the binary or inspect process memory
4. Reverse the transform algorithm
5. Recover the runtime key from memory
6. Recover or read ciphertext from the binary
7. Reimplement decryption
8. Recover the flag

### Final flag
`inseclab{memory_leaks_are_dangerous}`

---

# Part 1 - Prepare the Windows VM

## Recommended VM setup

Use a clean Windows virtual machine.

Recommended:
- Windows 10 or Windows 11
- 2 GB RAM is enough
- 20 GB disk is enough
- as few extra applications as possible

Why?
A cleaner VM makes:
- the process list easier to inspect
- the memory image smaller
- the challenge artifacts easier to find
- debugging easier for you

## What to prepare inside the VM

Copy these files into the Windows VM:

- `chatclient.exe`
- your RAM dump tool:
  - DumpIt, or
  - WinPMEM, or
  - FTK Imager Memory Capture

Optional but useful:
- Process Hacker or Process Explorer
- a text file with quick notes
- a folder for storing the generated memory dump

Suggested folder layout in Windows:

```text
C:\CTF\challenge\chatclient.exe
C:\CTF\tools\DumpIt.exe
C:\CTF\output\
```

---

# Part 2 - Run the Challenge Binary

## Step 1 - Start the binary

Run:

```text
chatclient.exe
```

Expected behavior:
- the program starts normally
- it performs the runtime key assembly
- it processes the ciphertext internally
- it prints only a generic message such as:
  - `Message processed successfully!`
- it stays alive waiting for input

## Step 2 - Do NOT close the window

This is critical.

The process must still be alive when you create the memory dump.

If you close the program too early:
- the runtime key may disappear
- stack/heap buffers may be lost or changed
- your intended solve path becomes unstable

## Step 3 - Confirm the process exists

Use Task Manager or Process Hacker and confirm:
- `chatclient.exe` is running
- it is a user process
- it remains open and stable

This gives you a quick sanity check before capturing RAM.

---

# Part 3 - Create the Memory Dump

## Tool options

You can use one of the following:

### Option A - DumpIt
Easy and common for Windows memory forensics.

### Option B - WinPMEM
Also very suitable and widely used.

### Option C - FTK Imager Memory Capture
Fine for testing if you already use FTK tools.

Use whichever one you trust most.

## Important rules during memory capture

While creating the dump:

- do not close `chatclient.exe`
- do not reboot the VM
- do not launch many extra programs
- do not interact with the system more than necessary

The goal is to preserve the runtime artifacts as cleanly as possible.

## Output

After the tool finishes, you should get a file such as:

- `memory.raw`
- `memdump.raw`
- `PhysicalMemory.raw`
- or another tool-specific image name

Move that file into a location you can copy back to your analysis machine.

Suggested final name:
- `memory.raw`

---

# Part 4 - Validate the Challenge Artifacts

This is the most important part of the Windows phase.

Do **not** assume the challenge is ready just because the dump exists.

You must verify that the actual memory image supports the intended solve path.

## Artifact checklist

You want the dump to support all of the following:

### 1. Process visibility
You should be able to find:
- `chatclient.exe`

### 2. Runtime key visibility
You want the full key:
- `uit_insec_lab`

to appear in process memory or a recoverable memory region.

This is the main reason memory matters in the challenge.

### 3. Ciphertext availability
The ciphertext should still be recoverable from:
- the binary itself
- or process memory if needed

### 4. Reverse path remains valid
The dumped binary should still make it possible to:
- identify the rolling-key XOR logic
- identify seed calculation
- identify key fragment assembly

### 5. Plaintext should not be trivially leaked
This is extremely important.

You should check whether the plaintext flag appears too easily in RAM.

If the player can just grep the memory dump for:
- `inseclab{`

and instantly recover the flag, the challenge may become too easy.

That does not automatically make the challenge invalid, but it weakens the intended solve path.

---

# Part 5 - Test the Intended Solve Path

Once you have the memory dump, treat it like a real player would.

## Goal

Solve the challenge only from the memory dump and the extracted artifacts.

## Expected test flow

### Step 1 - Find the process
Use Volatility to identify:
- `chatclient.exe`

### Step 2 - Dump or recover the executable
Extract the process-related binary or inspect the dumped image as needed.

### Step 3 - Reverse the binary
Open the executable in:
- Ghidra
- IDA
- Cutter

Confirm that you can identify:
- the rolling-key XOR logic
- the key fragment assembly
- the seed calculation
- the ciphertext location

### Step 4 - Recover the runtime key from memory
Find:
- `uit_insec_lab`

This should come from memory, not from simple binary strings.

### Step 5 - Recover the seed
Reverse should reveal:
- `seed = 0x42`

You should not need to brute-force it.

### Step 6 - Recover ciphertext
Recover ciphertext from the binary or relevant data section.

### Step 7 - Run the solve script
Use your rolling-key XOR solve script and confirm it outputs:

```text
inseclab{memory_leaks_are_dangerous}
```

---

# Part 6 - What Exactly You Need to Check

## Check A - Does memory really matter?

Ask yourself:

**Can the player solve the challenge with only the binary?**

If the answer is yes, too easily, then memory is still not important enough.

The desired answer should be:
- reverse gives the algorithm
- memory gives the runtime key
- both are needed for the intended solution

## Check B - Is plaintext too easy to recover from RAM?

Search for:
- `inseclab{`

If you find the flag instantly in the raw dump with no effort, the challenge may be too easy from a forensics perspective.

If this happens, decide whether you want to:
- accept it for an easier challenge, or
- revise the runtime behavior later

## Check C - Is the runtime key stable enough?

Check whether:
- the full key is present
- it appears consistently
- it is not too fragile or missing

If the runtime key does **not** show up reliably in dumps, your intended solve path is too unstable.

---

# Part 7 - Decision Rules After Testing

After testing the memory dump, decide using this framework.

## Ready to release if:
- `chatclient.exe` is easy to identify
- the binary can be recovered or inspected
- the runtime key is present in RAM
- the rolling-key XOR algorithm is recoverable
- the seed is recoverable through reverse engineering
- the final flag can be recovered end-to-end
- plaintext is not exposed in an unintended trivial way

## Needs revision if:
- the runtime key is missing from RAM
- the process exits too early
- plaintext appears too obviously in RAM
- the seed is too obscure or too trivial
- the challenge can still be solved comfortably from the binary alone

---

# Part 8 - Final Packaging

Once validation is complete, prepare the challenge release.

## Files for players

Recommended release package:

```text
challenge/
├── memory.raw
└── description.txt
```

Do **not** include:
- source code
- solve scripts
- generator scripts
- internal design notes
- binary unless you want the challenge to be easier than intended

## Internal author package

Keep a separate private folder containing:
- source code
- generator script
- solve script
- writeup
- testing notes
- final verified binary
- original memory dump

---

# Part 9 - Final Windows Checklist

Use this as your Windows execution checklist.

## Before dumping memory
- [ ] Copy `chatclient.exe` into the VM
- [ ] Copy memory dump tool into the VM
- [ ] Run `chatclient.exe`
- [ ] Confirm it prints only a generic message
- [ ] Confirm the process remains alive
- [ ] Confirm `chatclient.exe` is visible in Task Manager / Process Hacker

## During memory capture
- [ ] Keep `chatclient.exe` open
- [ ] Run DumpIt / WinPMEM / FTK Imager
- [ ] Wait for dump completion
- [ ] Save the memory image
- [ ] Copy the dump back to the analysis machine

## After memory capture
- [ ] Verify `chatclient.exe` is discoverable in the dump
- [ ] Verify the runtime key is recoverable from memory
- [ ] Verify plaintext is not trivially exposed
- [ ] Verify ciphertext is recoverable
- [ ] Reverse the binary and confirm the intended algorithm
- [ ] Run the solve script end-to-end
- [ ] Confirm final flag recovery
- [ ] Package the challenge release

---

# Part 10 - Final Advice

The Windows phase is not just a mechanical step.  
It is where your challenge becomes either:

- a real memory-forensics challenge with meaningful runtime artifacts, or
- just a reverse challenge wrapped in a RAM dump

The quality of the final challenge depends on what actually survives in RAM.

Your main validation question is:

**Does the memory dump contain the right evidence for the intended solve path, without leaking the answer too easily?**

If the answer is yes, the challenge is ready.
