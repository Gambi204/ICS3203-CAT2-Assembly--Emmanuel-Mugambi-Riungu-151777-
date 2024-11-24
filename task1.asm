section .data
    prompt db "Enter a number: ", 0  ; Prompt message
    positive_msg db "POSITIVE", 10, 0
    negative_msg db "NEGATIVE", 10, 0
    zero_msg db "ZERO", 10, 0

section .bss
    num resb 4   ; Reserve space for user input

section .text
    global _start

_start:
    ; Prompt the user for input
    mov eax, 4           ; syscall: sys_write
    mov ebx, 1           ; file descriptor: stdout
    mov ecx, prompt      ; message to display
    mov edx, 15          ; length of message
    int 0x80             ; make system call

    ; Read user input
    mov eax, 3           ; syscall: sys_read
    mov ebx, 0           ; file descriptor: stdin
    mov ecx, num         ; buffer to store input
    mov edx, 4           ; maximum bytes to read
    int 0x80             ; make system call

    ; Convert ASCII input to integer
    mov ecx, 0           ; ECX will hold the result (number)
    mov esi, num         ; Point ESI to the input buffer
    xor ebx, ebx         ; EBX will track the sign (0 for positive, 1 for negative)

    ; Check for a negative sign
    cmp byte [esi], '-'  ; Compare first character with '-'
    jne parse_digits     ; If not '-', skip sign handling
    inc esi              ; Move to the next character
    mov bl, 1            ; Mark the number as negative

parse_digits:
    ; Parse digits
parse_loop:
    movzx eax, byte [esi] ; Load the current character
    cmp eax, 10          ; Check for newline or end of input
    je done_parsing      ; Exit loop if newline
    sub eax, '0'         ; Convert ASCII to numeric
    imul ecx, ecx, 10    ; Multiply result by 10
    add ecx, eax         ; Add the current digit
    inc esi              ; Move to the next character
    jmp parse_loop       ; Repeat for next character

done_parsing:
    ; Apply the sign if negative
    cmp bl, 1            ; Check if the number is negative
    jne classify         ; Skip if positive
    neg ecx              ; Negate the number if negative

classify:
    ; Classify the number
    cmp ecx, 0           ; Compare the number with 0
    je is_zero           ; Jump if number == 0
    jl is_negative       ; Jump if number < 0
    jmp is_positive      ; Jump if number > 0

is_zero:
    ; Handle zero case
    mov eax, 4           ; syscall: sys_write
    mov ebx, 1           ; file descriptor: stdout
    mov ecx, zero_msg    ; message to display
    mov edx, 5           ; length of message
    int 0x80             ; make system call
    jmp exit_program     ; Exit program

is_negative:
    ; Handle negative case
    mov eax, 4           ; syscall: sys_write
    mov ebx, 1           ; file descriptor: stdout
    mov ecx, negative_msg; message to display
    mov edx, 8           ; length of message
    int 0x80             ; make system call
    jmp exit_program     ; Exit program

is_positive:
    ; Handle positive case
    mov eax, 4           ; syscall: sys_write
    mov ebx, 1           ; file descriptor: stdout
    mov ecx, positive_msg; message to display
    mov edx, 8           ; length of message
    int 0x80             ; make system call

exit_program:
    ; Exit the program
    mov eax, 1           ; syscall: sys_exit
    xor ebx, ebx         ; return code 0
    int 0x80             ; make system call
