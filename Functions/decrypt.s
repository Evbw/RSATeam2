//
// Program Name: decrypt.s
// Purpose: Decrypt an encrypted message using Private Key
// Input: Encrypted message in "encrypted.txt", d (private key), n
// Output: Decrypted message on "plaintext.txt"
// 

.text
.global main
main:
    // push stack record
    SUB sp, sp, #4
    STR lr, [sp]

    // Read from "encrypted.txt"

    // Find 'm' and write to "plaintext.txt"
    // m = c^d mod n

    // pop stack record
    LDR lr, [sp]
    ADD sp, sp, #4
    MOV pc, lr

.data

