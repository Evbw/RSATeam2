//
// Program Name: main.s
// Section 81 Team 2
// Purpose: Encrypt sender's message to be decrypted and read by receiver
//

//
// TO DO
// 1. Reading from and writing to .txt files; want to keep algorithm within
// function or in main code?
//


.text
.global main
main:
    // push stack record
    SUB sp, sp, #4
    STR lr, [sp]

    // Receiver generates public and private keys
    // Function: cpubexp.s
    // Input: p, q
    // Store Outputs: n, e (public key), totient
    // Function: cprivexp.s
    // Input: x, e (public key), totient
    // Store Outputs: d

    // Encrypt message using Public Key
    // Function: encrypt.s
    // Purpose: Prompt Sender for message to be encrypted
    // Inputs: Sender's message, e (public key), n
    // Store Outputs: c (encrypted message on 'encrypted.txt')
    // Write encrypted message to "encrypted.txt"

    // Decrypt message using Private Key
    // Function: decrypt.s
    // Purpose: Read from "encrypted.s" and decrypt onto "plaintext.txt"
    // Input: c (encrypted message), d (private key), n
    // Output: Decrypted message on "plaintext.txt"
    // Write decrypted message to "plaintext.txt"

    // pop stack record
    LDR lr, [sp]
    ADD sp, sp, #4
    MOV pc, lr

.data
    prompt3: .asciz "Sender, enter message to send to the Receiver: "
    buffer: .skip 100  // Sender message; reserve 100 bytes for a string
    format3: .asciz "%s"

