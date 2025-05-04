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
////////////////

    	// fopen("encrypted.txt", "r")
    	ldr r0, =infile
    	ldr r1, =r_mode
    	bl fopen
    	ldr r1, =in_fp
    	str r0, [r1]

    	// fopen("plaintext.txt", "w")
    	ldr r0, =outfile
    	ldr r1, =w_mode
    	bl fopen
    	ldr r1, =out_fp
    	str r0, [r1]

	read_loop:

    		// fgets(buffer, 256, in_fp)
    		ldr r0, =buffer
    		mov r1, #256
		ldr r2, =in_fp
    		ldr r2, [r2]
    		bl fgets
    		cmp r0, #0
    		beq done

    		// fprintf(out_fp, buffer)
		ldr r0, =out_fp
    		ldr r0, [r0]
    		ldr r1, =buffer
    		bl fprintf
    		b read_loop

	done:

    		// fclose(in_fp)
		ldr r0, =in_fp
    		ldr r0, [r0]
    		bl fclose

    		// fclose(out_fp)
		ldr r0, =out_fp
    		ldr r0, [r0]
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
	buffer:   .space 256
	infile:   .asciz "encrypted.txt"
	outfile:  .asciz "plaintext.txt"
	r_mode:   .asciz "r"

.bss

	fp: .skip 4     @ file pointer (32-bit)
	in_fp:  .skip 4
	out_fp: .skip 4
