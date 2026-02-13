global _start

extern get_active_interface
extern interface

section .data
    exiting db "Exiting the program..", 10
    exitingLength equ $-exiting
    errorInitSocket db "Error in init socket", 10
    errorInitSocketLength equ $-errorInitSocket
    errorIoctlMsg db "Error in init ioctl", 10
    errorIoctlMsgLength equ $-errorIoctlMsg
    printingMacAddress db "Printing mac address..", 10
    printingMacAddressLength equ $-printingMacAddress
    hexDigits db "0123456789abcdef"
    socketClosed db "Socket closed", 10
    socketClosedLength equ $-socketClosed
    closeSocketErrorMessage db "Error closing socket", 10
    closeSocketErrorMessageLength equ $-closeSocketErrorMessage
    ifr:
        times 40 db 0

section .bss
    macAddress resb 18      ; 17 = mac, last = 10 (new line)

section .text
    _closeSocket:

        mov rax, 3
        mov rdi, r9
        syscall

        test rax, rax
        js _closeErrorSocket

        mov rax, 1
        mov rdi, 1
        mov rsi, socketClosed
        mov rdx, socketClosedLength
        syscall
        ret

    _closeErrorSocket:
        mov rax, 1
        mov rdi, 1
        mov rsi, closeSocketErrorMessage
        mov rdx, closeSocketErrorMessageLength
        syscall
        ret

    _start:
        call get_active_interface
        ;socket fd in r9
        mov rdi, ifr
        mov rsi, interface
        mov rcx, r12
        rep movsb

        ; socket already init


        ; mov rax, 41
        ; mov rdi, 2
        ; mov rsi, 2
        ; mov rdx, 0
        ; syscall
        ; mov r9, rax
        test rax, rax
        js _socketInitError

        mov rdi, r9
        mov rsi, 0x8927
        lea rdx, [rel ifr]
        mov rax, 16
        syscall
        test rax, rax
        js _erorIoctl

        xor rdx, rdx
        lea rsi, [rel ifr + 18]
        lea rdi, [rel macAddress]
        lea r8, [rel hexDigits]

    _macAddressStoreLoop:
        cmp rdx, 6
        je _doneSavingMac
        mov al, [rsi + rdx]

        mov bl, al
        shr al, 4
        and al, 0x0F
        movzx rcx, al
        mov al, [r8 + rcx]
        mov [rdi], al
        inc rdi

        mov al, bl
        and al, 0x0F
        movzx rcx, al
        mov al, [r8 + rcx]
        mov [rdi], al
        inc rdi

        cmp rdx, 5
        je _no_sep
        mov byte [rdi], ':'
        inc rdi
    _no_sep:
        inc rdx
        jmp _macAddressStoreLoop

    _doneSavingMac:
        mov byte [rdi], 10
        inc rdi

        mov rax, 1
        mov rdi, 1
        lea rsi, [rel macAddress]
        mov rdx, 18
        syscall

        jmp _exit

    _socketInitError:
        mov rax, 1
        mov rdi, 1
        mov rsi, errorInitSocket
        mov rdx, errorInitSocketLength
        syscall
        jmp _exit

    _erorIoctl:
        mov rax, 1
        mov rdi, 1
        mov rsi, errorIoctlMsg
        mov rdx, errorIoctlMsgLength
        syscall
        jmp _exit

    _exit:
        call _closeSocket
        mov rax, 60
        xor rdi, rdi
        syscall
