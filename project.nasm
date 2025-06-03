; Ask the user to input 10 integers and then output the sum, average, range and the number of prime numbers.

; First .text section. We say global _start for the linker to find the start of our program
section .text
    global _start

; Data section to hold predefined variables/values
section .data
    welcome db "Welcome to Abhay's assembly program!", 0x0a, 0x0a
    welcomeLen equ $ - welcome

    entNum db "Enter a number: "
    entNumLen equ $ - entNum

    sumPrint db 0x0a, "Sum: "
    sumPrintLen equ $ - sumPrint

    avgPrint db 0x0a, "Average: "
    avgPrintLen equ $ - avgPrint
 
    rangePrint db 0x0a, "Range: "
    rangPrintLen equ $ - rangePrint
    minPrint db " (Min: "
    minPrintLen equ $ - minPrint
    maxPrint db " Max: "
    maxPrintLen equ $ - maxPrint
    rightPara db ")"
    rightParaLen equ $ - rightPara

    newLine db 0x0a
    newLineLen equ $ - newLine
    perSym db "."
    perSymLen equ $ - perSym

    loopcounter db 10

; bss section to hold uninitialized values in memory.
section .bss
    input_buf resb 12
    num_holder resd 1 ; resb is for reserving bytes, resd is for double word, aka 4 bytes
    num_holder2 resd 1
    
    sum_buf resb 4

    max resb 4
    min resb 4

    print_buf resb 12

; .text section to hold 
section .text
_start:

    ; Print out welcome message
    mov eax, 4
    mov ebx, 1
    mov ecx, welcome
    mov edx, welcomeLen
    int 0x80

; Loop to get 10 user inputs
inp_loop:
    ; Print out prompt
    mov eax, 4
    mov ebx, 1
    mov ecx, entNum
    mov edx, entNumLen
    int 0x80

    ; Get user input
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 12
    int 0x80

    ; Call the parse_num function so we can 
    call parse_num

    ; Move the values in memory to registers eax, ebx, and 
    mov eax, [sum_buf]
    mov ebx, [num_holder]
    add eax, ebx
    mov [sum_buf], eax

    ; We are holding a running total of the min/max, so we do so here
    cmp byte [loopcounter], 10
    je update_min_max_first
    jne update_min_max_other

continue_loop:
    ; Decrement the loop counter and jump back while we still need to input numbers
    dec byte [loopcounter]
    cmp byte [loopcounter], 1
    jge inp_loop

    ; Add the sum to the stack and print it out with the print_val function
    mov eax, 4
    mov ebx, 1
    mov ecx, sumPrint
    mov edx, sumPrintLen
    int 0x80
    push dword [sum_buf]
    call print_val

    ; Calculate average by dividing by 10
    mov eax, [sum_buf]
    mov ebx, 10
    xor edx, edx ; 0 out edx register
    div ebx

    ; Save the values in num_holders because they will be modified
    mov [num_holder], eax
    mov [num_holder2], edx

    ; Print the average of the values
    mov eax, 4
    mov ebx, 1
    mov ecx, avgPrint
    mov edx, avgPrintLen
    int 0x80
    push dword [num_holder]
    call print_val

    ; If there is a remainder, then print that out as well.
    cmp dword [num_holder2], 0
    jg print_remainder

continue_prog:

    mov eax, 4
    mov ebx, 1
    mov ecx, rangePrint
    mov edx, rangPrintLen
    int 0x80

    mov eax, [max]
    sub eax, [min]
    push dword eax
    call print_val

    mov eax, 4
    mov ebx, 1
    mov ecx, minPrint
    mov edx, minPrintLen
    int 0x80

    push dword [min]
    call print_val

    mov eax, 4
    mov ebx, 1
    mov ecx, maxPrint
    mov edx, maxPrintLen
    int 0x80

    push dword [max]
    call print_val

    mov eax, 4
    mov ebx, 1
    mov ecx, rightPara
    mov edx, rightParaLen
    int 0x80

    ; Print newline at end of program
    mov eax, 4
    mov ebx, 1
    mov ecx, newLine
    mov edx, newLineLen
    int 0x80

    ; Exit program
    mov eax, 1
    mov ebx, 0
    int 0x80

; Update the min/max value after getting the first value
update_min_max_first:
    mov edx, [num_holder]
    mov [max], edx
    mov [min], edx
    jmp continue_loop

; Update min/max value after getting any other value by comparing to current min/max
update_min_max_other:
    mov edx, [num_holder]
    cmp edx, [max]
    jg update_max

    cmp edx, [min]
    jl update_min

    jmp continue_loop
update_max:
    mov [max], edx
    jmp continue_loop
update_min:
    mov [min], edx
    jmp continue_loop

; Add remainder to calculation
print_remainder:

    mov eax, 4
    mov ebx, 1
    mov ecx, perSym
    mov edx, perSymLen
    int 0x80

    push dword [num_holder2]
    call print_val

    jmp continue_prog

parse_num:
    ; Faster way to set cpu register to be 0 rather than just "MOV REG, 0"
    xor eax, eax
    xor ecx, ecx
; Loop to convert every 
convert_loop:
    ; Move the single character into the low byte (8 bit out of the 32 bit) on the ebx register
    mov bl, [input_buf + ecx]

    ; Compare to the new line character, and if it is, then we are done reading input
    cmp bl, 0x0a
    je done_convert

    ; Subtract the byte for the '0' ASCII character, multiply the currently stored number by 10 to get it ready to add the next digit, then add the digit 
    sub bl, '0'
    imul eax, eax, 10
    add eax, ebx

    ; Update the ecx register so we can read the next digit
    inc ecx
    jmp convert_loop

; Done with loop so move value into num_holder address and return
done_convert:
    mov [num_holder], eax
    ret


; Input: 32-bit number is on the stack (esp)
; Output: prints number + newline to stdout
print_val:

    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx

    mov eax, [ebp + 8]       ; Get the 32-bit value from stack

    mov ecx, print_buf + 11  ; End of buffer
    ; mov byte [ecx], ' '      ; Empty Space
    dec ecx                  ; Move back to fill digits

    cmp eax, 0
    jne .convert
    mov byte [ecx], '0'
    dec ecx
    jmp .done

.convert:
    xor edx, edx
.next_digit:
    mov ebx, 10
    div ebx                  ; EAX = EAX / 10, remainder in EDX
    add dl, '0'              ; Convert remainder to ASCII
    mov [ecx], dl
    dec ecx
    xor edx, edx
    test eax, eax
    jnz .next_digit

.done:
    inc ecx                  ; Point to first digit

    mov eax, 4               ; sys_write
    mov ebx, 1               ; stdout
    mov edx, print_buf + 12
    sub edx, ecx             ; length = end - start
    mov ecx, ecx             ; buffer ptr already in ecx
    int 0x80

    pop edx
    pop ecx
    pop ebx
    pop eax
    pop ebp
    ret