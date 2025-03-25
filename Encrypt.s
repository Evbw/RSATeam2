.global encrypt


# NOTES
# r0 = base (message to be encrypted)
# r1 = exponent (public key exponent)
# r2 = modulus (the modulus used for encryption)
# Return: r0 = encrypted message (cipher)


@ ----- FUNCTION 1: Encrypt -----
.text
encrypt:
	
	# Initialize result (result = 1)
	MOV r3, #1						@ r3 = 1 (this will hold the result)

.data
@ ----- END FUNCTION 1 -----


@ ----- FUNCTION 2: Encrypt Loop -----
.text
encrypt_loop:
	
	# Check if the exponent (r1) is zero
	CMP r1, #0
	BEQ encrypt_done					@ If the exponent is zero, then we're done

	# If the exponent (r1) is odd (r1 % 2 != 0), multiply the result by the base and take the modulo
	AND r4, r1, #1						@ r4 = r1 & 1 (check if it's odd)
	CMP r4, #1
	BEQ encrypt_odd_exponent

	# If the exponent is even, just square the base and reduce the modulus
	MUL r0, r0, r0						@ r0 = r0 * r0 (square the base)
	BL modulo						@ Call the modulo function
	MOV r0, r0						@ Store the result of the modulo in r0 (base)

	LSR r1, r1, #1						@ r1 = r1 / 2 (shift the exponent right by 1)
	B encrypt_loop						@ Loop again

.data
@ ----- END FUNCTION 2 -----


@ ----- FUNCTION 3: Encrypt Odd Exponent -----
.text
encrypt_odd_exponent:
	
	MUL r3, r3, r0						@ r3 = r3 * base (multiply the result by the base)
	BL modulo						@ Call the modulo function
	MOV r3, r0						@ Store the result of the modulo in r3 (result)

	MUL r0, r0, r0						@ r0 = r0 * r0 (square the base)
	BL modulo						@ Call the modulo function
	MOV r0, r0						@ Store the result of the modulo in r0 (base)

	LSR r1, r1, #1						@ r1 = r1 / 2 (shift the exponent right by 1)
	B encrypt_loop						@ Loop again

.data
@ ----- END FUNCTION 3 -----


@ ----- FUNCTION 4: Encrypt Done -----
.text
encrypt_done:
	
	# The result (cipher) is now in r3, so copy it to r0 (return value)
	MOV r0, r3
	BX lr							@ Return to the OS

.data
@ ----- END FUNTION 4 -----
