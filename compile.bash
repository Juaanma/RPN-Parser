#!/bin/bash
# A simple script to compile this project with debug symbols
# (debugging data in DWARF format). The linker mode is x86-32 bits.

compIO="nasm -f elf -F dwarf -g Parser_Helper.asm"
compMain="nasm -f elf -F dwarf -g RPN_Parser.asm"
link="ld -m elf_i386 -o RPN_Parser RPN_Parser.o"
execute="./RPN_Parser"

eval $compIO
eval $compMain
eval $link
eval $execute
