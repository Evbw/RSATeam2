.text
.global main
main:
	SUB sp, sp, #4
	STR lr, [sp, #0]

	MOV r0, #65
	MOV r1, #37
	MOV r2, #551
	BL modExp

	MOV r1, r0
	LDR r0, =testOutput
	BL printf

	LDR lr, [sp, #0]
	ADD sp, sp, #4
	MOV pc, lr


.data
	testOutput: .asciz "The answer is %d\n"


// START
.text
modExp:
// Arguments:
// r0 = base
// r1 = exponent
// r2 = modulus
// Return:
// r0 = (base^exponent) % modulus
    push {r1-r4, lr}        // Save registers we will use
    mov r3, #1              // r3 = result = 1

mod_exp_loop:
    cmp r1, #0              // while exponent > 0
    beq mod_exp_done

    and r12, r1, #1         // if (exponent & 1)
    cmp r12, #0
    beq skip_multiply

    // result = (result * base) % modulus
    mul r12, r3, r0         // r12 = result * base
    mov r0, r12             // move numerator into r0 for division
    mov r1, r2              // move denominator into r1 for division
    bl __aeabi_idiv         // call software integer division (r0 = r0 / r1)
    mul r4, r0, r2          // r4 = (quotient) * modulus
    sub r3, r12, r4         // r3 = (result * base) - (quotient * modulus)

skip_multiply:
    // base = (base * base) % modulus
    mul r12, r0, r0         // r12 = base * base
    mov r0, r12             // numerator
    mov r1, r2              // denominator
    bl __aeabi_idiv         // call software division
    mul r4, r0, r2          // r4 = (quotient) * modulus
    sub r0, r12, r4         // base = (base * base) - (quotient * modulus)

    // exponent >>= 1
    lsrs r1, r1, #1
    b mod_exp_loop

mod_exp_done:
    mov r0, r3              // result -> r0
    pop {r1-r4, pc}         // restore and return

