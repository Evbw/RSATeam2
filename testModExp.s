.text
.global main
main:
    SUB sp, sp, #4
    STR lr, [sp, #0]

    MOV  r0, #65
    MOV  r1, #37
    LDR  r2, =551   // (use LDR because 551 is too big for MOV)

    BL modExp

    MOV r1, r0
    LDR r0, =testOutput
    BL printf

    LDR lr, [sp, #0]
    ADD sp, sp, #4
    MOV pc, lr

// =====================
// KEEP GOING WITH CODE
// =====================
modExp:
// Arguments:
// r0 = base
// r1 = exponent
// r2 = modulus
// Return:
// r0 = (base^exponent) % modulus
    push {r1-r4, lr}
    mov r3, #1

mod_exp_loop:
    cmp r1, #0
    beq mod_exp_done

    and r12, r1, #1
    cmp r12, #0
    beq skip_multiply

    mul r12, r3, r0         // r12 = result * base
    mov r0, r12             // numerator
    mov r4, r2              // copy modulus into r4
    mov r1, r4              // denominator
    bl __aeabi_idiv
    mul r4, r0, r2
    sub r3, r12, r4

skip_multiply:
    mul r12, r0, r0         // r12 = base * base
    mov r0, r12             // numerator
    mov r4, r2              // copy modulus into r4
    mov r1, r4              // denominator
    bl __aeabi_idiv
    mul r4, r0, r2
    sub r0, r12, r4

    lsrs r1, r1, #1         // exponent >>= 1
    b mod_exp_loop

mod_exp_done:
    mov r0, r3
    pop {r1-r4, pc}

// =====================
// AFTER ALL CODE
// =====================
.data
testOutput: .asciz "The answer is %d\n"
