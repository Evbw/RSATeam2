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
	BEQ gcdLib
	CMP r0, #3
	BEQ moduloLib
	CMP r0, #4
	BEQ cpubexpLib
	CMP r0, #5
	BEQ isPrimeLib

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
	
	moduloLib:

		LDR r0, =moduloPrompt
		BL printf

		LDR r0, =input
		LDR r1, =num
		BL scanf

		LDR r7, =num
		LDR r7, [r7]

		LDR r0, =moduloPrompt2
		BL printf
	
		LDR r0, =input
		LDR r1, =num
		BL scanf

		LDR r1, =num
		LDR r1, [r1]

		MOV r0, r7
		BL modulo
		MOV r1, r0

		LDR r0, =moduloOutput
		BL printf
		B MenuLoop
	
	cpubexpLib:

		LDR r0, =cpubexpPrompt
		BL printf

		LDR r0, =input
		LDR r1, =num
		BL scanf

		LDR r7, =num
		LDR r7, [r7]

		LDR r0, =cpubexpPrompt2
		BL printf
	
		LDR r0, =input
		LDR r1, =num
		BL scanf

		MOV r0, r7

		LDR r1, =num
		LDR r1, [r1]
		BL cpubexp

		MOV r1, r0
		LDR r0, =cpubexpLibOutput
		BL printf
		B MenuLoop

	isPrimeLib:

		LDR r0, =isprimePrompt
		BL printf

		LDR r0, =input
		LDR r1, =num
		BL scanf

		LDR r1, =num
		LDR r1, [r1]
		BL isPrime

		MOV r1, r0
		LDR r0, =isprimeOutput
		BL printf
		B MenuLoop

	EndProgram:

	LDR lr, [sp]
	ADD sp, sp, #4
	MOV pc, lr

.data
	prompt: .asciz "Please choose to create a power (1), find the greatest common denominator (2), find the modulus (3), create a public exponent (4), check if a number is prime (5), or exit with (-1):\n"
	powPrompt: .asciz "Please enter a number:\n"
	powPrompt2: .asciz "Please enter an exponent:\n"
	gcdPrompt: .asciz "Please enter a term:\n"
	gcdPrompt2: .asciz "Please enter a second term:\n"
	moduloPrompt: .asciz "Please enter a dividend:\n"
	moduloPrompt2: .asciz "Please enter a divisor:\n"
	cpubexpPrompt: .asciz "Please enter a p < 50:\n"
	cpubexpPrompt2: .asciz "Please enter a q < 50:\n"
	isprimePrompt: .asciz "Please enter a number to see if it is prime:\n"
	input: .asciz "%d"
	num: .word 0
	powOutput: .asciz "The result is %d.\n"
	gcdOutput: .asciz "The greatest common denominator is %d.\n"
	moduloOutput: .asciz "The modulus is %d.\n"
	cpubexpLibOutput: .asciz "The public exponent is %d.\n"
	isprimeOutput: .asciz "If it is 1, it's not prime. If it's 0, it is prime: %d\n"
	
