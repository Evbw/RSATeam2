#
# File name: libRSA
# Authors: Ayush Goel, Calvin Tang, Conner Wright, Everett Bowline
# Editing: Calvin Tang, Everett Bowline
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

//Begin pow
//Author: Everett Bowline

.text
	// Function Input
 	// 	r0 - base
  	// 	r1 - exponent
   	// 	r8 - modulus (n)
 	// Return: 
  	//	r0 - r0^r1 mod r8
pow:
	SUB sp, sp, #20
	STR lr, [sp, #0]
 	STR r5, [sp, #4]
  	STR r6, [sp, #8]
   	STR r7, [sp, #12]
	STR r8, [sp, #16]

	MOV r5, r0		//Store the term in r5 and r7
	MOV r7, r0
	MOV r6, r1		//And move exponent to r6
 	MOV r1, r8		//Move the modulus value to r1
	
	MOV r1, #0
	CMP r6, r1
	BEQ ZeroExp		//If the exponent is zero, handle it
	BLT NegExp		//If the exponent is negative, dismiss it with a return value of -1

	StartLoop:		//Begin the loop!
		CMP r6, #1	//Compare the exponent value to 1.
		BLE EndLoop	//Branch it (B) and if the value in r6 is LESS THAN (L) or EQUAL (E) to 1, then move to EndLoop
		
		MUL r7, r7, r5	//Multiply the term by itself through every iteration of the loop and store in r7
		MOV r0, r7
		BL modulo	//Perform modulo to prevent numbers from getting too large
		MOV r7, r0	//Move the resulting value back to r7

		SUB r6, r6, #1	//Reduce the value of the exponent by 1 for every advance through the loop

		B StartLoop	//Branch again and go back to the beginning of the StartLoop procedure

	EndLoop:		//Once the condition is met, end the loop and continue with the program

		MOV r0, r7	//Move the value from r7 to r0
		B EndPow	//Break to the end of the program

	ZeroExp:
		MOV r0, #1
		B EndPow
	
	NegExp:
	        MOV r0, #-1
		B EndPow

	EndPow:

 	LDR lr, [sp, #0]
 	LDR r5, [sp, #4]
  	LDR r6, [sp, #8]
   	LDR r7, [sp, #12]
	LDR r8, [sp, #16]
	ADD sp, sp, #20
	MOV pc, lr

.data

//End pow

//Begin gcd
//Author: Everett Bowline

.text
 	// Function Input
	// 	r0 - dividend
	// 	r1 - divisor
 	// Return:
  	//	r0 - The greatest common denominator
gcd:
	SUB sp, sp, #16
	STR lr, [sp, #0]
	STR r3, [sp, #4]
	STR r4, [sp, #8]
	STR r2, [sp, #12]

	CMP r0, r1
	BEQ Equal			//Handle an instance when the numerator and denominator are the same value

	MOV r3, #0			//Confirm registers aren't being used for anything (I had some issues compiling if I didn't do this)
	MOV r4, #0
 
	MOVGT r3, r0			//Use the same compare bit to move the greater between r0 and r1 to r3
	MOVGT r4, r1			//and the lesser to r4. The MOV functions use the same comparison flag, so
	MOVLT r4, r0			//MOVGT sees if r0 is greater than r1, and if is, performs the move operation
	MOVLT r3, r1			//MOVLT does the same, but only if r0 is less than r1
	MOV r0, #0			//Move 0 to r0 for comparison
 
	StartGCDLoop:	
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
		MOV r0, r3		//We could move r3 or r4, but they should be the same, so move that value to r0
		B EndGCD		//Branch to end program to prevent any other sections from activating

	LogicError:
		MOV r0, #-1		//Produce error output

	Equal:

	EndGCD:

	LDR lr, [sp, #0]
	LDR r3, [sp, #4]
	LDR r4, [sp, #8]
	LDR r2, [sp, #12]
	ADD sp, sp, #16
	MOV pc, lr

.data
//End gcd

//Begin modulo
//Author: Conner Wright

.text
	// Function Input
	// 	r0 = dividend
	// 	r1 = divisor
	// Return:
 	//	r0 = result of (dividend % divisor)
modulo:
 
// Push the stack

	SUB sp, sp, #20
	STR lr, [sp, #0]
	STR r2, [sp, #4]
    	STR r3, [sp, #8]
	STR r5, [sp, #12]
	STR r6, [sp, #16]

// Perform division
	MOV r5, r0		// Save r0, dividend
    	MOV r6, r1      	// Save r1, divisor
    	BL __aeabi_idiv		// Call division (quotient in r0)

// Store the quotient
	MOV r2, r0		// r2 = quotient

// Multiply the quotient by the divisor
	MOV r3, r2            	// Ensure different register for MUL
	MUL r2, r3, r6        	// r2 = quotient * divisor

// Subtract to get the remainder
	SUB r0, r5, r2		// r0 = dividend - (quotient * divisor)

// Ensure result is non-negative
	CMP r0, #0
	BGE skip_fix
	ADD r0, r0, r1		// Make it positive if needed

	skip_fix:

// Pop the stack (and return to the OS)

    LDR lr, [sp, #0]
    LDR r2, [sp, #4]
    LDR r3, [sp, #8]
    LDR r5, [sp, #12]
    LDR r6, [sp, #16]
    ADD sp, sp, #20
    MOV pc, lr

.data
//End modulo

//Begin cpubexp
//Author: Ayush Goel

.text
	// Function Input
	// 	r0 = p
	// 	r1 = q
	// 	Function dictionary:
	// 	r8 - n
	// 	r5 - totient
 	//Return: 
  	//	r0 = e, public key
	// 	r1 = totient
	// 	r2 = n
cpubexp:
	
	SUB sp, sp, #12
	STR lr, [sp, #0]
	STR r9, [sp, #4]
	STR r10, [sp, #8]

// Preserve p and q
	MOV r10, r0
	MOV r9, r1

// Calculate n
	MUL r8, r9, r10

// Calculate totient
	SUB r7, r10, #1
	SUB r6 ,r9, #1
	MUL r5, r6, r7 		// Store totient in r5

exp_loop:
	MOV r2, r5		//Move totient to r2 and r1 for prompt
	MOV r1, r5

	LDR r0, =prompt_exp	//Request input
	BL printf

	LDR r0, =exp_format
	LDR r1, =input1
	BL scanf
	
	LDR r0, =input1		//Move user input to r0 and r11
	LDR r0, [r0]
	MOV r11, r0  		// r11 = e
	
	CMP r0, #1		//Check if 1 <= e
	BLE Error_msg
		
	CMP r0, r5		//Check if e < totient
	BGE Error_msg
	
	MOV r0, r11		//Move e to r0
	MOV r1, r5		//Move totient to r1
	
	BL gcd			//Check if input is coprime to totient
	CMP r0, #1		//If not equal to 1, then we need a new input
	BNE Error_msg
	B done

	Error_msg:
		
		LDR r0, =error_msg	//Request new input if user input value is invalid
		BL printf
		B exp_loop

	done:
	
	MOV r0, r11		// Move e to r0
	MOV r1, r5		// Move totient to r1
	MOV r2, r8		// Move n to r8

	LDR lr, [sp, #0]
	LDR r9, [sp, #4]
	LDR r10, [sp, #8]
	ADD sp, sp, #12
	MOV pc, lr

.data
	prompt_exp: .asciz "Please enter a number that is between 1 and %d, positive, and coprime to %d:\n"		//Prompt for e value
	exp_format:.asciz "%d"
	input1: .word 0
	error_msg: .asciz "Your value for public key (e) does not match the specifications. Please try again.\n"	//Message to request a new e value
//End cpubexp

//Begin cprivexp
//Author: Ayush Goel

.text
	// Function Input
	// 	r0 = e (public exponent)
	// 	r1 = phi(n) (Euler's totient)
 	// Return:
  	//	r0 - d (private exponent)
cprivexp:
    // Push registers onto the stack
    SUB sp, sp, #32
    STR lr, [sp, #0]
    STR r2, [sp, #4]
    STR r3, [sp, #8]
    STR r5, [sp, #12]
    STR r6, [sp, #16]
    STR r7, [sp, #20]
    STR r8, [sp, #24]
    STR r4, [sp, #28]

    MOV r6, r0        		// Backup e into r6
    MOV r9, r1        		// Backup phi(n) into r9 and r7
    MOV r7, r1
    MOV r2, #1        		// Initialize x = 1

find_x:
    // Calculate numerator: 1 + x * phi
    MUL r3, r2, r7       	// r3 = x * phi
    ADD r3, r3, #1       	// r3 = (x * phi) + 1

    // Backup x before division
    MOV r8, r2

    // Prepare for division
    MOV r0, r3            	// r0 = numerator
    MOV r1, r6           	// r1 = e
    BL __aeabi_idiv      	// Divide

    // Restore x after division
    MOV r2, r8

    // Save quotient
    MOV r4, r0            	// r4 = quotient

    // Recalculate numerator fresh
    MUL r3, r2, r7        	// r3 = x * phi
    ADD r3, r3, #1        	// r3 = (x * phi) + 1

    // Verify: quotient * e == (1 + x * phi)
    MUL r5, r4, r6        	// r5 = quotient * e
    CMP r5, r3            	// Compare
    BEQ found             	// If match, solution found

    // Increment x and loop again
    ADD r2, r2, #1
    B find_x

found:
    MOV r0, r4            	// Move d into r0 for return
    MOV r1, r2            	// Move x value to r1 for return

    // Pop registers and return
    LDR lr, [sp, #0]
    LDR r2, [sp, #4]
    LDR r3, [sp, #8]
    LDR r5, [sp, #12]
    LDR r6, [sp, #16]
    LDR r7, [sp, #20]
    LDR r8, [sp, #24]
    LDR r4, [sp, #28]
    ADD sp, sp, #32
    MOV pc, lr

.data	

//End cprivexp

//Begin encrypt
//Author: Conner Wright

.text

	// Function Input
	//     r0 - ASCII decimal, base
	//     r1 - public key (e), exponent
	//     r2 - modulus (n), mod
	// Return:
	//     r0 - ciphertext (c)

encrypt:

	SUB sp, sp, #4
	STR lr, [sp]

	// Compute modular exponentiation: c = m^e mod n
	BL pow              // result in r0

	// Return result in r0
	LDR lr, [sp]
	ADD sp, sp, #4
	MOV pc, lr

.data
// End encrypt

//Begin isPrime
//Author: Ayush Goel, Calvin Tang

.text
	// Function Input
	// 	r0 - Number to check if Prime
 	//	r4 - term to check
  	//	r5 - divisor
	// Outputs:
	// 	r0 - Binary 1 (True) or 0 (False)
isPrime:
	//push stack record
	SUB sp, sp, #20
    	STR lr, [sp, #0]
	STR r1, [sp, #4]
	STR r2, [sp, #8]
	STR r3, [sp, #12]
	STR r4, [sp, #16]

	// Check if prime
	MOV r4, r0
	MOV r5, #2

	CMP r4, #2			// Statement if r4 == 2
	BNE elsif1
        	MOV r0, #1
	        B endIf1
	elsif1:
        	CMP r4, #2		// Statement if r4 < 2
	        BGT else
        	MOV r0, #0
	        B endIf1
	else:				// Statement if r4 > 2
        	MUL r1, r5, r5
	        CMP r1, r4		// If r1 is greater than r4, then it cannot be a divisor and is prime
        	BGT Prime

	        MOV r0, r4		// r0 = number for prime check
        	MOV r1, r5		// r1 = divisor
	        BL __aeabi_idiv
        
        	MUL r2, r0, r1		// r0 = divided result
	        SUB r3, r4, r2
        	CMP r3, #0		// If r3 = 0, then it divided evenly, so it is not prime
	        BEQ notPrime

        	ADD r5, r5, #1		// Increase the divisor for the next iteration
	        B else

        Prime:
        	MOV r0, #1		// Move immediate 1 to r0 (true)
        	B endIf1
        notPrime: 
        	MOV r0, #0		// Move immediate 0 to r0 (false)
        	B endIf1

	endIf1:

	LDR lr, [sp, #0]
	LDR r1, [sp, #4]
	LDR r2, [sp, #8]
	LDR r3, [sp, #12]
	LDR r4, [sp, #16]
	ADD sp, sp, #20
	MOV pc, lr
.data
//End isPrime

//Begin decrypt
//Author: Conner Wright

.text
	// Function Input
	//	r0 = base
	//	r1 = exponent
	//	r2 = modulus
	// Ouputs:
	// 	r0 = (base^exponent) % modulus
decrypt:
	SUB sp, sp, #4
	STR lr, [sp]

	// Compute modular exponentiation: m = c^d mod n
	BL pow              // result in r0

	// Return result in r0
	LDR lr, [sp]
	ADD sp, sp, #4
	MOV pc, lr
 
.data
// End decrypt
