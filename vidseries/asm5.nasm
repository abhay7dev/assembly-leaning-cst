global _start

section .data
    addrh db "hello", 10
    addrw db "world", 10

section .text
_start:
    
    mov eax, 4
    mov ebx, 1
    mov ecx, addrh
    mov edx, 6
    int 128
    mov eax, 4
    mov ebx, 1
    mov ecx, addrw
    mov edx, 6
    int 128
    ; int 0x80

    mov [addrh + 4], byte 'o'
    mov [addrh + 5], byte ' '
    mov [addrw + 5], byte '!'
        
    mov eax, 4
    mov ebx, 1
    mov ecx, addrh
    mov edx, 6
    int 128
    mov eax, 4
    mov ebx, 1
    mov ecx, addrw
    mov edx, 6
    int 128

    mov eax, 1
    mov ebx, 0
    int 0x80
