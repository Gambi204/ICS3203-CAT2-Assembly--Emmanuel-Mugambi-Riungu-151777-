section .data
    prompt db "Enter a positive integer (0-12): ", 0
    result_msg db "Factorial: ", 0
    error_msg db "Invalid input. Please enter a positive integer between 0 and 12.", 10, 0
    newline db 10, 0

section .bss
    input resb 10          ; Buffer for user input

section .text
    global _start

_start:
    ; Print the prompt message
    mov eax, 4             ; syscall: sys_write
    mov ebx, 1             ; file descriptor: stdout
    mov ecx, prompt        ; Address of the prompt
    mov edx, 36            ; Length of the prompt
    int 0x80               ; Execute syscall

    ; Read user input
    mov eax, 3             ; syscall: sys_read
    mov ebx, 0             ; file descriptor: stdin
    mov ecx, input         ; Buffer to store input
    mov edx, 10            ; Max bytes to read
    int 0x80               ; Execute syscall

    ; Convert input string to integer
    call string_to_int
    test eax, eax          ; Check if valid input
    js invalid_input       ; Jump to error if negative or invalid

    ; Check for valid range (0-12)
    cmp eax, 12
    jg invalid_input       ; Jump to error if greater than 12

    ; Call factorial subroutine
    push eax               ; Save input number on the stack
    call factorial         ; Compute factorial
    add esp, 4             ; Clean up the stack

    ; Display the result message
    mov eax, 4             ; syscall: sys_write
    mov ebx, 1             ; stdout
    mov ecx, result_msg    ; Address of the message
    mov edx, 10            ; Length of the message
    int 0x80               ; Execute syscall

    ; Print the factorial result
    call print_number

    ; Exit program
    mov eax, 1             ; syscall: sys_exit
    xor ebx, ebx           ; Exit code 0
    int 0x80

invalid_input:
    ; Display error message
    mov eax, 4             ; syscall: sys_write
    mov ebx, 1             ; stdout
    mov ecx, error_msg     ; Address of the error message
    mov edx, 58            ; Length of the error message
    int 0x80

    ; Exit program
    mov eax, 1             ; syscall: sys_exit
    xor ebx, ebx           ; Exit code 0
    int 0x80

; Subroutine: Convert string to integer
; Input: Address of string in ECX
; Output: EAX contains the integer (negative for invalid input)
string_to_int:
    xor eax, eax           ; Clear EAX for the result
    xor ebx, ebx           ; Clear EBX for digit parsing
    mov esi, input         ; Address of the input buffer

convert_loop:
    mov bl, byte [esi]     ; Load the current character
    cmp bl, 10             ; Check for newline
    je end_conversion      ; End of input
    cmp bl, ' '            ; Ignore spaces
    je skip_character
    sub bl, '0'            ; Convert ASCII to integer
    jl invalid_conversion  ; Invalid input (non-digit)
    cmp bl, 9
    jg invalid_conversion  ; Invalid input (non-digit)
    imul eax, eax, 10      ; Multiply result by 10
    add eax, ebx           ; Add the current digit
skip_character:
    inc esi                ; Move to the next character
    jmp convert_loop       ; Repeat for next character

invalid_conversion:
    mov eax, -1            ; Indicate invalid input
end_conversion:
    ret

; Subroutine: Compute factorial
; Input: Integer in EAX
; Output: Factorial in EAX
factorial:
    push ebx               ; Save EBX on the stack
    push ecx               ; Save ECX on the stack
    push edx               ; Save EDX on the stack

    mov ecx, eax           ; ECX = n (counter)
    mov eax, 1             ; EAX = 1 (result)

factorial_loop:
    test ecx, ecx          ; Check if ECX == 0
    jz factorial_done      ; Exit loop if ECX == 0
    imul eax, ecx          ; Multiply result by ECX
    dec ecx                ; Decrement ECX
    jmp factorial_loop     ; Repeat

factorial_done:
    pop edx                ; Restore EDX
    pop ecx                ; Restore ECX
    pop ebx                ; Restore EBX
    ret

; Subroutine: Print a number
; Input: Integer in EAX
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
    jnz print_stack        ; Repeat until stack empty

    pop eax                ; Restore original number
    ret
