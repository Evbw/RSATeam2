#Author: Ayush Goel
#purpose: to get the private key
#input: e and totient
#Output a binary output to say if the number is prime


.text
.global cprivexp

cprivexp:
	
	//push stack record
	SUB sp, sp, #4
	STR lr, [sp]

	MOV r12, r0
	MOV r13, r1 //preserving the toteint and the public key

	MOV r0, #1
	MOV r1, r13
	
	#getting modulo to do d = (1(mod(totient)))/e
	BL modulo // 
	MOV r1, r12
	BL __aeabi_div
	
	
	
	MOV r1, #2//check if the number is less than 2
	MOV r2, #2// counter

	LDR lr, [sp]
	ADD sp, sp, #4
	MOV pc, lr

.data


		
		
			
	

	
