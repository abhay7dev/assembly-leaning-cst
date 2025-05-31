; Ask the user to input 10 integers and then outputs the sum, average, range and the number of prime numbers.

section .text
    global _start

section .data
    welcome db "Welcome to Abhay's assembly program!", 0x0a
    welcomeLen equ $ -  welcome

    entNum db 0xa, "Enter a number: "
    entNumLen equ $ -  entNum

    loopcounter db 10

section .bss
    input_buf resb 12

section .text
_start:

    mov eax, 4
    mov ebx, 1
    mov ecx, welcome,
    mov edx, welcomeLen
    int 0x80

inp_loop:
    mov eax, 4
    mov ebx, 1
    mov ecx, entNum,
    mov edx, entNumLen
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 12
    int 0x80

    ; Convert user input to number

    dec byte [loopcounter]
    cmp byte [loopcounter], 1
    jge inp_loop

    ; Exit program
    mov eax, 1                      ; Move sys_exit syscall to eax (1)
    mov ebx, 0                      ; Move exit code to ebx
    int 0x80                        ; Call kernel