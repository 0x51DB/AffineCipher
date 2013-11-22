#! /bin/bash
nasm -f elf64 -o encrypt.o encrypt.asm
ld -o encrypt encrypt.o
rm encrypt.o
nasm -f elf64 -o decrypt.o decrypt.asm
ld -o decrypt decrypt.o
rm decrypt.o
