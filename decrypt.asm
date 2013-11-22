; Developed for Intel syntax NASM on x86_64 Linux
; Uses the keys in 'keyfile'
; Reads data from file 'encrypted' and offsets every byte by the 
; negative value of first key, then multiplies by inverse mod 256 of second
; Stores the result in file 'decrypted'
; General structure is very similar to encryption
global _start

section .text
	
_start:
    ;open infile for reading
    mov rax,2
    mov rdi,infile
    mov rsi,0
    mov rdx,0
    syscall
    ;ifd will hold infile descriptor
    mov [ifd],rax
    
    ;open the keyfile for reading
    mov rax,2
    mov rdi,keyfile
    mov rsi,0
    mov rdx,0
    syscall
    ;kfd will hold the keyfile descriptor
    mov [kfd],rax

    ;read the key
    mov rax,0
    mov rdi,[kfd]
    mov rsi,key
    mov rdx,2
    syscall

    ;close keyfile
    mov rdi,[kfd]
    mov rax,3
    syscall

    ;as it stands, the second key will not work
    ;the actual key for decryption is the inverse of the second key
    ;there are a lot of neat tricks for finding an inverse modulo a power of 2
    ;however in this case it is found by brute force counting
    mov r10b,[key+1]
    mov r11b,r10b
    mov ah,1
    KeyLoop:
        inc ah
        add r11b,r10b
        cmp r11b,1
        je KeyLoopEnd
        jmp KeyLoop
    KeyLoopEnd:
    mov [truekey],ah

    ;open the outfile for replacement or creation
    mov rax,2
    mov rdi,outfile
    mov rsi,0q1101
    mov rdx,0q666
    syscall
    ;ofd will now hold the outfile descriptor
    mov [ofd],rax

IOLoop:

    ;read from the infile
    mov rax,0
    mov rdi,[ifd]
    mov rsi,buffer
    mov rdx,128
    syscall
    
    ;save to check for eof
    mov [eofcheck],al

    ;now loop over buffer to apply keys
    mov r8,0
    BufferLoop:
        mov r9b,[buffer+r8]
        sub r9b,[key]
        mov al,r9b
        mov bl,[truekey]
        mul bl
        mov [buffer+r8],al
        inc r8
        cmp r8,128
        jne BufferLoop

    ;write to the outfile
    mov rax,1
    mov rdi,[ofd]
    mov rsi,buffer
    mov rdx,128
    syscall

    xor r12,r12
    mov r12b,[eofcheck]
    cmp r12,128
    jne IOLoopExit
    jmp IOLoop

IOLoopExit:

    ;close outfile
    mov rdi,[ofd]
    mov rax,3
    syscall

    ;close infile
    mov rdi,[ifd]
    mov rax,3
    syscall

    ;exit
    mov rax,60
    mov rdi,0
    syscall

section .data
    ;store basic variables: filenames and key
    infile: db 'encrypted',0
    keyfile: db 'keyfile',0
    outfile: db 'decrypted',0
    key: times 2 db 0
    truekey: db 1
    ; IO buffer
    buffer: times 128 db 0
    eofcheck: db 0
    ;file descriptors
    ifd: dq 0
    ofd: dq 0
    kfd: dq 0
