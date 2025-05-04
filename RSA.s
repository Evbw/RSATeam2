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

	// push stack record
	SUB sp, sp, #4
	STR lr, [sp, #0]

	LDR r0, =introPrompt
	BL printf

    // Request p, q from Receiver; ensure p and q meet requirements
    // Loop for p value. p must be prime and < 50.
    p_StartLoop:

        LDR r0, =prompt1
        BL printf
        LDR r0, =input
        LDR r1, =pValue
        BL scanf  // p stored in pValue

        // Verify 0 < p < 50
        LDR r0, =pValue
        LDR r0, [r0]
        MOV r1, #0
        CMP r0, #0
	      ADDGE r1, r1, #1  // p >= 0
        // Verify p is prime
        BL isPrime
        AND r0, r0, r1

        CMP r0, #1
        BNE p_error
            // Statement if p is valid
            B p_EndLoop
        p_error:
            LDR r0, =p_ErrorMsg1
            BL printf
            B p_StartLoop

    p_EndLoop:

    // Loop for q value. q must be prime and < 50.
    q_StartLoop:

        LDR r0, =prompt2
        BL printf
        LDR r0, =input
        LDR r1, =qValue
        BL scanf  // q stored in pValue

        // Verify 0 < q < 50
        LDR r0, =qValue
        LDR r0, [r0]
        MOV r1, #0
        CMP r0, #0
	ADDGE r1, r1, #1  // q >= 0

        // Verify q is prime
        BL isPrime
        AND r0, r0, r1

        CMP r0, #1
        BNE q_error
            // Statement if q is valid
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

	// Receiver generates public key
	// Function: cpubexp.s
	// Inputs: r0 = p, r1 = q
	// Output: r0 = e (public key), r1 = totient, r2 = n
	LDR r0, =pValue
	LDR r0, [r0]
	LDR r1, =qValue
	LDR r1, [r1]
	BL cpubexp
	// Store outputs in program dictionary
	MOV r4, r0  // public key
	MOV r6, r1  // totient
	MOV r7, r2  // modulus


	// Receiver generates private key
	// Function: cprivexp.s
	// Input: r0 = e (public key), r1 = totient
	// Output: r0 = d (private key)
	BL cprivexp
	// Store outputs in program dictionary
	MOV r5, r0  //  private key

	// Output encryption info to Receiver
	LDR r0, =RSAValuesOutput
	LDR r1, =pValue
	LDR r1, [r1]
	LDR r2, =qValue
	LDR r2, [r2]
	MOV r3, r7
	BL printf

	LDR r0, =RSAValuesOutput2
	MOV r1, r6
	MOV r2, r4
	MOV r3, r5
	BL printf

	B MenuLoop

//////////////////////////////////////////////////////////// 
// END Key Generation Section
//////////////////////////////////////////////////////////// 

//////////////////////////////////////////////////////////// 
// START Menu Feature Section
// Contributors: Everett Bowline
//////////////////////////////////////////////////////////// 

	//Enter Main Menu
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
	BEQ p_StartLoop  // Set up encryption values again
	CMP r0, #2
	BEQ EncryptSection  // Encrypt a message, write to encrypted.txt
	CMP r0, #3
	BGE DecryptSection  // Decrypt a message, write to plaintext.txt

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
	// Request a message from the user to be encrypted
	LDR r0, =encryptPrompt
	BL printf
	BL getchar
    	LDR r0, =stringFormat
    	LDR r1, =messageBuffer
	BL scanf

	// Open encrypted.txt
	LDR r0, =encryptedFile
	LDR r1, =fileWriteMode
	BL fopen
    	LDR r1, =fp
    	STR r0, [r1]        		// Save file pointer

	// Intialization for encrypt loop
	LDR r8, =messageBuffer		// r8 = user message

encrypt_loop:
	// Loop through each character of the message
	// Load the current character from the message
	LDRB r3, [r8]
	CMP r3, #0
	BEQ encrypt_done

	MOV r0, r3 			// r0 = character
	MOV r1, r4			// r1 = exponent
	MOV r2, r7			// r2 = modulus

	// Encrypt the character m using RSA: c = m^e % n
	// Call the encrypt function with m (r1), e (r5), n (r6)
	BL encrypt			// r0 = encrypted byte

 	// Write the ciphertext to encrypted.txt
    	// fprintf(fp, format %d, integer)
	MOV r2, r0
	LDR r1, =encryptWritingFormat
	LDR r3, =fp
    	LDR r0, [r3]
	BL fprintf

	// Loop to the next message index
	ADD r8, r8, #1
	B encrypt_loop

encrypt_done:
    	// Close encrypted.txt
    	LDR r1, =fp
    	LDR r0, [r1]
    	BL fclose

	// Output
	LDR r0, =encryptSuccess
	BL printf

	B MenuLoop

//////////////////////////////////////////////////////////// 
// END Encrypt Message Section
//////////////////////////////////////////////////////////// 

//////////////////////////////////////////////////////////// 
// START Decrypt Message Section
// Contributors: Everett Bowline
//////////////////////////////////////////////////////////// 

	// Function: decrypt.s
	// Input: c (ciphertext), d (private key), n
	// Output: m (decrypted text)
	// Write decrypted text to "plaintext.txt"

//Begin Decrypt section - Everett Bowline

DecryptSection:    
	// Open encrypted.txt
	LDR r0, =encryptedFile
	LDR r1, =fileReadMode
	BL fopen
	LDR r1, =in_fp
	STR r0, [r1]

	// Open plaintext.txt
	LDR r0, =plaintextFile
	LDR r1, =fileWriteMode
	BL fopen
	LDR r1, =out_fp
	STR r0, [r1]

decrypt_loop:

	// Read the next encrypted character in encrypted.txt
	// fscanf(in_fp, "%d", &num)
	LDR r0, =in_fp
	LDR r0, [r0]
	LDR r1, =decryptReadingFormat
	LDR r2, =decryptNum
	BL fscanf
	CMP r0, #1
	BNE decrypt_done

	// decrypt ciphertext
	LDR r0, =decryptNum		// r0 = character to be decrypted
	LDR r0, [r0]
	MOV r1, r5			// r1 = private exponent d
	MOV r2, r7			// r2 = modulus n
	BL decrypt			// plaintext character return in r0
	//MOV r1, r0			// ??
	//STR r1, [r0]			// ??

	// Write the next decrypted character to plaintext.txt
	// fprintf(out_fp, "%d", &num)
	MOV r2, r0
	LDR r0, =out_fp
	LDR r0, [r0]
	LDR r1, =decryptWritingFormat
	BL fprintf

	B decrypt_loop			//Repeat until characters are exhausted

decrypt_done:

	// Close encrypted.txt
	// fclose(in_fp)
	LDR r0, =in_fp
	LDR r0, [r0]
	BL fclose

	// Close plaintext.txt
	// fclose(out_fp)
	LDR r0, =out_fp
	LDR r0, [r0]
	BL fclose

	// Output
	LDR r0, =decryptSuccess
	BL printf

	B MenuLoop

//////////////////////////////////////////////////////////// 
// END Decrypt Message Section
//////////////////////////////////////////////////////////// 

EndProgram:

	MOV r0, #1

	// pop stack record
	LDR lr, [sp, #0]
	ADD sp, sp, #4
	MOV pc, lr

.data
	// Prompts
	introPrompt: .asciz "Welcome to our RSA algorithm program. We first require encryption setup:\n"
	menuPrompt: .asciz "Please choose an option:\nSet up RSA Encryption (1)\nEncrypt a message to encrypted.txt (2)\nDecrypt ciphertext from encrypted.txt to plaintext.txt (3)\nExit the program (-1):\n"
	prompt1: .asciz "Receiver, input a positive prime value < 50 for p: \n"
	prompt2: .asciz "Receiver, input a positive prime value < 50 for q: \n"
	encryptPrompt: .asciz "Please enter the message to encrypt: \n"	

	// Formats 
	stringFormat: .asciz "%[^\n]"
	input: .asciz "%d"
	num: .word 0
	encryptWritingFormat: .asciz "%d\n"
	
	// Stored values
	pValue: .word 0
	qValue: .word 0
	decryptNum: .space 256
	messageBuffer: .space 255
	encryptedFile: .asciz "encrypted.txt"
	plaintextFile: .asciz "plaintext.txt"
	fileReadMode: .asciz "r"
	fileWriteMode: .asciz "w"
	decryptReadingFormat: .asciz "%d"
	decryptWritingFormat: .asciz "%c"

	// Error messages
	p_ErrorMsg1: .asciz "Invalid p value. Requirement: 0 <= p < 50, and must be prime.\n"
	q_ErrorMsg1: .asciz "Invalid q value. Requirement: 0 <= q < 50, and must be prime.\n"

	// Outputs
	RSAValuesOutput: .asciz "The value for p is %d.\nThe value for q is %d.\nThe value for modulus (n) is %d.\n"
	RSAValuesOutput2: .asciz "The value for the totient is %d.\nThe value for public key (e) is %d.\nThe value for private key (d) is %d.\n\n"
	encryptSuccess: .asciz "\nThe message has been encrypted and exported to encrypted.txt.\n\n"
	decryptSuccess: .asciz "\nThe message has been decrypted and exported to plaintext.txt.\n\n"

.bss
	fp: .skip 4     // file pointer (32-bit)
	in_fp: .skip 4
	out_fp: .skip 4
