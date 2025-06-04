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

    primePrint db 0x0a, "Number of Primes: "
    primePrintLen equ $ - primePrint

; bss section to hold uninitialized values in memory.
section .bss
    input_buf resb 12
    num_holder resd 1 ; resb is for reserving bytes, resd is for double word, aka 4 bytes
    num_holder2 resd 1
    
    sum_buf resb 4

    max resb 4
    min resb 4

    primeLoopNum resd 1
    primecount resd 1

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

; The update min/max funcs need a label to jump to after completing
continue_loopMM:

    ; Call the label to check if number is prime
    jmp check_primality

continue_loopPr:

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

; Need a label for print_remainder to jump back to if called
continue_prog:

    ; Print our range information. We will be printing strings for the output
    mov eax, 4
    mov ebx, 1
    mov ecx, rangePrint
    mov edx, rangPrintLen
    int 0x80
    ; Calculate the range. Subtract the max from the min and print out the value
    mov eax, [max]
    sub eax, [min]
    push dword eax
    call print_val
    
    ; Print minimum
    mov eax, 4
    mov ebx, 1
    mov ecx, minPrint
    mov edx, minPrintLen
    int 0x80
    push dword [min]
    call print_val
    ; Print maximum
    mov eax, 4
    mov ebx, 1
    mov ecx, maxPrint
    mov edx, maxPrintLen
    int 0x80
    push dword [max]
    call print_val
    ; Print closing parentheses
    mov eax, 4
    mov ebx, 1
    mov ecx, rightPara
    mov edx, rightParaLen
    int 0x80

    ; Print the number of prime numbers
    mov eax, 4
    mov ebx, 1
    mov ecx, primePrint
    mov edx, primePrintLen
    int 0x80
    push dword [primecount]
    call print_val

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
    ; User inputted number is in num_holder, so we move to edx, do comparisons, then continue the loop
    mov edx, [num_holder]
    mov [max], edx
    mov [min], edx
    jmp continue_loopMM

; Update min/max value after getting any other value by comparing to current min/max
update_min_max_other:
    mov edx, [num_holder]
    cmp edx, [max]
    jg update_max

    cmp edx, [min]
    jl update_min

    jmp continue_loopMM
update_max:
    mov [max], edx
    jmp continue_loopMM
update_min:
    mov [min], edx
    jmp continue_loopMM

; Check whether number is prime
check_primality:
    mov dword [primeLoopNum], 1 ; Reset primeLoopNum to 1. Further explained below

    ; Check small values for primes: 0, 1, 2, 3 
    mov eax, [num_holder]
    cmp eax, 0
    je exitPrimeCheck
    cmp eax, 1
    je exitPrimeCheck
    cmp eax, 2
    je isPrime
    cmp eax, 3
    je isPrime


    ; Check if number is even. If it is, it's not prime
    mov eax, [num_holder]
    xor edx, edx
    mov ebx, 2
    div ebx
    cmp edx, 0
    je exitPrimeCheck
checkNumsLoop:
    ; primeLoopNum is the number we divide by in order to check if a number is prime in this brute force algorithm
    ; Because we already check if the number is even, we only have to check odd numbers, so we increment by 2 to get the sequence 1, 3, 5, 7, ...
    ; I can improve upon this by iterating only up until the floor of the square root of the number, but implementing that in assembly is pretty tricky
    inc dword [primeLoopNum]
    inc dword [primeLoopNum]
    mov ebx, [primeLoopNum]

    ; If ebx and eax are the same, then we know we have gone through all numbers below. We know the number is prime
    cmp ebx, eax
    jge isPrime

    ; Divides the user inputted number by the current loop number.
    ; If the remainder is 0, that means there was a perfect division, which means the num isn't prime
    mov eax, [num_holder]
    xor edx, edx
    div ebx
    cmp edx, 0
    je exitPrimeCheck

    ; We update eax once more (beacuse it may have been modified) and jump back.
    ; Our exit condition is a couple lines above, where I do a jge after compaing ebx, eax
    mov eax, [num_holder]
    jmp checkNumsLoop
isPrime:
    ; If the number is prime, we just increase the primecount variable
    inc dword [primecount]
exitPrimeCheck:
    ; Go back to where this was called from
    jmp continue_loopPr

; Add remainder to calculation
print_remainder:
    ; Prints the remainder, as ".N" where N is the remainder decimal
    mov eax, 4
    mov ebx, 1
    mov ecx, perSym
    mov edx, perSymLen
    int 0x80

    push dword [num_holder2]
    call print_val

    jmp continue_prog

; Following 3 labels are together. Help parse a '1' into a 1. Convert the ASCII representation into an actual number
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


; Prints out an integer by converting it to it's ASCII form. Need to input as a variable on the stack (esp)
print_val:
    ; Section prologue. We are updating the base pointer's frame of reference from the initial frame to the new, print_val frame of reference.
    ; We are using the stack to save the values that are currently stored in the registers, as we want to restore them before going back.
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx

    ; Because the stack addresses grow negative as we push to it
    ; and we also push a return address to the stack, we need to go forward 8 bytes to get the value we are passing via the stack
    ; We are putting this number in the eax register to begin with
    mov eax, [ebp + 8]

    ; print_buf is a pointer to the start of a set of 12 reserved bytes (2^32 max digits + new line character) where we will store the ascii character values
    ; We are fiilling the buffer right to left, so least significant to most.
    mov ecx, print_buf + 11
    dec ecx
    
    ; We need to make sure the value we are passing via the stack isn't 0. If it's 0. We don't need it to enter the digit loop
    cmp eax, 0
    jne .convert

    ; If eax is 0, or empty, then we just put the 0 ascii into ecx to print that out
    mov byte [ecx], '0'
    dec ecx
    jmp .done

.convert:
    xor edx, edx ; 0 out the edx register
    ; flow will automatically go into next_digit
.next_digit:
    mov ebx, 10
    div ebx ; syntax for saying eax /= 10. it divides value in eax by 10

    add dl, '0'
    ; ^ Add the ascii '0' to the digit. Remember, we are going left to right. We divide by 10, get the remainder value
    ; And then we want to convert the number to its ascii representation, so we add '0' to get that
    mov [ecx], dl
    dec ecx
    ; ecx, remember, contains the memory address where we have our ascii buffer stored. We are storing the new ascii we calculated in the buffer
    ; we decrement it because again, we are filling from right to left

    ; reset the edx register
    xor edx, edx
    ; Remember, eax stores the result of dividing by ten. 121 / 10 -> eax = 12, dl = 1
    test eax, eax ; Bitwise AND operator. This is the fastest way to check if register is set to 0.
    ; This is faster than doing cmp eax, 0.
    ; the test keyword sets a couple of flags on the cpu, which is how jnz evaluates 
    jnz .next_digit ; If the register is not 0, we have another digit we need to parse.

.done:
    ; Remember, ecx is our pointer to where we currently are in memory for printing out the ascii representation
    ; We need to increment ecx by 1 to get the pointer to the first byte we are printing out.
    inc ecx

    ; Print the digits
    mov eax, 4
    mov ebx, 1
    ; ecx already contains the start pointer
    mov edx, print_buf + 12
    int 0x80

    ; We are popping the stack which contains the saved register values, thus restoring what we had previously.
    ; This way, we aren't leaving the stack modified.
    pop edx
    pop ecx
    pop ebx
    pop eax
    pop ebp
    ret ; Ret handles the jumping to the return address in memory (thats already on the stack)