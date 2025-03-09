.text
.global main

main:
	SUB sp, sp, #4
	STR lr, [sp, #0]
	
	LDR r0, =prompt1
	BL printf
	
	LDR r0, =input
	LDR r1, =num1
	BL scanf

	LDR r0, =num1
	LDR r0, [r0]
	MOV r5, r0
	
	LDR r0, =prompt2
	BL printf

	LDR r0, =input
	LDR r1, =num2
	BL scanf

	LDR r0, =num2
	LDR r0, [r0]
	MOV r6, r0

	CMP r6, r5
	BEQ Equal

	CMP r6, r5
	MOVGT r3, r6
	CMP r5, r6
	MOVLT r4, r5
	
	CMP r6, r5
	MOVLT r4, r6
	CMP r5, r6
	MOVGT r3, r5

	StartGCDLoop:
		CMP r3, r4
		BEQ EndGCDLoop

		SUB r2, r3, r4
		CMP r2, r4
		MOVGT r3, r2
		CMP r2, r4
		MOVLT r4, r3
		CMP r2, r4
		MOVLT r4, r2		
	
	EndGCDLoop:
		MOV r1, r3
		MOV r2, #1
		CMP r1, r2
		BEQ NoGCD

	Equal:
		MOV r1, r6
		LDR r0, =equalOutput
		BL printf
	
	NoGCD:
		LDR r0, =noCommon
		BL printf

	LDR lr, [sp, #0]
	ADD sp, sp, #4
	MOV pc, lr

.data
	prompt1: .asciz "Please enter the first term\n"
	prompt2: .asciz "Please enter the second term\n"
	equalOutput: .asciz "The values are the same: %d\n"
	noCommon: .asciz "Resulted in %d. There is no GCD.\n"
	input: .asciz "%d"
	num1: .word 0
	num2: .word 0
