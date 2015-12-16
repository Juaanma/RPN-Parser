; Postfix algorithm:
; While there are input tokens left
;  	Read the next token from input.
;	If the token is a value
;		Push it onto the stack.
;	Otherwise, the token is an operator (operator here includes both operators and functions).
;		It is known a priori that the operator takes n arguments.
;		If there are fewer than n values on the stack
;			(Error) The user has not input sufficient values in the expression.
;		Else, Pop the top n values from the stack.
;		Evaluate the operator, with the values as arguments.
;		Push the returned results, if any, back onto the stack.
; If there is only one value in the stack
;	That value is the result of the calculation.
; Otherwise, there are more values in the stack
; 	(Error) The user input has too many values.


SYS_READ equ 3
SYS_WRITE equ 4
STDIN equ 0
STDOUT equ 1

; A macro with two parameters.
; Implements the write system call.
%macro write_string 2
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, %1
    mov edx, %2

    int 80h             ; Invoke the kernel.
%endmacro

segment .bss 
char resb 1
dig resd 1

segment .data
num dd 0
len db 0

segment .text
; This procedure will read each part of the expression,
; parsing operands and operators.
read_and_parse:
    ; pusha We could push the registers' values to the stack, but it's not necessary.

    read_loop:          ; A loop to read and parse each character. 

    mov eax, SYS_READ
    mov ebx, STDIN
    mov ecx, char
    mov edx, 1          ; We'll read one character at a time 
    
    int 80h             ; Invoke the kernel.

    cmp byte [char], 10      ; If we read a new line character (decimal 10 in ASCII), it means that we have finished reading the expression.   
    je finished_reading

    cmp byte [char], ' ' 
    je space

    cmp byte [char], '0'
    jge create_number   ; If it's a digit, add it to the end of the current number (so that we store the entire operand).

    ; Otherwise, the token is an operator.
    ; Pop both operands.
    pop ebx
    pop eax
    ; And evaluate the corresponding operator.
    cmp byte [char], '+'  
    je plus_operator
    cmp byte [char], '-'
    je minus_operator
    cmp byte [char], '/'
    je division_operator
    cmp byte [char], '*'
    je multiplication_operator

    plus_operator:
    add eax, ebx
    push eax
    jmp read_loop

    minus_operator:
    sub eax, ebx
    push eax
    jmp read_loop

    ; We want to divide EAX by EBX.
    ; As the divisor is a dword (32 bits long), 
    ; the dividend is assumed to be 64 bits 
    ; long and in the EDX:EAX registers.
    division_operator:
    mov edx, 0                                 ; Because we only want to divide by EAX, we set EDX to 0.
    div ebx
    push eax
    jmp read_loop

    multiplication_operator:
    mul ebx
    push eax
    jmp read_loop

    ; Add the last digit read to the actual number.
    create_number:
    mov eax, [num] 
    mov ebx, 10
    mul ebx
    sub byte [char], '0'
    add eax, [char]
    mov [num], eax
    jmp read_loop

    ; If we read a space and we had previously read an operand, we'll push it to the stack and clear the [num] variable.
    space:
    cmp dword [num], 0
    je read_loop
    push dword [num]  
    mov dword [num], 0
    jmp read_loop

    finished_reading:
    pop dword [num]
    ; popa
    ret

print_integer:
    ; We'll use the EBP register to save the value of ESP.
    ; In this way, we can reference the parameters passed
    ; to the procedure, even if the ESP register gets
    ; a new value when data is pushed to the stack.
    push ebp
    mov ebp, esp

    ; Store the integer in the EAX register.
    mov eax, dword [ebp+8]
    mov byte [len], 0

    ; Prepare the EBX register for the next step.
    ; We store the divisor (10) in EBX.
    mov ebx, 10
    ; While the number is not zero, get each digit as the remainder of the division by 10, and push it to the stack.
    extract_digits_loop:
    ; The divisor is 32 bits long (EBX register). Therefore, the dividend will be EDX:EAX, and we should set EDX to 0.
    mov edx, 0 
    div ebx 
    push edx                       ; Push the remainder to the stack.
    
    inc byte [len]                 ; Count the number of digits to print.

    ; Do while structure: count at least a digit and then check if there are no digits left (EAX == 0).
    ; This is important for the case where the number to print is 0.
    cmp eax, 0
    je print_digits

    jmp extract_digits_loop

    ; While there are digits left to print, pop one digit from the stack and print it.
    print_digits: 

    cmp byte [len], 0
    je end_print

    pop dword [dig]
    add dword [dig], '0'

    write_string dig, 1

    dec byte [len]
    jmp print_digits
    
    ; End of the print_integer procedure.
    end_print:               
    ; Print a newline character.
    write_string 0xA, 1

    pop ebp
    ret
