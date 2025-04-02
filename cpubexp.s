.text
.global cpubexp

cpubexp:

	SUB sp, sp, #4
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

	LDR, r0, =prompt_exp
	BL printf

	LDR, r0, =exp_format
	LDR, r1, =input1
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
		
		LDR, r0, =error_msg
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

	prompt_exp: .asciz "Please enter a number that is: \n between 1 and %d \npositive \n prime \n coprime to %d:
	exp_format:.asciz "%d"
	input1: .word 0
	error_msg: .asciz "your value does not match the specifications, please try again."

