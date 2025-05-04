.global main
.extern printf
.extern scanf
.extern fopen
.extern fscanf
.extern fprintf
.extern decrypt
.extern isPrime
.extern cprivexp
.extern gcd

.section .data
prompt_n:      .asciz "Enter modulus n: "
prompt_e:      .asciz "Enter public exponent e: "
decryptPrompt: .asciz "Decrypting...\n"

encryptedFile:         .asciz "encrypted.txt"
plaintextFile:         .asciz "plaintext.txt"
fileReadMode:          .asciz "r"
fileWriteMode:         .asciz "w"
decryptReadingFormat:  .asciz "%d"
decryptWritingFormat:  .asciz "%c"
scanfFormat:           .asciz "%d"

.section .bss
nVal:        .word 0
eVal:        .word 0
totient:     .word 0
privkey:     .word 0
decryptNum:  .word 0
in_fp:       .word 0
out_fp:      .word 0

.section .text

main:
    PUSH {lr}

    @ Prompt for modulus (n)
    LDR r0, =prompt_n
    BL printf
    LDR r0, =scanfFormat
    LDR r1, =nVal
    BL scanf

    @ Prompt for public exponent (e)
    LDR r0, =prompt_e
    BL printf
    LDR r0, =scanfFormat
    LDR r1, =eVal
    BL scanf

    @ Calculate φ(n) = (p-1)*(q-1) — assume φ(n) is provided or hardcoded here for now
    @ You can replace this with actual factorization if desired
    @ For example: n = 3233 → p = 61, q = 53 → φ(n) = 3120

    LDR r0, =nVal
    LDR r7, [r0]              @ r7 = n (modulus)

    MOV r0, #3120             @ set totient manually (replace with calc if desired)
    LDR r1, =eVal
    LDR r1, [r1]
    BL cprivexp               @ r0 = private exponent (d)
    LDR r1, =privkey
    STR r0, [r1]
    MOV r5, r0                @ r5 = d
    @ r7 = n already
    LDR r0, =decryptPrompt
    BL printf

    @ Open encrypted.txt
    LDR r0, =encryptedFile
    LDR r1, =fileReadMode
    BL fopen
    LDR r1, =in_fp
    STR r0, [r1]

    @ Open plaintext.txt
    LDR r0, =plaintextFile
    LDR r1, =fileWriteMode
    BL fopen
    LDR r1, =out_fp
    STR r0, [r1]

decrypt_loop:
    @ fscanf(in_fp, "%d", &decryptNum)
    LDR r0, =in_fp
    LDR r0, [r0]
    LDR r1, =decryptReadingFormat
    LDR r2, =decryptNum
    BL fscanf
    CMP r0, #1
    BNE decrypt_done

    LDR r0, =decryptNum
    LDR r0, [r0]         @ r0 = ciphertext
    MOV r1, r5           @ r1 = d (private key)
    MOV r2, r7           @ r2 = n (modulus)
    BL decrypt           @ r0 = plaintext char

    @ fprintf(out_fp, "%c", char)
    MOV r2, r0
    LDR r0, =out_fp
    LDR r0, [r0]
    LDR r1, =decryptWritingFormat
    BL fprintf

    B decrypt_loop

decrypt_done:
    MOV r0, #0
    POP {lr}
    BX lr

