//
// Program Name: main.s
// Section 81 Team 2
// Purpose: Encrypt sender's message to be decrypted and read by receiver
//

.text
.global main

main:
	// Register usage:
	// r4 - public key (e)
	// r5 - private key (d)
	// r6 - totient (φ(n))
	// r7 - modulus (n)
	// r8 - message index register (for iterating through characters)

	// Save link register to stack (function return support)
	SUB sp, sp, #4
	STR lr, [sp, #0]

	// Print introduction prompt
	LDR r0, =introPrompt
	BL printf

// START: Loop to get valid 'p' value
p_StartLoop:
	LDR r0, =prompt1			// Prompt user for p
	BL printf
	LDR r0, =format1			// Set scanf format
	LDR r1, =pValue				// Set memory location to store input
	BL scanf

	LDR r0, =pValue				// Load input value
	LDR r0, [r0]
	CMP r0, #0
	MOVLE r1, #0				// If p ≤ 0, set r1 = 0
	MOVGT r1, #1				// If p > 0, set r1 = 1
	BL isPrime 					// Check if r0 is prime (result in r0)
	AND r0, r0, r1				// Ensure input is positive and prime
	CMP r0, #1
	BNE p_error					// Invalid p value
	B p_EndLoop					// Valid p value
p_error:
	LDR r0, =p_ErrorMsg1
	BL printf
	B p_StartLoop				// Retry

p_EndLoop:

// START: Loop to get valid 'q' value
q_StartLoop:
	LDR r0, =prompt2
	BL printf
	LDR r0, =format1
	LDR r1, =qValue
	BL scanf

	LDR r0, =qValue
	LDR r0, [r0]
	CMP r0, #0
	MOVLE r1, #0
	MOVGT r1, #1
	BL isPrime
	AND r0, r0, r1
	CMP r0, #1
	BNE q_error
	B q_EndLoop
q_error:
	LDR r0, =q_ErrorMsg1
	BL printf
	B q_StartLoop

q_EndLoop:

	// Generate public exponent, totient, and modulus
	LDR r0, =pValue
	LDR r0, [r0]
	LDR r1, =qValue
	LDR r1, [r1]
	BL cpubexp					// Outputs: r0=e, r1=φ(n), r2=n
	MOV r4, r0					// Store e
	MOV r6, r1					// Store φ(n)
	MOV r7, r2					// Store n

	// Generate private key (d)
	BL cprivexp					// Inputs: e, φ(n); Output: d
	MOV r5, r0

	B MenuLoop					// Go to main menu

// START: Menu loop
MenuLoop:
	LDR r0, =menuPrompt
	BL printf
	LDR r0, =input
	LDR r1, =num
	BL scanf
	LDR r0, =num
	LDR r0, [r0]
	CMP r0, #-1
	BLE EndProgram
	CMP r0, #1
	BEQ p_StartLoop				// Regenerate p & q
	CMP r0, #2
	BEQ EncryptSection
	CMP r0, #3
	BGE DecryptSection

// ----- START ENCRYPT SECTION -----
EncryptSection:
	LDR r0, =messagePrompt
	BL printf
	BL getchar					// Clear input buffer newline
	LDR r0, =stringFormat
	LDR r1, =messageBuffer
	BL scanf					// Read full line message

	// Open encrypted file in write mode
	LDR r0, =encryptedFile
	LDR r1, =fileWriteMode
	BL fopen
	LDR r1, =fp
	STR r0, [r1]				// Store file pointer

	LDR r8, =messageBuffer		// Initialize message pointer

encrypt_loop:
	LDRB r3, [r8]				// Load byte (char) from message
	CMP r3, #0					// Verifit this is the end of the string
	BEQ encrypt_done

	MOV r0, r3					// char to encrypt
	MOV r1, r4					// public key (e)
	MOV r2, r7					// modulus (n)
	BL encrypt					// r0 = encrypted int

	MOV r2, r0					// r2 = encrypted value
	LDR r1, =encryptWritingFormat
	LDR r3, =fp
	LDR r0, [r3]				// Load file pointer
	BL fprintf 					// Write encrypted value to file

	ADD r8, r8, #1				// Move to next char
	B encrypt_loop

encrypt_done:
	LDR r1, =fp
	LDR r0, [r1]
	BL fclose					// Close encrypted file
	LDR r0, =encryptSuccess
	BL printf
	B MenuLoop

// ----- START DECRYPT SECTION -----
DecryptSection:
	// Open encrypted input file
	LDR r0, =encryptedFile
	LDR r1, =fileReadMode
	BL fopen
	LDR r1, =in_fp
	STR r0, [r1]

	// Open plaintext output file
	LDR r0, =plaintextFile
	LDR r1, =fileWriteMode
	BL fopen
	LDR r1, =out_fp
	STR r0, [r1]

decrypt_loop:
	LDR r0, =in_fp
	LDR r0, [r0]				// Load file pointer
	LDR r1, =decryptReadingFormat
	LDR r2, =decryptNum			// Store integer read
	BL fscanf
	CMP r0, #1					// Check if read was successful
	BNE decrypt_done

	LDR r0, =decryptNum
	LDR r0, [r0]				// Load encrypted value
	MOV r1, r5					// private key (d)
	MOV r2, r7					// modulus (n)
	BL decrypt 					// r0 = decrypted char

	MOV r2, r0
	LDR r0, =out_fp
	LDR r0, [r0]				// Load output file pointer
	LDR r1, =decryptWritingFormat
	BL fprintf					// Write decrypted char to file

	B decrypt_loop

decrypt_done:
	LDR r0, =in_fp
	LDR r0, [r0]
	BL fclose 					// Close input file

	LDR r0, =out_fp
	LDR r0, [r0]
	BL fclose 					// Close output file

	LDR r0, =decryptSuccess
	BL printf
	B MenuLoop

// END: Program termination
EndProgram:
	MOV r0, #1
	LDR lr, [sp, #0]			// Restore link register
	ADD sp, sp, #4 				// Restore stack
	MOV pc, lr 					// Return

.data
introPrompt:	.asciz "Welcome to our RSA algorithm program. We first require a cipher:\n"
menuPrompt:		.asciz "Please choose an encryption (1), encrypt a message using that cipher (2), or decrypt a message using that cipher (3), or exit the program (-1):\n"
prompt1:		.asciz "Receiver, input a positive prime number for p: \n"
prompt2:		.asciz "Receiver, input a different positive prime number for q: \n"
decryptPrompt:	.asciz "Searching for a file named encrypted.txt:\n"
encryptSuccess:	.asciz "\nThe message has been encrypted and exported to encrypted.txt.\n\n"
decryptSuccess:	.asciz "\nThe message has been decrypted and exported to plaintext.txt.\n\n"

format1:		.asciz "%d"
stringFormat:	.asciz "%[^\n]"
input:			.asciz "%d"
num:			.word 0

pValue:			.word 0
qValue:			.word 0

p_ErrorMsg1:	.asciz "Invalid p value. Requirement: p must be a positive prime number.\n"
q_ErrorMsg1:	.asciz "Invalid q value. Requirement: q must be a different positive prime number.\n"

messagePrompt:			.asciz "Please enter the message to encrypt: \n"
encryptWritingFormat:	.asciz "%d\n"

messageBuffer:	.space 255
messageLength:	.word 100
cipherTextFile:	.asciz "encrypted.txt"

encryptedFile:	.asciz "encrypted.txt"
plaintextFile:	.asciz "plaintext.txt"
fileReadMode:	.asciz "r"
fileWriteMode:	.asciz "w"
cipherTextBuffer:	.space 4
plaintextBuffer:	.space 1
decryptNum:			.space 256
decryptReadingFormat:	.asciz "%d"
decryptWritingFormat:	.asciz "%c"

.bss
fp:		.skip 4
in_fp:	.skip 4
out_fp:	.skip 4
