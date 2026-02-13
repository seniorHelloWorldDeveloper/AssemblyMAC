;; gets the first active interface that is up, is not loopback and is running

global get_active_interface


section .bss
    ifRequests resb 640 ;16 structs, every one is 40 bytes
    ifconf reso 1 ;16 bytes of ifconf struct
    global interface
    interface resb 16
    register resw 1
section .text
    get_active_interface:
        mov rax, 41
        mov rdi, 2
        mov rsi, 2
        mov rdx, 0
        syscall


        mov r9, rax
        mov r10, ifRequests
        mov dword [ifconf], 640
        mov [ifconf+8], r10

        mov rax, 16
        mov rdi, r9
        mov rsi, 0x8912
        mov rdx, ifconf
        syscall

        cdq
        mov eax, dword [ifconf]
        mov ecx, 40
        div ecx

        movsxd r13, eax
        xor rbx, rbx
    mainloop:
        cmp rbx,r13
        je exit

        mov r10, rbx

        imul r10, 40

        mov r14, ifRequests

        mov rax, 16
        mov rdi, r9
        mov rsi, 0x8913
        lea rdx, [r14+r10]
        syscall

        ;flags

        mov ax, word [rdx+16]
        test ax, 8
        jnz continue

        test ax, 1
        jz continue

        test ax, 0x40
        jz continue
        lea rdx, [ifRequests+r10]
        xor r12, r12

    interfaceLength:
        cmp byte [rdx+r12], 0
        je endInterfaceLength

        inc r12
        jmp interfaceLength
    endInterfaceLength:
        mov rsi, rdx
        mov rdi, interface
        mov rcx, r12
        rep movsb
        jmp exit


    continue:
        inc rbx
        jmp mainloop

    exit:
        ret
