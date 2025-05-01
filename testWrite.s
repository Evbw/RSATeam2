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
    	ldr r1, =fp
    	ldr r0, [r1]
    	ldr r1, =msg2
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
	filename:  .asciz "encrypted.txt"
	w_mode:    .asciz "w"
	msg1:      .asciz "This is a secret message.\n"
	msg2:      .asciz "Another encrypted line.\n"

.bss
	fp: .skip 4     @ file pointer (32-bit)



