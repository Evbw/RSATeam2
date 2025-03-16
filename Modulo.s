.global modulo


# Arguments: r0 = dividend, r1 = divisor
# Return: r0 = result of (dividend % divisor)


##### Function 1 - Modulo #####
.text
modulo:

	# Step 1: Perform division using the `udiv` instruction (unsigned division for hardware)
	udiv r2, r0, r1          // r2 = r0 / r1 (quotient)

	# Step 2: Multiply the quotient by the divisor
	mul r2, r2, r1           // r2 = r2 * r1 (this is the divisor * quotient)

	# Step 3: Subtract to get the remainder
	sub r0, r0, r2           // r0 = r0 - r2 (this is dividend - (divisor * quotient))

	# Step 4: Return the remainder
	bx lr                     // Return to the caller

.data
##### END Function 1 #####
