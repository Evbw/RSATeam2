.global modulo


# NOTES 
# r0 = dividend
# r1 = divisor
# Return: r0 = result of (dividend % divisor)


@ ----- FUNCTION 1: Modulo -----
.text
modulo:

	# Push the stack
	SUB sp, sp, #4
	STR lr, [sp, #0]

	# Perform division
	BL __aeabi_div					@ Call aeabi_div(dividend, divisor) and return quotient in r0

	# Store the quotient
	MOV r2, r0						@ r2 = quotient (returned by aeabi_div)

	# Multiply the quotient by the divisor
	MUL r2, r2, r1					@ r2 = quotient * divisor

	# Subtract to get the remainder
	SUB r0, r0, r2					@ r0 = dividend - (divisor * quotient)

	# Pop the stack (and return to the OS)
	LDR lr, [sp, #0]
	ADD sp, sp, #4
	MOV pc, lr

.data
@ ----- END FUNCTION 1 -----
