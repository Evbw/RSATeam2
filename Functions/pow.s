# TODO:
#	Figure out how to write a function call
#	Figure out how to handle a stack overflow and underflow
#	Do not allow negative numbers
#	Reconfigure inputs to be accepted from another part of the program

.text
.global main

main:
	SUB sp, sp, #4
	STR lr, [sp, #0]

	LDR r0, =prompt1	#Prompt for the term
	BL printf

	LDR r0, =input		#Accept user input
	LDR r1, =num1
	BL scanf

	LDR r0, =num1		#Get the address of the value entered for num1
	LDR r0, [r0]		#Dereference the address in r0 and store the entered value in r0
	MOV r5, r0		#Store the term in r5 and r7
	MOV r7, r0

	LDR, =prompt2		#Prompt for the exponent
	BL printf

	LDR r0, =input
	LDR r1, =num2
	BL scanf

	LDR r0, =num2
	LDR r0, [r0]		#Same as above, dereference and store the entered value in r0
	MOV r6, r0		#And move to to r6

	StartLoop:		#Begin the loop!
		CMP r6, #1	#Compare the exponent value to 1.
		BLE EndLoop	#Branch it (B) and if the value in r6 is LESS THAN (L) or EQUAL (E) to 1, then move to EndLoop
		
		MUL r7, r7, r5	#Multiply the term by itself through every iteration of the loop and store in r7
		SUB r6, r6, #1	#Reduce the value of the exponent by 1 for every advance through the loop

		B StartLoop	#Branch again and go back to the beginning of the StartLoop procedure

	EndLoop:		#Once the condition is met, end the loop and continue with the program

	MOV r1, r7		#Move the value from r7 to r1

	LDR r0, =output		#Provide output to confirm the program is working
	BL printf

	LDR lr, [sp, #0]
	ADD sp, sp, #4
	MOV pc, lr

.data
	prompt1: .asciz "Please enter a term to take to a power:\n"
	prompt2: .asciz "Please enter an exponent:\n"
	input: .asciz "%d"
	num1: .word 0
	num2: .word 0
	output: .asciz "The result is %d\n"
	
