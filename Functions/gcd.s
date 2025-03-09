.text
.global main

main:
	SUB sp, sp, #4
	STR lr, [sp, #0]

	LDR lr, [sp, #0]
	ADD sp, sp, #4
	MOV pc, lr
