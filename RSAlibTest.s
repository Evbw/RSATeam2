.text
.global main

main:
	SUB sp, sp, #8
	STR lr, [sp]

	MenuLoop:

	LDR r0, =prompt
	BL printf

	LDR r0, =input
	LDR r1, =num
	BL scanf

	LDR r0, =num
	LDR r0, [r0]

	CMP r0, #-1
	BEQ EndProgram
	CMP r0, #1
	BLE powLib
	CMP r0, #2
	BGE gcdLib

	powLib:
		LDR r0, =powPrompt
		BL printf
		
		LDR r0, =input
		LDR r1, =num
		BL scanf

		LDR r7, =num
		LDR r7, [r7]

		LDR r0, =powPrompt2
		BL printf

		LDR r0, =input
		LDR r1, =num
		BL scanf

		LDR r8, =num
		LDR r8, [r8]

		MOV r0, r7
		MOV r1, r8

		BL pow
		MOV r1, r0
		
		LDR r0, =powOutput
		BL printf
		B MenuLoop

	gcdLib:

		LDR r0, =gcdPrompt
		BL printf

		LDR r0, =input
		LDR r1, =num
		BL scanf

		LDR r7, =num
		LDR r7, [r7]

		LDR r0, =gcdPrompt2
		BL printf
	
		LDR r0, =input
		LDR r1, =num
		BL scanf

		LDR r1, =num
		LDR r1, [r1]

		MOV r0, r7
		BL gcd
		MOV r1, r0

		LDR r0, =gcdOutput
		BL printf
		B MenuLoop		
	
	EndProgram:

	LDR lr, [sp]
	ADD sp, sp, #4
	MOV pc, lr

.data
	prompt: .asciz "Please choose to create either a power (1) or find the greatest common denominator (2), or exit with (-1):\n"
	powPrompt: .asciz "Please enter a number:\n"
	powPrompt2: .asciz "Please enter an exponent:\n"
	gcdPrompt: .asciz "Please enter a term:\n"
	gcdPrompt2: .asciz "Please enter a second term:\n"
	input: .asciz "%d"
	num: .word 0
	powOutput: .asciz "The result is %d.\n"
	gcdOutput: .asciz "The greatest common denominator is %d.\n"
	
