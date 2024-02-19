section .data
    resultMsg db 'Result: ', 0

section .bss
    res resb 1

section .text
global _start

_start:
    mov al, 3               ; b - c = 3 - 2
    sub al, 2
    add al, 5               ; + a = 5

    ; Сохраняем результат для вывода
    add al, '0'             ; Преобразуем число в символ
    mov [res], al

    ; Выводим сообщение
    mov rax, 1              ; Системный вызов для записи
    mov rdi, 1              ; Дескриптор файла (stdout)
    lea rsi, [resultMsg]    ; Сообщение для вывода
    mov rdx, 8              ; Длина сообщения
    syscall

    ; Выводим результат
    mov rax, 1              ; Системный вызов для записи
    mov rdi, 1              ; Дескриптор файла (stdout)
    lea rsi, [res]          ; Адрес результата
    mov rdx, 1              ; Размер результата (1 байт)
    syscall

    ; Завершение программы
    mov rax, 60             ; Системный вызов для выхода
    xor rdi, rdi            ; Код возврата
    syscall