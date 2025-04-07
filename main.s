//
// Program Name: main.s
// Section 81 Team 2
// Purpose: Encrypt sender's message to be decrypted and read by receiver
//

.text
.global main
main:
    // push stack record
    SUB sp, sp, #4
    STR lr, [sp]

    // Request p, q from Receiver; ensure p and q meet requirements
    // Loop for p value. p must be prime and < 50.
    p_Loop:

        LDR r0, =prompt1
        BL printf
        LDR r0, =format1
        LDR r1, =pValue
        BL scanf  // p stored in pValue

        // Verify 0 < p < 50
        LDR r0, =pValue
        LDR r9, [r0]// putting the value in r9 to preserve the input
	BL isPrime //calling a function check if the number is prime
	CMP r0, #0
	BNE p_elsif2
		LDR r0, =p_ErrorMsg2
		BL printf
		B p_Loop

	p_elsif2:
	
        CMP r9, #0
        BGT p_elsif1
            // Statement if p <= 0
            LDR r0, =p_ErrorMsg1
            BL printf
            B p_Loop
        p_elsif1:
            // Statement if 0 < p < 50
            CMP r9, #50
            BGE p_else
            B endIf1
        p_else:
            LDR r0, =p_ErrorMsg1
            BL printf
            B p_Loop
        endIf1:

        // Verify p is prime
        

        LDR r0, =debug1
        LDR r1, =pValue
        LDR r1, [r1]
        BL printf

    // Loop for q value. q must be prime and < 50.
    q_Loop:

        LDR r0, =prompt2
        BL printf
        LDR r0, =format2
        LDR r1, =qValue
        BL scanf  // q stored in qValue

        // Verify q
        LDR r0, =qValue
        LDR r0, [r0]
        CMP r0, #0
        BGT q_elsif1
            // Statement if q <= 0
            LDR r0, =q_ErrorMsg1
            BL printf
            B q_Loop
        q_elsif1:
            // Statement if 0 < q 50
            CMP r0, #50
            BGE q_else
            B endIf2
        q_else:
            LDR r0, =q_ErrorMsg1
            BL printf
            B q_Loop
        endIf2:

        LDR r0, =debug2
        LDR r1, =qValue
        LDR r1, [r1]
        BL printf
        // END Verify q
        

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

    prompt1: .asciz "Receiver, input a positive prime value < 50 for p: \n"
    prompt2: .asciz "Receiver, input a positive prime value < 50 for q: \n"
    format1: .asciz "%d"
    decryptPrompt: .asciz "Please enter the name of the file to be decrypted:\n" 

    format2: .asciz "%d"
    decryptFormat: .asciz "%s"
    pValue: .word 0
    qValue: .word 0
    decryptInput: .word 100
    p_ErrorMsg1: .asciz "Invalid p value. Requirement: 0 < p < 50.\n"
    q_ErrorMsg1: .asciz "Invalud q value. Requirement: 0 < q < 50.\n"
    debug1: .asciz "Valid p value: %d.\n"
    debug2: .asciz "Valid q value: %d.\n"

