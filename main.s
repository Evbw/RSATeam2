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
    // Loop for p value. p < 50
    p_Loop:

        LDR r0, =prompt1
        BL printf
        LDR r0, =format1
        LDR r1, =pValue
        BL scanf  // p stored in pValue

        // Verify p
        LDR r0, =pValue
        LDR r0, [r0]
        CMP r0, #0
        BGT p_elsif1
            // Statement if p <= 0
            LDR r0, =p_ErrorMsg1
            BL printf
            B p_Loop
        p_elsif1:
            // Statement if 0 < p < 50
            CMP r0, #50
            BGE p_else
            B endIf1
        p_else:
            LDR r0, =p_ErrorMsg1
            BL printf
            B p_Loop
        endIf1:
        
        LDR r0, =debug
        LDR r1, =pValue
        LDR r1, [r1]
        BL printf
        // END Verify p


    // Receiver generates public key
    // Function: cpubexp.s
    // Inputs: r0 = p, r1 = q
    // Output: r0 = e (public key), r1 = totient, r2 = n
    // Store outputs
    BL cpubexp


    // Receiver generates private key
    // Function: cprivexp.s
    // Input: r0 = e (public key), r1 = totient
    // Output: r0 = d (private key)
    // Store outputs
    BL cprivexp


    // Request message to encrypt, using public key, from Sender
    // for (character in message) { encrypt char and write in "encrypted.txt" }
    // Function: encrypt.s
    // Input: m (char from message), e (public key), n
    // Output: c (ciphertext)
    // Write ciphertext to "encrypted.txt"

    // Read from "encrypted.txt"
    // for (cipher in "encrypted.txt") { decrypt and write in "plaintext.txt }
    // Function: decrypt.s
    // Input: c (ciphertext), d (private key), n
    // Output: m (decrypted text)
    // Write decrypted text to "plaintext.txt"

    // pop stack record
    LDR lr, [sp]
    ADD sp, sp, #4
    MOV pc, lr

.data
    prompt1: .asciz "Receiver, input a positive value < 50 for p: \n"
    prompt2: .asciz "Receiver, input a positive value < 50 for q: \n"
    format1: .asciz "%d"
    format2: .asciz "%d"
    pValue: .word 0
    qValue: .word 0
    p_ErrorMsg1: .asciz "Invalid p value. Requirement: 0 < p < 50.\n"
    debug: .asciz "Valid p value: %d.\n"

