.global main
.global modulo

.text

main:
	SUB sp, sp, #28
	STR lr, [sp, #0]
	STR r4, [sp, #4]
	STR r5, [sp, #8]
	STR r6, [sp, #12]
	STR r7, [sp, #16]
	STR r8, [sp, #20]
	STR r9, [sp, #24]

	LDR r0, =prompt
	BL printf

	LDR r0, =input
	LDR r1, =num
	BL scanf

	LDR r7, =input
	LDR r7, [r7]

	LDR r0, =prompt2
	BL printf

	LDR r0, =input
	LDR r1, =num
	BL scanf

	LDR r1, =input
	LDR r1, [r1]

	MOV r0, r7
	
	MOV r6, r0
	MOV r6, r1

	MOV r2, #1

findx:

	MUL r3, r2, r7
	ADD r4, r3, #1

	MOV r0, r4
	MOV r1, r6
	BL modulo

	CMP r0, #0
	BEQ found

	Add r2, r2, #1
	B findx

found:
	MOV r0, r4
	MOV r1, r6
	BL __aeabi_idiv

	MOV r1, r0

	LDR r0, =output
	BL printf
	
	LDR lr, [sp, #0]
	LDR r4, [sp, #4]
	LDR r5, [sp, #8]
	LDR r6, [sp, #12]
	LDR r7, [sp, #16]
	LDR r8, [sp, #20]
	STR r9, [sp, #24]
	ADD sp, sp, #28
	MOV pc, lr

.data

	prompt: .asciz "p<50:\n"
	prompt2: .asciz "q<50:\n"
	input: .asciz "%d"
	num: .word 0
	output: .asciz "r0 = %d and r1 = %d.\n"

.text

modulo:

	SUB sp, sp, #28
	STR lr, [sp, #0]
	STR r4, [sp, #4]
	STR r5, [sp, #8]
	STR r6, [sp, #12]
	STR r7, [sp, #16]
	STR r8, [sp, #20]
	STR r9, [sp, #24]

	MOV r5, r0
	BL __aeabi_idiv
	
	MOV r3, r0

	MOV r2, r0
	MUL r2, r3, r1

	SUB r0, r5, r2


	LDR lr, [sp, #0]
	LDR r4, [sp, #4]
	LDR r5, [sp, #8]
	LDR r6, [sp, #12]
	LDR r7, [sp, #16]
	LDR r8, [sp, #20]
	STR r9, [sp, #24]
	ADD sp, sp, #28
	MOV pc, lr
.data

