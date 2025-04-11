.global modulo


// Made a slight change to the registers to fix the multiplication errors I was having during testing.  See the picture for test results.
.text
# int modulo(int dividend, int divisor)
# r0 = dividend
# r1 = divisor
# returns r0 = dividend % divisor
modulo:
    SUB sp, sp, #8
    STR lr, [sp, #0]
    STR r1, [sp, #4]

    MOV r5, r0            // Save dividend
    BL __aeabi_idiv       // Call division (quotient in r0)

    MOV r2, r0            // r2 = quotient
    MOV r3, r2            // Ensure different register for MUL
    MUL r2, r3, r1        // r2 = quotient * divisor

    SUB r0, r5, r2        // r0 = dividend - (quotient * divisor)

    LDR lr, [sp, #0]
    LDR r1, [sp, #4]
    ADD sp, sp, #8
    MOV pc, lr
