//
// Program Name: RSA
// Authors: Ayush Goel, Calvin Tang, Conner Wright, Everett Bowline
// Section 81 Team 2
// Purpose: Encrypt sender's message to be decrypted and read by receiver
//

.global main

.text

  	// Program dictionary:
	// r4 - public key (e)
	// r5 - private key (d)
	// r6 - totient
	// r7 - modulus (n)
  	// r8 - encrypt, message index register

main:
	
//////////////////////////////////////////////////////////// 
// START RSA Encryption Setup Section
// Contributors: Calvin Tang
//////////////////////////////////////////////////////////// 

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
        	LDR r0, =input				// Set scanf format
        	LDR r1, =pValue				// Set memory location to store input
        	BL scanf

        	LDR r0, =pValue				// Load input value
        	LDR r0, [r0]
        	CMP r0, #0
		MOVLE r1, #0				// If p ≤ 0, set r1 = 0
		MOVGT r1, #1				// If p > 0, set r1 = 1
		BL isPrime 				// Check if r0 is prime (result in r0)
		AND r0, r0, r1				// Ensure input is positive and prime
		CMP r0, #1
		BNE p_error				// Invalid p value
		B p_EndLoop				// Valid p value
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

//////////////////////////////////////////////////////////// 
// END RSA Encryption Setup Section
//////////////////////////////////////////////////////////// 

//////////////////////////////////////////////////////////// 
// START Key Generation Section
// Contributors: Calvin Tang
//////////////////////////////////////////////////////////// 

	// Generate public exponent, totient, and modulus
	LDR r0, =pValue
	LDR r0, [r0]
	LDR r1, =qValue
	LDR r1, [r1]
	BL cpubexp			// Outputs: r0=e, r1=φ(n), r2=n
	
	MOV r4, r0  			// Store e: public key
	MOV r6, r1  			// Store φ(n): totient
	MOV r7, r2  			// Store n: modulus

	// Generate private key (d)
	BL cprivexp			// Inputs: e, φ(n); Output: d
	MOV r5, r0  			// Store d: private key

	// Output encryption info to Receiver
	LDR r0, =RSAValuesOutput
	LDR r1, =pValue
	LDR r1, [r1]
	LDR r2, =qValue
	LDR r2, [r2]
	MOV r3, r7
	BL printf

	//LDR r0, =RSAValuesOutput2
	//MOV r1, r6
	//MOV r2, r4
	//MOV r3, r5
	//BL printf

	B MenuLoop

//////////////////////////////////////////////////////////// 
// END Key Generation Section
//////////////////////////////////////////////////////////// 

//////////////////////////////////////////////////////////// 
// START Menu Feature Section
// Contributors: Everett Bowline
//////////////////////////////////////////////////////////// 

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
		BEQ p_StartLoop  	// Regenerate p & q
		CMP r0, #2
		BEQ EncryptSection  	// Encrypt a message, write to encrypted.txt
		CMP r0, #3
		BGE DecryptSection  	// Decrypt a message, write to plaintext.txt

//////////////////////////////////////////////////////////// 
// END Menu Feature Section
//////////////////////////////////////////////////////////// 

//////////////////////////////////////////////////////////// 
// START Encrypt Message Section
// Contributors: Conner Wright
//////////////////////////////////////////////////////////// 

    // Request message to encrypt, using public key, from Sender
    // for (character in message) { encrypt char and write in "encrypted.txt" }
    // Function: encrypt.s
    // Input: m (char from message), e (public key), n
    // Output: c (ciphertext)
    // Write ciphertext to "encrypted.txt"

EncryptSection:
	LDR r0, =encryptPrompt		// Request a message from the user to be encrypted
	BL printf
	BL getchar			// Clear input buffer newline
    	LDR r0, =stringFormat
    	LDR r1, =messageBuffer
	BL scanf			// Read full line message

	LDR r0, =encryptedFile		// Open encrypted file in write mode
	LDR r1, =fileWriteMode
	BL fopen
    	LDR r1, =fp
    	STR r0, [r1]        		// Store file pointer

	// Intialization for encrypt loop
	LDR r8, =messageBuffer		// Initialize message pointer

encrypt_loop:
	// Loop through each character of the message
	// Load the current character from the message
	LDRB r3, [r8]			// Load byte (char) from message
	CMP r3, #0			// Verify this is the end of the string
	BEQ encrypt_done

	MOV r0, r3 			// r0 = character to encrypt (c)
	MOV r1, r4			// r1 = public key exponent (e)
	MOV r2, r7			// r2 = modulus (n)

	// Encrypt the character m using RSA: c = m^e % n
	// Call the encrypt function with m (r1), e (r5), n (r6)
	BL encrypt			// r0 = encrypted int

 	// Write the ciphertext to encrypted.txt
    	// fprintf(fp, format %d, integer)
	MOV r2, r0			// r2 = encrypted value
	LDR r1, =encryptWritingFormat
	LDR r3, =fp
    	LDR r0, [r3]			// Load file pointer
	BL fprintf			// Write encrypted value to file

	ADD r8, r8, #1			// Move to next character
	B encrypt_loop

encrypt_done:
    	LDR r1, =fp
    	LDR r0, [r1]
    	BL fclose			// Close encrypted file

	LDR r0, =encryptSuccess		// Output success message
	BL printf

	B MenuLoop

//////////////////////////////////////////////////////////// 
// END Encrypt Message Section
//////////////////////////////////////////////////////////// 

//////////////////////////////////////////////////////////// 
// START Decrypt Message Section
// Contributors: Everett Bowline, Conner Wright
//////////////////////////////////////////////////////////// 

	// Function: decrypt.s
	// Input: c (ciphertext), d (private key), n
	// Output: m (decrypted text)
	// Write decrypted text to "plaintext.txt"

DecryptSection:    
	LDR r0, =encryptedFile		// Open input file - encrypted.txt in read mode
	LDR r1, =fileReadMode
	BL fopen
	LDR r1, =in_fp
	STR r0, [r1]

	LDR r0, =plaintextFile		// Open output file - plaintext.txt in read mode
	LDR r1, =fileWriteMode
	BL fopen
	LDR r1, =out_fp
	STR r0, [r1]

decrypt_loop:
	// Read the next encrypted character in encrypted.txt
	// fscanf(in_fp, "%d", &num)
	LDR r0, =in_fp
	LDR r0, [r0]			// Load file pointer
	LDR r1, =decryptReadingFormat
	LDR r2, =decryptNum		// Store integer read
	BL fscanf
	CMP r0, #1			// Check if read was successful
	BNE decrypt_done

	LDR r0, =decryptNum		// r0 = character to be decrypted
	LDR r0, [r0]
	MOV r1, r5			// r1 = private exponent d
	MOV r2, r7			// r2 = modulus n
	BL decrypt			// plaintext character return in r0

	// Write the next decrypted character to plaintext.txt
	// fprintf(out_fp, "%d", &num)
	MOV r2, r0
	LDR r0, =out_fp
	LDR r0, [r0]			// Load output file pointer
	LDR r1, =decryptWritingFormat
	BL fprintf			// Write decrypted char to file

	B decrypt_loop			//Repeat until characters are exhausted

decrypt_done:
	LDR r0, =in_fp			// Close encrypted.txt
	LDR r0, [r0]			// fclose(in_fp)
	BL fclose

	LDR r0, =out_fp			// Close plaintext.txt
	LDR r0, [r0]			// fclose(out_fp)
	BL fclose

	// Output
	LDR r0, =decryptSuccess		// Output success message
	BL printf
	B MenuLoop

//////////////////////////////////////////////////////////// 
// END Decrypt Message Section
//////////////////////////////////////////////////////////// 

EndProgram:

	MOV r0, #1

	LDR lr, [sp, #0]		// Restore link register
	ADD sp, sp, #4			// Restore stack
	MOV pc, lr			// Return

.data
	// Prompts
	introPrompt: .asciz "Welcome to our RSA algorithm program. We first require encryption setup.\n"
	menuPrompt: .asciz "Please choose an option:\nSet up RSA Encryption (1)\nEncrypt a message to encrypted.txt (2)\nDecrypt ciphertext from encrypted.txt to plaintext.txt (3)\nExit the program (-1):\n"
	prompt1: .asciz "Receiver, input a positive prime number for p: \n"
	prompt2: .asciz "Receiver, input a different positive prime number for q: \n"
	encryptPrompt: .asciz "Please enter the message to encrypt: \n"	
	decryptPrompt: .asciz "Searching for a file named encrypted.txt:\n"

	// Formats
 	format1: .asciz "%d"
	stringFormat: .asciz "%[^\n]"
	input: .asciz "%d"
	num: .word 0
	encryptWritingFormat: .asciz "%d\n"
	
	// Stored values
	pValue: .word 0
	qValue: .word 0
	decryptNum: .space 256
	messageBuffer: .space 255
 	messageLength:	.word 100
	encryptedFile: .asciz "encrypted.txt"
	plaintextFile: .asciz "plaintext.txt"
	fileReadMode: .asciz "r"
	fileWriteMode: .asciz "w"
	decryptReadingFormat: .asciz "%d"
	decryptWritingFormat: .asciz "%c"

	// Error messages
	p_ErrorMsg1: .asciz "Invalid p value. Requirement: p must be a positive prime number.\n"
	q_ErrorMsg1: .asciz "Invalid q value. Requirement: q must be a different positive prime number.\n"

	// Outputs
	RSAValuesOutput: .asciz "The value for p is %d.\nThe value for q is %d.\nThe value for modulus (n) is %d.\n"
	RSAValuesOutput2: .asciz "The value for the totient is %d.\nThe value for public key (e) is %d.\nThe value for private key (d) is %d.\n\n"
	encryptSuccess: .asciz "\nThe message has been encrypted and exported to encrypted.txt.\n\n"
	decryptSuccess: .asciz "\nThe message has been decrypted and exported to plaintext.txt.\n\n"

.bss
	fp: .skip 4     // file pointer (32-bit)
	in_fp: .skip 4
	out_fp: .skip 4
