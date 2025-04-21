// File: test_encrypt.s
.global main
.text
main:
    // Push lr
    SUB sp, sp, #4
    STR lr, [sp]

    // Test Case 1: m = 65 ('A'), e = 3, n = 187
    MOV r0, #65     // m = 'A'
    MOV r1, #3      // e = 3
    MOV r2, #187    // n = 187
    BL encrypt      // r0 = c = (65^3) % 187 = 83

    // Print result
    MOV r1, r0
    LDR r0, =resultFmt
    BL printf

    // Restore lr and return
    LDR lr, [sp]
    ADD sp, sp, #4
    MOV pc, lr

.data
    resultFmt: .asciz "Encrypted output: %d\n"
