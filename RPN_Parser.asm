; Reverse Polish notation parser in ASM (NASM x86 32 bits).

%include "Parser_Helper.asm"

SYS_EXIT equ 1

segment .data
msg1 db "This is a reverse Polish notation parser written in NASM.", 0xA
msg1_len equ $ - msg1
msg2 db "Please enter a valid expression to be evaluated. For example: '3 5 + 2 *'.", 0xA
msg2_len equ $ - msg2
msg3 db "As for now, this program doesn't support negative numbers.", 0xA
msg3_len equ $ - msg3

segment .text
global _start

_start: 
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, msg1
    mov edx, msg1_len

    int 80h

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, msg2
    mov edx, msg2_len

    int 80h

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, msg3
    mov edx, msg3_len

    int 80h

    call read_and_parse

    ; Pass the result of the expression as an argument to the print_integer function (through the stack).
    push dword [num]       

    call print_integer

    ; Update the stack pointer to remove the argument from the stack.
    add esp, 4
    
    mov eax, SYS_EXIT
    int 80h
