# Chat Application Leak -- Memory Forensics Challenge

## Overview

This challenge is a **Memory Forensics + Basic Reverse Engineering**
task designed for CTF competitions.\
Players receive a **RAM dump** from a Windows machine where a small chat
client application crashed.

The application encrypts messages before sending them.\
The encryption key and encrypted message remain in memory when the
program crashes.

The player's goal is to:

1.  Identify the suspicious process in the memory dump
2.  Dump the executable from memory
3.  Reverse the encryption routine
4.  Recover the encryption key from memory
5.  Decrypt the message and obtain the flag

Difficulty: **Easy--Medium**

------------------------------------------------------------------------

# Challenge Story

A developer created an experimental chat client.

The application encrypts outgoing messages before sending them to the
server.\
During testing the application crashed.

A memory dump of the machine was collected for debugging.

Your task is to analyze the memory dump and recover the secret message.

------------------------------------------------------------------------

# Tools Required (Challenge Creation)

To build this challenge you need:

## Development

-   C compiler (MinGW / GCC)
-   Windows virtual machine
-   Notepad++ or VSCode

## Memory Dump

-   DumpIt or WinPMEM

## Analysis / Testing

-   Volatility3
-   IDA Pro / Ghidra
-   Python (for decrypt script)

------------------------------------------------------------------------

# Step 1 -- Write the Chat Client Program

Create a simple C program that encrypts a message with XOR.

Example code:

``` c
#include <stdio.h>
#include <string.h>

char key[] = "dev_secret_key";
char message[] = "flag{memory_leaks_are_dangerous}";

void encrypt(char *data, int len) {
    int keylen = strlen(key);
    for(int i=0;i<len;i++) {
        data[i] ^= key[i % keylen];
    }
}

int main() {

    encrypt(message, strlen(message));

    printf("Encrypted message sent!\n");

    getchar(); // keep program running

    return 0;
}
```

Compile:

    gcc chatclient.c -o chatclient.exe

------------------------------------------------------------------------

# Step 2 -- Prepare the Windows VM

1.  Start a Windows virtual machine
2.  Copy `chatclient.exe` into the VM
3.  Run the program

The program will:

-   encrypt the flag
-   keep the encrypted message in memory
-   keep the key in memory

------------------------------------------------------------------------

# Step 3 -- Create Memory Dump

Use DumpIt or WinPMEM.

Example:

    DumpIt.exe

This produces:

    memory.raw

This file will be distributed to players.

------------------------------------------------------------------------

# Step 4 -- Verify the Challenge

Before publishing the challenge test that the artifacts exist.

Check:

-   process visible
-   key visible in memory
-   encrypted message visible

Example command:

    volatility3 -f memory.raw windows.pslist

Expected process:

    chatclient.exe

------------------------------------------------------------------------

# Files Provided to Players

Players receive:

    memory.raw
    description.txt

No source code is provided.

------------------------------------------------------------------------

# Expected Solve Path

## Step 1 -- Identify Running Processes

Use Volatility:

    volatility3 -f memory.raw windows.pslist

Find suspicious process:

    chatclient.exe

------------------------------------------------------------------------

## Step 2 -- Dump the Process

    volatility3 -f memory.raw windows.dumpfiles --pid <PID>

Extract:

    chatclient.exe

------------------------------------------------------------------------

## Step 3 -- Reverse the Program

Open the binary in IDA or Ghidra.

Identify encryption routine:

    cipher = plaintext XOR key[i % keylen]

------------------------------------------------------------------------

## Step 4 -- Recover Key From Memory

Search memory for strings:

    volatility3 -f memory.raw windows.strings

Find:

    dev_secret_key

------------------------------------------------------------------------

## Step 5 -- Recover Encrypted Message

Locate encrypted message in memory dump.

Example:

    memory region of chatclient.exe

Extract the bytes.

------------------------------------------------------------------------

## Step 6 -- Decrypt

Python script:

``` python
key = b"dev_secret_key"
cipher = b"...encrypted bytes..."

plain = bytearray()

for i,b in enumerate(cipher):
    plain.append(b ^ key[i % len(key)])

print(plain.decode())
```

Output:

    flag{memory_leaks_are_dangerous}

------------------------------------------------------------------------

# Why This Challenge Works

The challenge teaches:

-   memory artifact discovery
-   process analysis
-   binary reverse engineering
-   simple cryptanalysis
-   RAM data leakage

Players must combine **forensics + reverse engineering**.

------------------------------------------------------------------------

# Difficulty Adjustment

To make the challenge harder:

-   obfuscate the key
-   store key on heap instead of static section
-   encrypt flag multiple times
-   remove obvious strings

To make it easier:

-   include encrypted message in clear memory
-   keep key as plain ASCII string

------------------------------------------------------------------------

# Final Challenge Structure

    challenge/
     ├ memory.raw
     ├ description.txt

Flag format:

    flag{memory_leaks_are_dangerous}
