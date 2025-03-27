//
// Program Name: decrypt.s
// Purpose: Decrypt an encrypted message using Private Key
// Input: 
//     r0 = cipher text (c)
//     r1 = private key (d)
//     r2 = p * q (n)
// Output:
//     r0 = decrypted ascii character
// 

.global decrypt

.text
decrypt:

    // push stack record
    SUB sp, sp, #4
    STR lr, [sp]

    // m = c^d mod n
    BL pow  // r0 = c^d
    MOV r1, r2
    BL modulo // r0 = c^d mod n

    // pop stack record
    LDR lr, [sp]
    ADD sp, sp, #4
    MOV pc, lr

.data

// END decrypt

