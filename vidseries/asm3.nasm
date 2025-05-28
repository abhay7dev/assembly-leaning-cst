global _start
section .text
_start:
    mov ebx, 1 ; start ebx at 1
    mov ecx, 0 ; number of iterations
label:
    add ebx, ebx
    dec ecx
    cmp ecx, 0
    jg label

    mov eax, 4                      ; Move sys_write syscall to eax (4)
    mov ecx, ebx                    ; Specfify which bytes to printe out in ecx
    mov ebx, 1                      ; Specify file descriptor (1 - stdout)
    mov edx, 4                      ; Specify length of buffer in edx
    int 0x80                        ; Call kernel

    mov eax, 1
    mov ebx, 0
    int 0x80