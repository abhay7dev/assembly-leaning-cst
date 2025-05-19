; Run with the following command on my arch linux machine:
; nasm -f elf32 -o helloworld.o helloworld.nasm && ld -m elf_i386 -o helloworld helloworld.o && ./helloworld

_start:
    ; Print hello world
    mov eax, 4                      ; Move sys_write syscall to eax (4)
    mov ebx, 1                      ; Specify file descriptor (1 - stdout)
    mov ecx, msg                    ; Specfify which bytes to printe out in ecx
    mov edx, len                    ; Specify length of buffer in edx
    int 0x80                        ; Call kernel

    ; Print out prompt
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, lenP
    int 0x80

    ; Grab user input
    mov eax, 3                      ; Move sys_read syscall to eax (3)
    mov ebx, 0                      ; Specify file descriptor (0 - stdin)
    mov ecx, num                    ; Destination buffer/pointer for input
    mov edx, 2                      ; Read 1 byte of data
    int 0x80                        ; Call kernel

    ; Print result string and then actual age
    mov eax, 4
    mov ebx, 1
    mov ecx, ageNot
    mov edx, lenNot
    int 0x80
    mov eax, 4
    mov ebx, 1
    mov ecx, num
    mov edx, 2
    int 0x80
    mov eax, 4
    mov ebx, 1
    mov ecx, 0
    mov edx, 2
    int 0x80

    ; Exit program
    mov eax, 1                      ; Move sys_exit syscall to eax (1)
    mov ebx, 0                      ; Move exit code to ebx
    int 0x80                        ; Call kernel

section .text
    global _start                   ; Declared so linker (ld) can properly setup program

section .data
    msg db 'Hello, World!', 0xa     ; String we are printing. db = define byte
    len equ $ - msg                 ; Grab length of string. $ symbol signified current pointer, and we are subtracing the pointer for the msg string, so we get the length.
    ; This happens at compile time. "equ" signifies that.
    
    prompt db 'Enter your age: '
    lenP equ $ - prompt

    ageNot db 'Your age is '
    lenNot equ $ - ageNot
 
section .bss                        ; Uninitialized data section
    num resb 2
    ; resb means reserve byte. num is a label to the start of the 5 allocated bytes.
    ; Bytes are 0-filled and allocated at start of execution