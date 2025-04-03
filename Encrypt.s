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

	# push stack record
	SUB sp, sp, #4
	STR lr, [sp]

	# c = m^e
	BL pow  // r0 = m^e
	MOV r1, r2
	BL modulo // r0 = m^e mod n

	# pop stack record
	LDR lr, [sp]
	ADD sp, sp, #4
	MOV pc, lr

.data
@ ----- END OF FUNCTION 1 -----
