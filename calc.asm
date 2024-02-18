org  0x100                  ; Indicate that this is a .COM program
section .data
    a db 5                  ; Define a = 5
    b db 3                  ; Define b = 3
    c db 2                  ; Define c = 2
    resultMsg db 'Result: $' ; Define the string for displaying the result

section .text
_start:
    mov al, [b]             ; Load b into al
    sub al, [c]             ; Subtract c from al
    add al, [a]             ; Add a to al

    ; Convert the result to an ASCII character (for single-digit numbers)
    add al, 30h             ; Convert the number to an ASCII character

    ; Display the result
    mov ah, 09h             ; DOS function for displaying a string
    lea dx, resultMsg       ; Set DX to the address of resultMsg
    int 21h                 ; Call DOS interrupt

    ; Display the number
    mov dl, al              ; Move the result into dl for display
    mov ah, 02h             ; DOS function for displaying a character
    int 21h                 ; Call DOS interrupt

    ; Terminate the program
    mov ax, 4c00h           ; DOS function to terminate the program
    int 21h                 ; Call DOS interrupt
