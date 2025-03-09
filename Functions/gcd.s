# TODO:
#	Handle a function call
#	Handle stack overflow and underflow
#	Handle invalid input (negative numbers or letters, for example)
#	Reconfigure inputs to be accepted from another part of the program

.text
.global main

main:
	SUB sp, sp, #4
	STR lr, [sp, #0]
	
	LDR r0, =prompt1		//Request user input	
	BL printf
	
	LDR r0, =input
	LDR r1, =num1
	BL scanf

	LDR r0, =num1
	LDR r0, [r0]
	MOV r5, r0			//Move the value of the input of the first value to r5
	
	LDR r0, =prompt2
	BL printf

	LDR r0, =input
	LDR r1, =num2
	BL scanf

	LDR r0, =num2
	LDR r0, [r0]
	MOV r6, r0			//Move the value of the input of the second value to r6

	CMP r6, r5
	BEQ Equal			//Handle an instance when they are the same value

	MOV r3, #0
	MOV r4, #0			//Confirm registers aren't being used for anything (I had some issues compiling if I didn't do this)

	CMP r6, r5
	MOVGT r3, r6			//Compare the value in r6 (second input value) to the one in r5. Move the greater to r3
	MOVGT r4, r5			//and the lesser to r4. The MOV functions use the same comparison flag, so
	MOVLT r4, r6			//MOVGT sees if r6 is greater than r5, and if is, performs the move operation
	MOVLT r3, r5			//MOVLT does the same, but only if r6 is less than r5

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
		MOV r1, r3		//We could move r3 or r4, but they should be the same, so move that value to r1
		MOV r2, #1		//Move the immediate value 1 to r2
		CMP r1, r2		//If the number in r1 is, in fact, 1, then the two numbers do not have a common denominator
		BEQ NoGCD		//So goto NoGCD

		LDR r0, =gcdOutput	//Otherwise continue with the output of the appropriate number
		BL printf

		B EndProgram		//Branch to end program to prevent any other sections from activating

	LogicError:
		LDR r0, =error		//Produce error output
		BL printf

		B EndProgram

	Equal:
		MOV r1, r6		//If the values are equal, produce equalOutput to let the user know
		LDR r0, =equalOutput
		BL printf
		B EndProgram
	
	NoGCD:				//If the value reached is 1, as would be the case with 5 and 7, say, then produce noCommon output
		LDR r0, =noCommon
		BL printf
		B EndProgram

	EndProgram:

	LDR lr, [sp, #0]
	ADD sp, sp, #4
	MOV pc, lr

.data
	prompt1: .asciz "Please enter the first term\n"				//prompts/output to present to user at appropriate parts of
	prompt2: .asciz "Please enter the second term\n"			//the program
	equalOutput: .asciz "The values are the same: %d\n"
	noCommon: .asciz "Resulted in %d. There is no GCD.\n"
	gcdOutput: .asciz "The greatest common denominator is %d.\n"
	error: .asciz "The calculation resulted in a negative number.\n"
	input: .asciz "%d"							//Value for user input
	num1: .word 0								//Values to store user input
	num2: .word 0
