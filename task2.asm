section .data
    prompt db "Enter 5 integers separated by spaces: ", 0
    reversed_msg db "Reversed array: ", 10, 0
    error_msg db "Invalid input. Please enter 5 integers.", 10, 0
    newline db 10, 0

section .bss
    input resb 100         ; Buffer for raw input (max 100 bytes)
    array resd 5           ; Reserve space for 5 integers (5 * 4 bytes)

section .text
    global _start

_start:
    ; Print the prompt message
    mov eax, 4             ; syscall: sys_write
    mov ebx, 1             ; file descriptor: stdout
    mov ecx, prompt        ; Address of the prompt
    mov edx, 34            ; Length of the prompt
    int 0x80               ; Execute syscall

    ; Read user input
    mov eax, 3             ; syscall: sys_read
    mov ebx, 0             ; file descriptor: stdin
    mov ecx, input         ; Buffer to store input
    mov edx, 100           ; Max bytes to read
    int 0x80               ; Execute syscall

    ; Parse input into integers
    call parse_input
    test eax, eax          ; Check if parsing was successful
    jz invalid_input       ; If failed, show error and exit

    ; Reverse the array
    call reverse_array

    ; Display the reversed array message
    mov eax, 4             ; syscall: sys_write
    mov ebx, 1             ; file descriptor: stdout
    mov ecx, reversed_msg  ; Address of the message
    mov edx, 17            ; Length of the message
    int 0x80               ; Execute syscall

    ; Print the reversed array
    lea esi, [array]       ; Pointer to start of the array
    mov ecx, 5             ; Number of integers to print

print_loop:
    mov eax, [esi]         ; Load the current integer
    call print_number      ; Print the integer
    lea eax, [newline]     ; Add a newline
    mov ebx, 1             ; stdout
    mov ecx, eax
    mov edx, 1
    mov eax, 4             ; syscall: sys_write
    int 0x80
    add esi, 4             ; Move to the next integer
    loop print_loop        ; Repeat for all integers

    ; Exit the program
    mov eax, 1             ; syscall: sys_exit
    xor ebx, ebx           ; Exit code 0
    int 0x80

invalid_input:
    mov eax, 4             ; syscall: sys_write
    mov ebx, 1             ; file descriptor: stdout
    mov ecx, error_msg     ; Address of the error message
    mov edx, 39            ; Length of the error message
    int 0x80               ; Display error message

    mov eax, 1             ; syscall: sys_exit
    xor ebx, ebx           ; Exit code 0
    int 0x80

; Function to parse input into integers
; EAX = 0 if failed, EAX = 1 if successful
parse_input:
    lea esi, [input]       ; Pointer to input buffer
    lea edi, [array]       ; Pointer to array
    mov ecx, 5             ; Expecting 5 integers

parse_loop:
    xor eax, eax           ; Clear EAX for new number
    xor ebx, ebx           ; Clear EBX for digit parsing

parse_digit:
    mov bl, byte [esi]     ; Load the current character
    cmp bl, 10             ; Check for newline
    je end_parse           ; End of input
    cmp bl, ' '            ; Check for space
    je next_number         ; Move to next number
    sub bl, '0'            ; Convert ASCII to integer
    jl fail_parse          ; Invalid input (non-digit)
    cmp bl, 9
    jg fail_parse          ; Invalid input (non-digit)
    imul eax, eax, 10      ; Shift previous result left
    add eax, ebx           ; Add the current digit
    inc esi                ; Move to the next character
    jmp parse_digit        ; Repeat for the next character

next_number:
    mov [edi], eax         ; Store the parsed number in the array
    add edi, 4             ; Move to the next array slot
    inc esi                ; Skip the space
    loop parse_loop        ; Repeat for all numbers
    mov eax, 1             ; Indicate success
    ret

fail_parse:
    xor eax, eax           ; Indicate failure
    ret

end_parse:
    mov [edi], eax         ; Store the last number
    mov eax, 1             ; Indicate success
    ret

; Reverse the array in place
reverse_array:
    lea esi, [array]       ; Start of the array
    lea edi, [array + 16]  ; End of the array
    mov ecx, 2             ; Number of swaps (5 / 2)
reverse_loop:
    mov eax, [esi]         ; Load the value at start
    mov ebx, [edi]         ; Load the value at end
    mov [esi], ebx         ; Swap end value to start
    mov [edi], eax         ; Swap start value to end
    add esi, 4             ; Move start pointer forward
    sub edi, 4             ; Move end pointer backward
    loop reverse_loop      ; Repeat
    ret

; Print a number in EAX
print_number:
    push eax               ; Save the number
    mov ecx, 10            ; Divisor for base 10
    xor edi, edi           ; Digit count

convert_digit:
    xor edx, edx           ; Clear remainder
    div ecx                ; Divide EAX by 10
    add dl, '0'            ; Convert remainder to ASCII
    push edx               ; Store digit on stack
    inc edi                ; Increment digit count
    test eax, eax          ; Check if quotient is 0
    jnz convert_digit      ; Repeat if not

print_stack:
    pop eax                ; Pop a digit
    mov [esp - 1], al      ; Write digit
    lea ebx, [esp - 1]     ; Address of digit
    mov ecx, ebx
    mov edx, 1
    mov eax, 4             ; syscall: sys_write
    int 0x80               ; Execute syscall
    dec edi                ; Decrement digit count
    jnz print_stack        ; Repeat until stack is empty

    pop eax                ; Restore original number
    ret
