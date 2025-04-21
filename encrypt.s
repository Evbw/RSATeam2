# Program Name: encrypt.s
# Purpose: Encrypt a message using Public Key
# Input: 
#	r0 = message (m)
#	r1 = public key (e)
#	r2 = p * q (n)
# Output:
#	r0 = encrypted cipher text (c)
 

.global encrypt

@ ----- FUNTION 1: encrypt -----
.text
encrypt:
    SUB sp, sp, #12
    STR lr, [sp]
    STR r2, [sp, #4]    @ Save n
    STR r1, [sp, #8]    @ Save e

    @ Compute m^e using pow
    MOV r1, r1          @ exponent
    MOV r0, r0          @ base
    BL pow              @ result in r0

    @ r0 now has m^e
    LDR r1, [sp, #4]    @ r1 = n (modulus)
    BL modulo           @ r0 = (m^e) mod n

    @ Return result in r0
    LDR lr, [sp]
    ADD sp, sp, #12
    MOV pc, lr

.data
@ ----- END OF FUNCTION 1 -----
