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
	BEQ cprivexpLib
	CMP r0, #6
	BEQ isPrimeLib
	CMP r0, #7
	BEQ encryptLib
	CMP r0, #8
	BEQ decryptLib

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

		LDR r7, =num  // holding p
		LDR r7, [r7]

		LDR r0, =cpubexpPrompt2
		BL printf
	
		LDR r0, =input
		LDR r1, =num
		BL scanf

		MOV r0, r7  // holding p

		LDR r1, =num
		LDR r1, [r1]  // holding q
		BL cpubexp

		MOV r3, r2
		MOV r2, r1
		MOV r1, r0
		LDR r0, =cpubexpLibOutput
		BL printf
		B MenuLoop

	cprivexpLib:

		LDR r0, =cprivexpPrompt
		BL printf

		LDR r0, =input
		LDR r1, =cprivexpInput1
		BL scanf

		LDR r7, =cprivexpInput1
		LDR r7, [r7]

		LDR r0, =cprivexpPrompt2
		BL printf
	
		LDR r0, =input
		LDR r1, =cprivexpInput2
		BL scanf

		MOV r0, r7

		LDR r1, =cprivexpInput2
		LDR r1, [r1]
		BL cprivexp
		MOV r2, r1
		MOV r1, r0
		LDR r0, =cprivexpOutput
		BL printf
		B MenuLoop

	isPrimeLib:

		LDR r0, =isprimePrompt
		BL printf

		LDR r0, =input
		LDR r1, =num
		BL scanf

		LDR r0, =num
		LDR r0, [r0]
		BL isPrime

		MOV r1, r0
		LDR r0, =isprimeOutput
		BL printf
		B MenuLoop

	encryptLib:

		// Clear leftover newline from previous scanf
		LDR r0, =characterInput       // "%c"
		LDR r1, =encryptInput1        // Use any temp space
		BL scanf                      // Dummy read to consume '\n'

		// Enter a character to encrypt
		LDR r0, =encryptPrompt
		BL printf
		LDR r0, =characterInput
		LDR r1, =encryptInput1
		BL scanf

		// Enter value for public key (e) and modulo (n)
		LDR r0, =encryptPrompt2
		BL printf
		LDR r0, =input
		LDR r1, =encryptInput2
		BL scanf

		LDR r0, =encryptPrompt3
		BL printf
		LDR r0, =input
		LDR r1, =encryptInput3
		BL scanf

		// Encrypt character
		LDR r0, =encryptInput1
		LDRB r0, [r0]  // r0 = decimal for character
		MOV r4, r0
		LDR r1, =encryptInput2
		LDR r1, [r1]
		LDR r2, =encryptInput3
		LDR r2, [r2]
		MOV r8, r2
		BL encrypt

		// Print result
		MOV r2, r0
		MOV r1, r4
		LDR r0, =encryptOutput
		BL printf
		B MenuLoop

	decryptLib:

		// Enter a character to decrypt

		// Enter ciphertext to decrypt
		LDR r0, =decryptPrompt
		BL printf
		LDR r0, =input
		LDR r1, =decryptInput1
		BL scanf

		// Enter value for private key (d) and modulo (n)
		LDR r0, =decryptPrompt2
		BL printf
		LDR r0, =input
		LDR r1, =decryptInput2
		BL scanf

		LDR r0, =decryptPrompt3
		BL printf
		LDR r0, =input
		LDR r1, =decryptInput3
		BL scanf

		LDR r0, =decryptInput1
		LDR r0, [r0]

		LDR r1, =decryptInput2
		LDR r1, [r1]

		LDR r2, =decryptInput3
		LDR r2, [r2]
		BL decrypt

		// Print result

		LDR r0, =decryptOutput
		BL printf
		B MenuLoop

	EndProgram:

	LDR lr, [sp]
	ADD sp, sp, #8
	MOV pc, lr

.data
	prompt: .asciz "Please choose to create a power (1), find the greatest common denominator (2), find the modulus (3), create a public exponent (4), create a private exponent (5), check if a number is prime (6), encrypt character (7), decrypt character (8), or exit with (-1):\n"
	powPrompt: .asciz "Please enter a number:\n"
	powPrompt2: .asciz "Please enter an exponent:\n"
	gcdPrompt: .asciz "Please enter a term:\n"
	gcdPrompt2: .asciz "Please enter a second term:\n"
	moduloPrompt: .asciz "Please enter a dividend:\n"
	moduloPrompt2: .asciz "Please enter a divisor:\n"
	cpubexpPrompt: .asciz "Requirement: p < 50, p is prime. Please enter a value for p: \n"
	cpubexpPrompt2: .asciz "Requirement: q < 50, q is prime. Please enter a value for q: \n"
	cprivexpPrompt: .asciz "Please enter value for public key (e): \n"
	cprivexpPrompt2: .asciz "Please enter value for totient: \n"
	isprimePrompt: .asciz "Please enter a number to see if it is prime:\n"
	encryptPrompt: .asciz "Please enter a character: \n"
	encryptPrompt2: .asciz "Please enter a value for the public key (e): \n"
	encryptPrompt3: .asciz "Please enter a value for the modulo (n): \n"
	decryptPrompt: .asciz "Please enter ciphertext to decrypt: \n"
	decryptPrompt2: .asciz "Please enter a value for the private key (d): \n"
	decryptPrompt3: .asciz "Please enter a value for the modulo (n): \n"
	characterInput: .asciz "%c"
	input: .asciz "%d"
	num: .word 0
	encryptInput1: .space 2
	decryptInput1: .asciz "%d"
	decryptChar: .space 100
	encryptInput2: .word 0
	encryptInput3: .word 0
	decryptInput2: .word 0
	decryptInput3: .word 0
	cprivexpInput1: .word 0
	cprivexpInput2: .word 0
	powOutput: .asciz "The result is %d.\n"
	gcdOutput: .asciz "The greatest common denominator is %d.\n"
	moduloOutput: .asciz "The modulus is %d.\n"
	cpubexpLibOutput: .asciz "The public key is %d.\nThe totient is %d.\nn is %d.\n\n"
	cprivexpOutput: .asciz "The private key is: %d. The value for x is: %d. Don't tell anyone.\n\n"
	isprimeOutput: .asciz "Result: %d\nZero is not prime, one is prime.\n\n"
	encryptOutput: .asciz "The encrypted ciphertext for character %c is %d.\n\n"
	decryptOutput: .asciz "The decryption for ciphertext %d is %d.\n\n"
