//
// Program Name: main.s
// Section 81 Team 2
// Purpose: Encrypt sender's message to be decrypted and read by receiver
//

.text
.global main

main:
    // Program dictionary:
    // r4 - public key (e)
    // r5 - private key (d)
    // r6 - totient
    // r7 - modulus (n)

    // r8 -
    // r9 - 
    // r10 -
    // r11 -
    // r12 -

    // push stack record
    SUB sp, sp, #4
    STR lr, [sp]

    // Request p, q from Receiver; ensure p and q meet requirements
    // Loop for p value. p must be prime and < 50.
    p_StartLoop:

        LDR r0, =prompt1
        BL printf
        LDR r0, =format1
        LDR r1, =pValue
        BL scanf  // p stored in pValue

        // Verify 0 < p < 50
        LDR r0, =pValue
        LDR r0, [r0]
        MOV r1, #0
        CMP r0, #0
	ADDGE r1, r1, #1  // p >= 0
        MOV r2, #0
        CMP r0, #50
        ADDLT r2, r2, #1  // 0 <= p < 50
        AND r1, r1, r2

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
        LDR r0, =format1
        LDR r1, =qValue
        BL scanf  // q stored in pValue

        // Verify 0 < q < 50
        LDR r0, =qValue
        LDR r0, [r0]
        MOV r1, #0
        CMP r0, #0
	ADDGE r1, r1, #1  // q >= 0
        MOV r2, #0
        CMP r0, #50
        ADDLT r2, r2, #1  // 0 <= q < 50
        AND r1, r1, r2

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
    MOV r4, r0
    MOV r6, r1
    MOV r7, r2


    // Receiver generates private key
    // Function: cprivexp.s
    // Input: r0 = e (public key), r1 = totient
    // Output: r0 = d (private key)
    BL cprivexp
    // Store outputs in program dictionary
    MOV r5, r0


    // Request message to encrypt, using public key, from Sender
    // for (character in message) { encrypt char and write in "encrypted.txt" }
    // Function: encrypt.s
    // Input: m (char from message), e (public key), n
    // Output: c (ciphertext)
    // Write ciphertext to "encrypted.txt"


@ ----- START ENCRYPT SECTION -----

	@ Request a message from the user to be encrypted
	LDR r0, =messagePrompt
	BL printf

	LDR r0, =inputFormat				@ scanf format: "%s"
	LDR r1, =messageBuffer				@ store input here
	BL scanf
	@ Read message from user input into messageBuffer

	LDR r0, =cipherTextFile
	LDR r1, =fileWriteMode
	BL openFile
	CMP r0, #0
	//BLT main_error
	MOV r7, r0							@ r7 holds file descriptor

	LDR r2, =messageBuffer				@ r2 = pointer to message
	MOV r4, #0							@ r4 = index

encrypt_loop:
	@ Loop through each character of the message
	@ Load the current character from the message
	LDRB r1, [r2, r4]					@ Load byte at index
	@ Check if we reached the end of the string (null terminator)
	CMP r1, #0							@ Check for null terminator
	BEQ encrypt_done

	MOV r0, r1 							@ r0 = character
	MOV r1, r5							@ r1 = exponent
	MOV r2, r6							@ r2 = modulus
	@ Encrypt the character m using RSA: c = m^e % n
	@ Call the encrypt function with m (r1), e (r5), n (r6)
	BL encrypt							@ r0 = encrypted byte

	MOV r1, r0							@ r1 = encrypted value
	LDR r2, =oneByteBuf
	STRB r1, [r2]						@ Store encrypted byte
	MOV r1, r2 							@ r1 = address of buffer
	MOV r2, #1 							@ r2 = byte count
	MOV r0, r7							@ r0 = file descriptor
	@ Write the ciphertext to the file
	BL writeToFile

	ADD r4, r4, #1
	B encrypt_loop

encrypt_done:
	MOV r0, r7
	@ Close the file after writing
	BL closeFile

@ ----- END ENCRYPT SECTION ------

//Start decrypt section
	// Function: decrypt.s
	// Input: c (ciphertext), d (private key), n
	// Output: m (decrypted text)
	// Write decrypted text to "plaintext.txt"
 	LDR r0, =decryptPrompt		// Display prompt
	BL printf
    
	LDR r0, =encryptedFile		//The name of the file
	LDR r1, =fileReadMode		//(encrypted.text, to be decrypted and written into plaintext.txt)
	BL openFile
	MOV r9, r0			//Save input file to r7

	LDR r0, =plaintextFile		//Open the file to be written to
	LDR r1, =fileWriteMode		
	BL openFile
	MOV r8, r0			//Save output file to r8

decrypt_loop:
	//Read the next encrypted character
	MOV r0, r9			//Input file 
	LDR r1, =cipherTextBuffer	//Buffer to store the encrypted character
	BL readFromFile			//Read the number into the buffer
	CMP r0, #0			//Check if we're at the end of the file
	BEQ decrypt_done		//And exit if we are

	LDR r1, =cipherTextBuffer	//Load ciphertext into r1
	STRB r1, [r1]

	MOV r0, r1			//r0 = character to be decrypted
	MOV r1, r5			//r1 = private exponent d
	MOV r2, r6			//r2 = modulus n
	BL decrypt			//plaintext character return in r0

	LDR r0, =plaintextBuffer
	STRB r0, [r0]			//Save character to the plaintext buffer

	MOV r0, r8			//Reload output file
	LDR r1, =plaintextBuffer	
	MOV r2, #1			//Write 1 byte
	BL writeToFile

	B encrypt_loop			//Repeat until characters are exhausted

decrypt_done:
	MOV r0, r9			//Close both files
	BL closeFile

	MOV r0, r8
	BL closeFile
	// Function: decrypt.s
	// Input: c (ciphertext), d (private key), n
	// Output: m (decrypted text)
	// Write decrypted text to "plaintext.txt"

	// pop stack record
	LDR lr, [sp]
	ADD sp, sp, #4
	MOV pc, lr

.data
	// Prompts
	prompt1: .asciz "Receiver, input a positive prime value < 50 for p: \n"
	prompt2: .asciz "Receiver, input a positive prime value < 50 for q: \n"
	decryptPrompt: .asciz "Searching for a file named encrypted.txt:\n"
	// Formats 
	format1: .asciz "%d"
	decryptFormat: .asciz "%s"
	inputFormat: .asciz "%[^\n]"
	
	// Stored values

	pValue: .word 0
	qValue: .word 0
	decryptInput: .word 100
	// Error messages
	p_ErrorMsg1: .asciz "Invalid p value. Requirement: 0 <= p < 50, and must be prime.\n"
	q_ErrorMsg1: .asciz "Invalid q value. Requirement: 0 <= q < 50, and must be prime.\n"

@ ----- .data for the Encrypt section ----
	messagePrompt: .asciz "Please enter the message to encrypt: \n"		@ Prompt user to enter a message
	messageBuffer: .space 255						@ Space to store the message (up to 100 characters)
	messageLength: .word 100						@ Maximum length for the message
	cipherTextFile: .asciz "encrypted.txt"
	oneByteBuf: .byte 0
	//decrypt
	encryptedFile: .asciz "encrypted.txt"
	plaintextFile: .asciz "plaintext.txt"
	fileReadMode: .asciz "r"
	fileWriteMode: .asciz "w"
	cipherTextBuffer: .space 4
	plaintextBuffer: .space 1
