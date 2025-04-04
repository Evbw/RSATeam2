#Author: Ayush Goel
#purpose: To see if a number is prime
#input: P and Q
#Output a binary output to say if the number is prime


.text
.global isPrime

isPrime:
	
	//push stack record
	SUB sp, sp, #4
	STR lr, [sp]

	MOV r0, r9
	MOV r1, #2//check if the number is less than 2
	MOV r2, #2// counter
		

		CMP r0, r1
		BLT error_1

			prime_loop:

			CMP r0, r2
			BEQ y_prime
			
			MOV r5,r0
			MOV r6,r2
			BL __aeabi_idiv
			SUB r7, r5, r0
			
			CMP r7, #0
			BEQ error_2 //not prime
			

			ADD r2, r2, #1
			B prime_loop

		y_prime:
			LDR r0, #1
			B done

		error_1:
			LDR r0, #0
		
	done:

	LDR lr, [sp]
	ADD sp, sp, #4
	MOV pc, lr

.data


		
		
			
	

	
