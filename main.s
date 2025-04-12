//
// Program Name: main.s
// Section 81 Team 2
// Purpose: Encrypt sender's message to be decrypted and read by receiver
//

.text
.global main
main:
    // Program dictionary:
    // r4 - 
    // r5 - 
    // r6 -
    // r7 -
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
    // BL cpubexp
    // Store outputs


    // Receiver generates private key
    // Function: cprivexp.s
    // Input: r0 = e (public key), r1 = totient
    // Output: r0 = d (private key)
    // BL cprivexp
    // Store outputs


    // Request message to encrypt, using public key, from Sender
    // for (character in message) { encrypt char and write in "encrypted.txt" }
    // Function: encrypt.s
    // Input: m (char from message), e (public key), n
    // Output: c (ciphertext)
    // Write ciphertext to "encrypted.txt"


@ ----- START ENCRYPT SECTION -----
@ I started doing this then realized you're already requesting stuff above, so I was a little confused as to what I should be requesting here.
	# Request a message to encrypt using a public key the from Sender
	LDR r0, =messagePrompt			@ Message prompt to display
	BL printf				@ Print the prompt for message input
	LDR r0, =messageBuffer			@ Where the message will be stored
	LDR r1, =messageLength			@ Max length of message input
	BL scanf				@ Read message from sender

	# Loop through each character of the message
	LDR r2, =messageBuffer			@ Load address of message buffer
	LDR r3, =messageLength			@ Load max length of message
	MOV r4, #0				@ Index for iterating through message

encrypt_loop:
	# Load the current character from the message
	LDRB r1, [r2, r4]			@ Load the current character (m)
	CMP r1, #0				@ Check if we reached the end of the string (null terminator)
	BEQ encrypt_done			@ If null terminator, finish encryption loop

	# Encrypt the character m using RSA: c = m^e % n
	# Call the encrypt function with m (r1), e (r5), n (r6)
	MOV r0, r1				@ Move m to r0 (input to encrypt function)
	MOV r1, r5				@ Move e (public key) to r1
	MOV r2, r6				@ Move n (modulus) to r2
	BL encrypt				@ Encrypt m (r1) with e (r5) and n (r6)

	# Store result (ciphertext) in r0 (which now contains the result from encrypt function)
	MOV r3, r0				@ r0 now holds the ciphertext c

	# Write the ciphertext to the "encrypted.txt" file
	LDR r0, =ciphertextFile			@ Load the filename to write
	LDR r1, =fileWriteMode			@ File write mode (could be binary or text)
	BL openFile				@ Open the file

	MOV r0, r3				@ Prepare the ciphertext for writing
	BL writeToFile 				@ Write the ciphertext to file

	# Increment the index to move to the next character
	ADD r4, r4, #1
	B encrypt_loop				@ Repeat for the next character

encrypt_done:
	# Close the file after writing
	LDR r0, =ciphertextFile
	BL closeFile				@ Close the file
@ ----- END ENCRYPT SECTION -----


@ ----- START FILE SECTION -----
@ Function: openFile
@ Input: r0 = file name (pointer to string)
@        r1 = file mode (e.g., O_WRONLY, O_CREAT)
@ Output: r0 = file descriptor (or -1 if error)
openFile:
	MOV r7, #5				@ sys_open system call number
	MOV r2, #0				@ Flags: O_WRONLY (write only), O_CREAT (create if doesn't exist)
	MOV r3, #0x1FF				@ Permissions (rw-rw-rw-), typically for new files
	SWI 0					@ Make the system call

	# Check for errors (negative value indicates an error)
	CMP r0, #0				@ If file descriptor is less than 0, there was an error
	BLT openFile_error

	# File opened successfully, return file descriptor
	BX lr

openFile_error:
	MOV r0, #-1				@ Return -1 on error
	BX lr
	
	
@ Function: writeToFile
@ Input: r0 = file descriptor (from openFile)
@        r1 = pointer to data (ciphertext)
@        r2 = number of bytes to write
writeToFile:
	MOV r7, #4				@ sys_write system call number
	SWI 0					@ Make the system call

	# Check for errors (negative value indicates an error)
	CMP r0, #0 				@ If the return value is less than 0, there was an error
	BLT writeToFile_error

	# Return number of bytes written (r0 contains the number of bytes written)
	BX lr

writeToFile_error:
	MOV r0, #-1				@ Return -1 on error
	BX lr
	
	
@ Function: closeFile
@ Input: r0 = file descriptor (from openFile)
@ Output: r0 = 0 if successful, -1 on error
closeFile:
	MOV r7, #6				@ sys_close system call number
	SWI 0					@ Make the system call

	# Check for errors (negative value indicates an error)
	CMP r0, #0				@ If the return value is less than 0, there was an error
	BLT closeFile_error

	# File closed successfully
	MOV r0, #0 				@ Return 0 to indicate success
	BX lr

closeFile_error:
	MOV r0, #-1				@ Return -1 on error
	BX lr
@ ----- END FILE SECTION -----


    LDR r0, =decryptPrompt	// Read from "encrypted.txt"
    BL printf			// for (cipher in "encrypted.txt") { decrypt and write in "plaintext.txt }
    
    LDR r0, =decryptFormat
    LDR r1, =decryptInput
    BL scanf

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
    decryptPrompt: .asciz "Please enter the name of the file to be decrypted:\n"
    // Formats 
    format1: .asciz "%d"
    decryptFormat: .asciz "%s"
    // Stored values
    pValue: .word 0
    qValue: .word 0
    decryptInput: .word 100
    // Error messages
    p_ErrorMsg1: .asciz "Invalid p value. Requirement: 0 <= p < 50, and must be prime.\n"
    q_ErrorMsg1: .asciz "Invalud q value. Requirement: 0 <= q < 50, and must be prime.\n"
    debug1: .asciz "Valid p value: %d.\n"
    debug2: .asciz "Valid q value: %d.\n"

@ ----- .data for the Encrypt section ----
	messagePrompt: .asciz "Please enter the message to encrypt: \n"		@ Prompt user to enter a message
	messageBuffer: .space 100						@ Space to store the message (up to 100 characters)
	messageLength: .word 100						@ Maximum length for the message
