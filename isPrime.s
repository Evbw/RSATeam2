.text
.global main

main:
    // push stack record
    SUB sp, sp, #4
    STR lr, [sp]

    // Function dictionary
    // r4 - number for prime check
    // r5 - divisor

	LDR r0, =input
	LDR r1, =num
	BL scanf

	LDR r0, =num
	LDR r0, [r0]

    // Check if prime
    MOV r4, r0
    MOV r5, #2

    CMP r4, #2
    BNE elsif1
        // Statement if r4 == 2
        MOV r0, #1
        B endIf1
    elsif1:
        CMP r4, #2
        BGT else
        // Statement if r4 < 2
        MOV r0, #0
        B endIf1
    else:
        // Statement if r4 > 2
        MUL r1, r5, r5
        CMP r1, r4
        BGT Prime

        // r0 = number for prime check
        // r1 = divisor
        MOV r0, r4
        MOV r1, r5
        BL __aeabi_idiv
        // r0 = divided result
        MUL r2, r0, r1
        SUB r3, r4, r2
        CMP r3, #0
        BEQ notPrime

        ADD r5, r5, #1
        B else

        Prime:
            MOV r1, #1
		LDR r0, =pout
		BL printf
            B endIf1
        notPrime: 
            MOV r1, #0
		LDR r0, =npout
		BL printf
           B endIf1

    endIf1:

    // pop stack record
    LDR lr, [sp]
    ADD sp, sp, #4
    MOV pc, lr

.data
	input: .asciz "%d"
	num: .word 0
	pout: .asciz "%d"
	npout: .asciz "%d"
