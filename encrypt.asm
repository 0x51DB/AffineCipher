; Developed for Intel syntax NASM on x86_64 Linux
; Generates keys in 'keyfile' using basic pseudo-random number generation
; Reads data from file 'message' and offsets every byte by the value of key
; Stores the result in file 'encrypted'
; Implements affine cipher, a m + k mod 256 = e
; a is second key relatively prime to 256, m is message, e is result
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
    
    ;open the keyfile for replacement or creation
    mov rax,2
    mov rdi,keyfile
    mov rsi,0q1101
    mov rdx,0q666
    syscall
    ;kfd will hold the keyfile descriptor
    mov [kfd],rax

    ;generate the keys
    ;this is a fairly basic program with no expectation of security,
    ;so whatever looks pseudo-random is good enough
    ;let's use the basic mod((time())
    ;this uses the lowest byte (seconds mod 256) for the first key
    ;this uses the 7 lowest bits of the next highest byte for the second key
    ;the first key changes every second but the second key changes only every 256 seconds
    ;this opens the implementation up to timing attacks - but that doesn't matter since
    ;it was already open to frequency attacks
    mov rax,201
    mov rdi,time
    syscall

    ;store the first key
    mov r8,[time]
    mov [key],r8b

    ;store the second key
    ;the second key is relatively prime to the message space
    ;since the message space is a power of 2, any odd number is relatively prime
    shr r8,7
    shl r8,1
    inc r8
    mov [key + 1],r8b
    
    ;write keys to keyfile
    mov rax,1
    mov rdi,[kfd]
    mov rsi,key
    mov rdx,2
    syscall

    ;close keyfile
    mov rdi,[kfd]
    mov rax,3
    syscall

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
        ;apply first key, then apply second key
        mov al,[buffer+r8]
        mov bl,[key+1]
        mul bl
        mov r9b,al
        add r9b,[key]
        mov [buffer+r8],r9b
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
    ;store basic variables: filenames, key, and time variable
    infile: db 'message',0
    keyfile: db 'keyfile',0
    outfile: db 'encrypted',0
    time: dq 0x0
    key: times 2 db 0
    ; IO buffer
    buffer: times 128 db 0
    eofcheck: db 0
    ;file descriptors
    ifd: dq 0
    ofd: dq 0
    kfd: dq 0
