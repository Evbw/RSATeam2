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
	SUB sp, sp, #16
	STR lr, [sp, #0]
 	STR r5, [sp, #4]
  	STR r6, [sp, #8]
   	STR r7, [sp, #12]

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

 	LDR lr, [sp, #0]
 	LDR r5, [sp, #4]
  	LDR r6, [sp, #8]
   	LDR r7, [sp, #12]
	ADD sp, sp, #16
	MOV pc, lr

.data

//End pow

.text

gcd:
	SUB sp, sp, #20
	STR lr, [sp, #0]
	STR r3, [sp, #4]
	STR r4, [sp, #8]
	STR r2, [sp, #12]
	STR r6, [sp, #16]

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

	EndGCD:

	LDR lr, [sp, #0]
	LDR r3, [sp, #4]
	LDR r4, [sp, #8]
	LDR r2, [sp, #12]
	LDR r5, [sp, #16]
	ADD sp, sp, #20
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
    STR r1, [sp, #4]

# Perform division
    MOV r5, r0            // Save dividend
    BL __aeabi_idiv       // Call division (quotient in r0)

# Store the quotient
    MOV r2, r0            // r2 = quotient

# Multiply the quotient by the divisor
    MOV r3, r2            // Ensure different register for MUL
    MUL r2, r3, r1        // r2 = quotient * divisor

# Subtract to get the remainder
    SUB r0, r5, r2        // r0 = dividend - (quotient * divisor)

# Ensure result is non-negative
    CMP r0, #0
    BGE skip_fix
    ADD r0, r0, r1        // Make it positive if needed
    
    skip_fix:

# Pop the stack (and return to the OS)
    LDR lr, [sp, #0]
    LDR r1, [sp, #4]
    ADD sp, sp, #8
    MOV pc, lr

.data
//End modulo

.text

cpubexp:
	// Input:
	// 	r0 = p
	// 	r1 = q
	// Output:
	// 	r0 = e, public key
	// 	r1 = totient
	// 	r2 = n

	// Function dictionary:
	// r10 - p
	// r9 - q
	// r8 - n
	// r5 - totient

	SUB sp, sp, #20
	STR lr, [sp, #0]
	STR r5, [sp, #4]
	STR r8, [sp, #8]
	STR r9, [sp, #12]
	STR r10, [sp, #16]

	// Preserve p and q
	MOV r10, r0
	MOV r9, r1

	// calculating n
	MUL r8, r9, r10

	// calculating totient
	SUB r7, r10, #1
	SUB r6 ,r9, #1
	MUL r5, r6, r7 //totient

	exp_loop:
	MOV r2, r5		//Move totient to r2 and r1
	MOV r1, r5

	LDR r0, =prompt_exp	//Request input
	BL printf

	LDR r0, =exp_format
	LDR r1, =input1
	BL scanf
	
	LDR r0, =input1		//Move user input to r0 and r11
	LDR r0, [r0]
	MOV r11, r0  // r11 = e
	
	CMP r0, #1		// Check if 1 < e
	BLE Error_msg
		
	CMP r0, r5		// Check if e < totient
	BGE Error_msg
	
	MOV r0, r11
	MOV r1, r5
	
	BL gcd			//Checking if input is coprime to totient
	CMP r0, #1		//If not equal to 1, then we need a new input
	BNE Error_msg
	B done

	Error_msg:
		
		LDR r0, =error_msg	//Request new input if user input value is invalid
		BL printf
		B exp_loop

	done:
	
	MOV r0, r11
	MOV r1, r5
	MOV r2, r8

	LDR lr, [sp, #0]
	LDR r5, [sp, #4]
	LDR r8, [sp, #8]
	LDR r9, [sp, #12]
	LDR r10, [sp, #16]
	ADD sp, sp, #20
	MOV pc, lr


.data

	prompt_exp: .asciz "Please enter a number that is between 1 and %d, positive, and coprime to %d:\n"
	exp_format:.asciz "%d"
	input1: .word 0
	error_msg: .asciz "Your value for public key (e) does not match the specifications. Please try again.\n"
//End cpubexp

.text

cprivexp:
    // Push registers onto the stack
    SUB sp, sp, #32
    STR lr, [sp, #0]
    STR r4, [sp, #4]
    STR r5, [sp, #8]
    STR r6, [sp, #12]
    STR r8, [sp, #16]
    STR r7, [sp, #20]
    STR r2, [sp, #24]
    STR r3, [sp, #28]

    // Inputs:
    // r0 = e (public exponent)
    // r1 = phi(n) (Euler's totient)

    MOV r6, r0        // Backup e into r6
    MOV r7, r1        // Backup phi(n) into r7
    MOV r2, #1        // Initialize x = 1

find_x:
    // Calculate numerator: 1 + x * phi
    MUL r3, r2, r7        // r3 = x * phi
    ADD r3, r3, #1        // r3 = (x * phi) + 1

    // Backup x before division
    MOV r8, r2

    // Prepare for division
    MOV r0, r3            // r0 = numerator
    MOV r1, r6            // r1 = e
    BL __aeabi_idiv       // Divide

    // Restore x after division
    MOV r2, r8

    // Save quotient
    MOV r4, r0            // r4 = quotient

    // Recalculate numerator fresh
    MUL r3, r2, r7        // r3 = x * phi
    ADD r3, r3, #1        // r3 = (x * phi) + 1

    // Verify: quotient * e == (1 + x * phi)
    MUL r5, r4, r6        // r5 = quotient * e
    CMP r5, r3            // Compare
    BEQ found             // If match, solution found

    // Increment x and loop again
    ADD r2, r2, #1
    B find_x

found:
    MOV r0, r4            // Move d into r0 for return
    MOV r1, r2            // Move x value to r1 for return

    // Pop registers and return
    LDR lr, [sp, #0]
    LDR r4, [sp, #4]
    LDR r5, [sp, #8]
    LDR r6, [sp, #12]
    LDR r8, [sp, #16]
    LDR r7, [sp, #20]
    LDR r2, [sp, #24]
    LDR r3, [sp, #28]
    ADD sp, sp, #32
    MOV pc, lr

.data	

//End cprivexp

.text
encrypt:

    SUB sp, sp, #4
    STR lr, [sp]

    // Compute m^e using pow
    BL pow              // result in r0

    // r0 now has m^e
    MOV r1, r2
    BL modulo           // r0 = (m^e) mod n

    // Return result in r0
    LDR lr, [sp]
    ADD sp, sp, #4
    MOV pc, lr

    //SUB sp, sp, #12
    //STR lr, [sp]
    //STR r2, [sp, #4]    @ Save n
    //STR r1, [sp, #8]    @ Save e

    //@ Compute m^e using pow
    //MOV r1, r1          @ exponent
    //MOV r0, r0          @ base
    //BL pow              @ result in r0

    //@ r0 now has m^e
    //LDR r1, [sp, #4]    @ r1 = n (modulus)
    //BL modulo           @ r0 = (m^e) mod n

    //@ Return result in r0
    //LDR lr, [sp]
    //ADD sp, sp, #12
    //MOV pc, lr

.data
// END encrypt


.text

isPrime:
	// Inputs:
	// 	r0 - Number to check if Prime
	// Outputs:
	// 	r0 - Binary 1 (True) or 0 (False)

	//push stack record
	SUB sp, sp, #24
    	STR lr, [sp, #0]
	STR r1, [sp, #4]
	STR r2, [sp, #8]
	STR r3, [sp, #12]
	STR r4, [sp, #16]
	STR r5, [sp, #20]

	// Function dictionary
	// r4 - number for prime check
	// r5 - divisor

	// Check if prime
	MOV r4, r0
	MOV r5, #2

	CMP r4, #2
	BNE elsif1
        // Statement if r4 == 2
        	MOV r0, #1
	        B endIf1
	elsif1:
        	CMP r4, #2
	        BGT else
        // Statement if r4 < 2
        	MOV r0, #0
	        B endIf1
	else:
        // Statement if r4 > 2
		MUL r1, r5, r5
	        CMP r1, r4
        	BGT Prime

        // r0 = number for prime check
        // r1 = divisor
	        MOV r0, r4
        	MOV r1, r5
	        BL __aeabi_idiv
        // r0 = divided result
        	MUL r2, r0, r1
	        SUB r3, r4, r2
        	CMP r3, #0
	        BEQ notPrime

        	ADD r5, r5, #1
	        B else

        Prime:
        	MOV r0, #1
        	B endIf1
        notPrime: 
        	MOV r0, #0
        	B endIf1

	endIf1:

	LDR lr, [sp, #0]
	LDR r1, [sp, #4]
	LDR r2, [sp, #8]
	LDR r3, [sp, #12]
	LDR r4, [sp, #16]
	LDR r5, [sp, #20]
	ADD sp, sp, #24
	MOV pc, lr
.data
//End isPrime


.text
decrypt:

	// push stack record
	SUB sp, sp, #24
	STR lr, [sp, #0]
	STR r4, [sp, #4]
	STR r5, [sp, #8]
	STR r6, [sp, #12]
	STR r7, [sp, #16]
	STR r3, [sp, #20]

	// Purpose: decrypt an ciphertext using private key; result=(b^e) mod n
	// Input:
	//     r0 - ciphertext (c)
	//     r1 - private key (d)
	//     r2 - modulus (n)
	// Output:
	//     r0 - plaintext (m)

	// Function dictionary
	// r4 - ciphertext (c), base %d
	// r5 - private key (d), exponent %d
	// r6 - modulus (n), %d

    	MOV r3, r0          // base = ciphertext (c)
    	MOV r4, r1          // exponent = private exponent (d)
    	MOV r5, r2          // modulus = n
    	MOV r6, #1          // result = 1

	decrypt_loop:
    		CMP r4, #0          // while exponent > 0
    		BEQ decrypt_done

    		AND r7, r4, #1      // if (exponent & 1)
    		CMP r7, #0
    		BEQ decrypt_skip_multiply

    		// result = (result * base) % modulus
    		MUL r6, r6, r3
    		MOV r0, r6          // dividend = result * base
    		MOV r1, r5          // divisor = modulus
    		BL __aeabi_idiv     // call signed divide
    		// after BL, quotient in r0
    		MUL r7, r0, r5      // r7 = quotient * modulus
    		SUB r6, r6, r7      // r6 = (result * base) - (quotient * modulus)

	decrypt_skip_multiply:
    		// base = (base * base) % modulus
    		MUL r3, r3, r3
    		MOV r0, r3          // dividend = base * base
    		MOV r1, r5          // divisor = modulus
    		BL __aeabi_idiv
    		// after BL, quotient in r0
    		MUL r7, r0, r5      // r7 = quotient * modulus
    		SUB r3, r3, r7      // r3 = (base * base) - (quotient * modulus)

    		// exponent = exponent >> 1
    		LSRS r4, r4, #1

    		B decrypt_loop

	decrypt_done:

	MOV r0, r6          // move final result into r0

	// pop stack record
	LDR lr, [sp, #0]
	LDR r4, [sp, #4]
	LDR r5, [sp, #8]
	LDR r6, [sp, #12]
	LDR r7, [sp, #16]
	LDR r3, [sp, #20]
	ADD sp, sp, #24
	MOV pc, lr

.data
// END decrypt



