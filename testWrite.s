.text
.global main
main:
	// push stack
	SUB sp, sp, #4
	STR lr, [sp, #0]

    	// fopen("encrypted.txt", "w")
    	ldr r0, =filename
    	ldr r1, =w_mode
    	bl fopen
    	ldr r1, =fp
    	str r0, [r1]        @ Save file pointer

    	// fprintf(fp, msg1)
    	ldr r0, [r1]
    	ldr r1, =msg1
    	bl fprintf

    	// fprintf(fp, msg2)
	LDR r0, =prompt
	BL printf
	LDR r0, =format
	LDR r1, =msg2
	BL scanf

	LDR r2, =msg2
	LDR r2, [r2]
	LDR r1, =format
    	ldr r3, =fp
    	ldr r0, [r3]
    	bl fprintf

    	// fclose(fp)
    	ldr r1, =fp
    	ldr r0, [r1]
    	bl fclose

    	mov r0, #0

	// pop stack
	LDR lr, [sp, #0]
	ADD sp, sp, #4
	MOV pc, lr

.data
	// Prompt
	prompt: .asciz "Enter a number: \n"
	filename:  .asciz "encrypted.txt"
	w_mode:    .asciz "w"
	msg1:      .asciz "This is a secret message.\n"
	format: .asciz "%d"
	msg2:      .word 0

.bss

	fp: .skip 4     @ file pointer (32-bit)

