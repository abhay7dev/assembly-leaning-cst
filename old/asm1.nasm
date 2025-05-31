; Assembly 1 Comp Sci Topics Program

section .text
    global _start ; Declared so linker (ld) can properly setup program

section .data
    title db 'I will prompt you for 10 integers and then output some data about that data set', 0xa ; String we are printing. 0xa is "\n". db = define byte
    lenTitle equ $ - title  ; Grab length of string. $ symbol signified current pointer, and we are subtracting the pointer for the string, so we get the length.
    ; This happens at compile time. "equ" signifies that.
    
    prompt db 'Enter a number: '
    lenPrompt equ $ - prompt

section .bss ; Uninitialized data section
    num resb 2
    ; resb means reserve byte. num is a label to the start of the 2 allocated bytes.
    ; Bytes are 0-filled and allocated at start of execution

section .text
_start:
    ; Print title & prompt
    mov eax, 4          ; Move sys_write syscall to eax (4)
    mov ebx, 1          ; Specify file descriptor (1 - stdout)
    mov ecx, title      ; Specfify which bytes to printe out in ecx
    mov edx, lenTitle   ; Specify length of buffer in edx
    int 0x80            ; Call kernel

    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, lenPrompt
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