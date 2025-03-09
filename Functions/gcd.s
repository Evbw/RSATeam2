.text
.global main

main:
	SUB sp, sp, #4
	STR lr, [sp, #0]
	
	LDR r0, =prompt1
	BL printf
	
	LDR r0, =input
	LDR r1, =num1
	BL scanf

	LDR r0, =num1
	LDR r0, [r0]
	MOV r5, r0
	
	LDR r0, =prompt2
	BL printf

	LDR r0, =input
	LDR r1, =num2
	BL scanf

	LDR r0, =num2
	LDR r0, [r0]
	MOV r6, r0

	CMP r6, r5
	BEQ Equal
	
	ContinueProgram:

	StartGCDLoop:
	
	EndGCDLoop:

	Equal:
		MOV r1, r6
		LDR r0, =equalOutput
		BL printf

	LDR lr, [sp, #0]
	ADD sp, sp, #4
	MOV pc, lr

.data
	prompt1: .asciz "Please enter the first term\n"
	prompt2: .asciz "Please enter the second term\n"
	equalOutput: .asciz "The values are the same: %d\n"
	input: .asciz "%d"
	num1: .word 0
	num2: .word 0
