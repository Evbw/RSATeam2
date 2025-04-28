.text
.global main

main:
    	SUB sp, sp, #4
    	STR lr, [sp, #0]

    	MOV  r0, #2
    	MOV  r1, #5
    	MOV  r2, #13       // load modulus (too big for MOV)

    	BL modExp

    	MOV r1, r0
    	LDR r0, =testOutput
    	BL printf

   	LDR lr, [sp, #0]
    	ADD sp, sp, #4
    	MOV pc, lr


// ===========================================
// Modular Exponentiation: r0 = (base^exponent) % modulus
// ===========================================
modExp:
	// Inputs:
	//     r0 - base
	//     r1 - exponent
	//     r2 - modulus
	// Ouputs:
	//     r0 - pow mod

	// Function dictionary
	// r4 - base
	// r5 - exponent
	// r6 - modulus
	// r7 - initial result

	SUB sp, sp, #20
	STR lr, [sp, #0]
	STR r4, [sp, #4]
	STR r5, [sp, #8]
	STR r6, [sp, #12]
	STR r7, [sp, #16]

	MOV r7, #1
	MOV r4, r0
	MOV r5, r1
	MOV r6, r2

	MOV r1, r2
	BL modulo  // r0 = base % modulus

	CMP r0, #0
	BEQ skip  // return r0 == 0

	startModLoop:

		CMP r5, #0
		BLE endModLoop  // while(exponent > 0)

		AND r0, r5, #1
		CMP r0, #1
		MUL r7, r7, r4
		MOV r0, r7
		MOV r1, r6
		BL modulo
		MOV r7, r0  // r7 = (r7 * base) % modulus

		LSR r5, r5, #1  // exp = exp // 2
		MUL r4, r4, r4
		MOV r0, r4
		MOV r1, r6
		BL modulo
		MOV r4, r0  // r4 = (r4 * r4) % r6

	endModLoop:

	MOV r0, r7

	skip:

	LDR lr, [sp, #0]
	LDR r4, [sp, #4]
	LDR r5, [sp, #8]
	LDR r6, [sp, #12]
	LDR r7, [sp, #16]
	ADD sp, sp, #20
	MOV pc, lr	

modulo:
 
# Push the stack

    SUB sp, sp, #20
    STR lr, [sp, #0]
    STR r2, [sp, #4]
    STR r3, [sp, #8]
    STR r5, [sp, #12]
    STR r6, [sp, #16]

# Perform division
    MOV r5, r0            // Save r0, dividend
    MOV r6, r1            // Save r1, divisor
    BL __aeabi_idiv       // Call division (quotient in r0)


# Store the quotient
	MOV r2, r0			// r2 = quotient

# Multiply the quotient by the divisor

	MOV r3, r2            // Ensure different register for MUL
	MUL r2, r3, r6        // r2 = quotient * divisor


# Subtract to get the remainder
	SUB r0, r5, r2			// r0 = dividend - (quotient * divisor)

 # Ensure result is non-negative
	CMP r0, #0
	BGE skip_fix
	ADD r0, r0, r1		// Make it positive if needed

	skip_fix:

# Pop the stack (and return to the OS)

    LDR lr, [sp, #0]
    LDR r2, [sp, #4]
    LDR r3, [sp, #8]
    LDR r5, [sp, #12]
    LDR r6, [sp, #16]
    ADD sp, sp, #20
    MOV pc, lr	


.data
testOutput: .asciz "The answer is %d\n"

