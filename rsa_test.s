.data
prompt:      .asciz "Enter a message to encrypt: "
fmtstr:      .asciz "%s"
filename:    .asciz "ciphertext.txt"
fmode:       .asciz "w"
outputfmt:   .asciz "%d\n"
error_msg: .asciz "Error: Could not open file for writing.\n"

e_val:       .word 59          @ Public exponent
n_val:       .word 517         @ Modulus

msgbuf:      .space 100        @ Input buffer (max 99 chars + null)
fileptr:     .word 0

.text
.global _start
.extern printf, scanf, fopen, fprintf, fclose
.extern encrypt

_start:
    @ Prompt user
    LDR r0, =prompt
    BL printf

    @ Read string
    LDR r0, =fmtstr
    LDR r1, =msgbuf
    BL scanf

    @ Open file for writing
    LDR r0, =filename
    LDR r1, =fmode
    BL fopen
    CMP r0, #0
    BEQ file_open_fail     @ If fopen returned NULL
    LDR r1, =fileptr
    STR r0, [r1]
    
    B continue_main
    
file_open_fail:
    @ Print error and exit
    LDR r0, =error_msg
    BL printf
    MOV r0, #1
    BX lr

continue_main:   

    @ Load keys
    LDR r4, =e_val
    LDR r4, [r4]         @ r4 = e

    LDR r5, =n_val
    LDR r5, [r5]         @ r5 = n

    @ String loop setup
    LDR r6, =msgbuf      @ r6 = pointer to msgbuf

encrypt_loop:
    LDRB r0, [r6]        @ r0 = current char
    CMP r0, #0           @ Null terminator?
    BEQ done_encrypt

    @ Save ASCII value (already in r0), r1 = e, r2 = n
    MOV r1, r4
    MOV r2, r5
    BL encrypt           @ Result in r0
    MOV r3, r0

    @ Get file pointer
    LDR r1, =fileptr
    LDR r0, [r1]

    @ Print to file
    LDR r1, =outputfmt
    MOV r2, r3        @ Encrypted value in r3 (see fix below)
    BL fprintf

    ADD r6, r6, #1       @ Next char
    B encrypt_loop

done_encrypt:
    @ Close file
    LDR r0, =fileptr
    LDR r0, [r0]
    BL fclose

    @ Exit cleanly
    MOV r0, #0
    BX lr
