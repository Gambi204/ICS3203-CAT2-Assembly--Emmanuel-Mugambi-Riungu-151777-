section .data
    prompt db "Enter water level (0-100): ", 0
    low_msg db "Motor ON: Water level LOW", 10, 0
    high_msg db "ALARM TRIGGERED: Water level HIGH", 10, 0
    moderate_msg db "Motor OFF: Water level MODERATE", 10, 0
    newline db 10, 0

section .bss
    sensor_value resb 1      ; Simulated sensor memory location
    motor_status resb 1      ; Simulated motor status memory location
    alarm_status resb 1      ; Simulated alarm status memory location
    input_buffer resb 10     ; Buffer for user input

section .text
    global _start

_start:
    ; Prompt user to enter water level
    mov eax, 4               ; syscall: sys_write
    mov ebx, 1               ; stdout
    mov ecx, prompt          ; Address of prompt message
    mov edx, 28              ; Length of the prompt
    int 0x80                 ; Execute syscall

    ; Read user input
    mov eax, 3               ; syscall: sys_read
    mov ebx, 0               ; stdin
    mov ecx, input_buffer    ; Buffer for input
    mov edx, 10              ; Max bytes to read
    int 0x80                 ; Execute syscall

    ; Convert input string to integer
    call string_to_int
    test eax, eax            ; Check if valid input
    js invalid_input         ; Jump to error if invalid

    ; Store the sensor value
    mov [sensor_value], al   ; Save water level in sensor memory location

    ; Decision logic based on sensor value
    cmp al, 40               ; If water level < 40
    jl water_low             ; Jump to water_low
    cmp al, 70               ; If water level > 70
    jg water_high            ; Jump to water_high
    jmp water_moderate       ; Otherwise, moderate

water_low:
    ; Turn motor ON
    mov byte [motor_status], 1   ; Set motor ON
    mov byte [alarm_status], 0   ; Clear alarm
    ; Display motor ON message
    mov eax, 4                   ; syscall: sys_write
    mov ebx, 1                   ; stdout
    mov ecx, low_msg             ; Address of message
    mov edx, 28                  ; Length of message
    int 0x80                     ; Execute syscall
    jmp end_program              ; Exit program

water_high:
    ; Trigger ALARM
    mov byte [motor_status], 0   ; Set motor OFF
    mov byte [alarm_status], 1   ; Set alarm ON
    ; Display alarm triggered message
    mov eax, 4                   ; syscall: sys_write
    mov ebx, 1                   ; stdout
    mov ecx, high_msg            ; Address of message
    mov edx, 35                  ; Length of message
    int 0x80                     ; Execute syscall
    jmp end_program              ; Exit program

water_moderate:
    ; Turn motor OFF
    mov byte [motor_status], 0   ; Set motor OFF
    mov byte [alarm_status], 0   ; Clear alarm
    ; Display motor OFF message
    mov eax, 4                   ; syscall: sys_write
    mov ebx, 1                   ; stdout
    mov ecx, moderate_msg        ; Address of message
    mov edx, 32                  ; Length of message
    int 0x80                     ; Execute syscall

end_program:
    ; Exit program
    mov eax, 1                   ; syscall: sys_exit
    xor ebx, ebx                 ; Exit code 0
    int 0x80

invalid_input:
    ; Handle invalid input
    mov eax, 4                   ; syscall: sys_write
    mov ebx, 1                   ; stdout
    mov ecx, newline             ; Print newline
    mov edx, 1                   ; Length
    int 0x80
    mov eax, 1                   ; syscall: sys_exit
    xor ebx, ebx                 ; Exit code 0
    int 0x80

; Subroutine: Convert string to integer
; Input: Address of string in ECX
; Output: AL contains the integer (negative for invalid input)
string_to_int:
    xor eax, eax                 ; Clear EAX for the result
    xor ebx, ebx                 ; Clear EBX for digit parsing
    mov esi, input_buffer        ; Address of input buffer

convert_loop:
    mov bl, byte [esi]           ; Load the current character
    cmp bl, 10                   ; Check for newline
    je end_conversion            ; End of input
    cmp bl, ' '                  ; Ignore spaces
    je skip_character
    sub bl, '0'                  ; Convert ASCII to integer
    jl invalid_conversion        ; Invalid input (non-digit)
    cmp bl, 9
    jg invalid_conversion        ; Invalid input (non-digit)
    imul eax, eax, 10            ; Multiply result by 10
    add eax, ebx                 ; Add the current digit
skip_character:
    inc esi                      ; Move to the next character
    jmp convert_loop             ; Repeat for next character

invalid_conversion:
    mov eax, -1                  ; Indicate invalid input
end_conversion:
    ret
