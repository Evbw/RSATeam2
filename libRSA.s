#
# File name: libRSA
# Authors: Ayush Goel, Calvin Tang, Conner Wright, Everett Bowline
# Purpose: Serves as the library function for the main RSA program
#


.global pow
.global gcd
.global modulo
.global cpubexp
.global cprivexp
.global encrypt
.global decrypt
.global isPrime

.text

pow:
	SUB sp, sp, #8
	STR lr, [sp]

	MOV r5, r0		//Store the term in r5 and r7
	MOV r7, r0

	MOV r6, r1		//And move to to r6

	MOV r1, #0
	CMP r6, r1
	BEQ ZeroExp
	BLE NegExp

	StartLoop:		//Begin the loop!
		CMP r6, #1	//Compare the exponent value to 1.
		BLE EndLoop	//Branch it (B) and if the value in r6 is LESS THAN (L) or EQUAL (E) to 1, then move to EndLoop
		
		MUL r7, r7, r5	//Multiply the term by itself through every iteration of the loop and store in r7
		SUB r6, r6, #1	//Reduce the value of the exponent by 1 for every advance through the loop

		B StartLoop	//Branch again and go back to the beginning of the StartLoop procedure

	EndLoop:		//Once the condition is met, end the loop and continue with the program

		MOV r0, r7	//Move the value from r7 to r1
		B EndPow

	ZeroExp:
		MOV r0, #1
		B EndPow
	
	NegExp:
	        MOV r0, #-1
		B EndPow

	EndPow:

	LDR lr, [sp]
	ADD sp, sp, #8
	MOV pc, lr

//End pow

gcd:
	SUB sp, sp, #8
	STR lr, [sp]

	CMP r0, r1
	BEQ Equal			//Handle an instance when they are the same value

	MOV r3, #0
	MOV r4, #0			//Confirm registers aren't being used for anything (I had some issues compiling if I didn't do this)

	CMP r0, r1
	MOVGT r3, r0			//Compare the value in r0 to the one in r1. Move the greater to r3
	MOVGT r4, r1			//and the lesser to r4. The MOV functions use the same comparison flag, so
	MOVLT r4, r0			//MOVGT sees if r0 is greater than r1, and if is, performs the move operation
	MOVLT r3, r1			//MOVLT does the same, but only if r0 is less than r1

	StartGCDLoop:
		MOV r0, #0
		CMP r3, r0
		BLE LogicError		//Handle any instance where the value drops to or below 0
		CMP r3, r4
		BEQ EndGCDLoop		//Break the loop when the comparison values are equal (via Euclid's algorithm)

		SUB r2, r3, r4		//Subtract the smaller of the two values and store in r2 (Say 252 - 105 = 147. Store 147 in r2)
		CMP r2, r4		//Find the new smallest value
		MOVGE r3, r2		//If the value in r2 is greater than or equal to the value in r4, store it in r3 (r3 is now 147)
		MOVLT r3, r4		//If the value in r2 is less than the value in r4, move r4 to r3 (the register meant to hold the
		MOVLT r4, r2		//larger value) and move r2 to r4
	
		B StartGCDLoop		//Begin loop again, so 147 - 105 = 42. 42 < 105, so 105 goes to r3 and 42 goes to r4 and we loop
					//again until r3 = r4 = 21, which is the GCD
	EndGCDLoop:			
		MOV r0, r3		//We could move r3 or r4, but they should be the same, so move that value to r1
		MOV r2, #1		//Move the immediate value 1 to r2
		CMP r0, r2		//If the number in r1 is, in fact, 1, then the two numbers do not have a common denominator

		B EndGCD		//Branch to end program to prevent any other sections from activating

	LogicError:
		MOV r0, #-1		//Produce error output

		B EndGCD

	Equal:
		MOV r0, r6		//If the values are equal, produce equalOutput to let the user know

	EndGCD:

	LDR lr, [sp]
	ADD sp, sp, #8
	MOV pc, lr

.data
	
//End gcd

.text
# NOTES 
# r0 = dividend
# r1 = divisor
# Return: r0 = result of (dividend % divisor)
modulo:

	# Push the stack
	SUB sp, sp, #8
	STR lr, [sp, #0]

	MOV r5, r0
	# Perform division
	BL __aeabi_idiv					//Call aeabi_div(dividend, divisor) and return quotient in r0

	# Store the quotient
	MOV r2, r0					//r2 = quotient (returned by aeabi_div)

	# Multiply the quotient by the divisor
	MUL r2, r2, r1					//r2 = quotient * divisor

	# Subtract to get the remainder
	SUB r0, r5, r2					//r0 = dividend - (divisor * quotient)

	# Pop the stack (and return to the OS)
	LDR lr, [sp, #0]
	ADD sp, sp, #8
	MOV pc, lr

.data
	debug: .asciz "%d\n"
//End modulo

cpubexp:

	SUB sp, sp, #8
	STR lr, [sp]

	MOV r10, r0 //moving p and q to ensure that values are preserved
	MOV r9, r1 

	# calculating N
	
	MUL r8, r9, r10
	
	# calculating totient

	SUB r7, r10, #1
	SUB r6 ,r9, #1
	MUL r5, r6, r7 //totient


	exp_loop:

	LDR r0, =prompt_exp
	BL printf

	LDR r0, =exp_format
	LDR r1, =input1
	BL scanf
	
	LDR r1, =input1
	LDR r0, [r1]
	MOV r11, r0
	
	CMP r0, #0 // check to see if the number is positive
	BGT Error_msg
		CMP r0, #1 // check to see if input is greater than 1
		BGT Error_msg
			CMP r0, r5 // Check to see input is less than totient
			BLT Error_msg
				BL isPrime//checking if the input is prime
				CMP r0, #0
				BNE Error_msg
					MOV r0, r11
					MOV r1, r5
					BL gcd //chekcing if input is comprime to totient
					CMP r0, #1
					BNE Error_msg
						B done


	Error_msg:
		
		LDR r0, =error_msg
		BL printf
		B exp_loop

	done:
	
	MOV r0, r11
	MOV r1, r5
	MOV r2, r8

	LDR lr, [sp]
	ADD sp, sp, #4
	MOV pc, lr


.data

	prompt_exp: .asciz "Please enter a number that is: \n between 1 and %d \npositive \n prime \n coprime to %d:"
	exp_format:.asciz "%d"
	input1: .word 0
	error_msg: .asciz "your value does not match the specifications, please try again."
//End cpubexp


isPrime:
	SUB sp, sp, #16
	STR lr, [sp, #0]
	STR r5, [sp, #4]
	STR r6, [sp, #8]
	STR r7, [sp, #12]

	MOV r5, r0			//Divide by 2 for easy comparison of divisors
	MOV r1, #2
	BL __aeabi_idiv
	MOV r6, r0			//Move the resulting value into r6

	MUL r0, r6, r1
	CMP r0, r5
	BEQ NotPrime
	MOV r4, #0
	MOV r4, r6

	CheckDivisor:
		MOV r0, r5
		MOV r1, r4
		BL __aeabi_idiv

		MOV r2, r0
		MUL r2, r2, r4
		SUB r2, r5, r2
		CMP r2, #0
		BEQ NotPrime

		ADD r4, r4, #-1
		CMP r4, #1
		BEQ Prime
		B CheckDivisor		

	Prime:
		MOV r0, #0

	NotPrime:
		MOV r0, #1

	End:

	LDR lr, [sp, #0]
	LDR r5, [sp, #4]
	LDR r6, [sp, #8]
	LDR r7, [sp, #12]
	ADD sp, sp, #16
	MOV pc, lr

.data
//End isPrime
