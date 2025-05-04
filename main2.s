//
// Program Name: main.s
// Section 81 Team 2
// Purpose: Encrypt sender's message to be decrypted and read by receiver
//

.text
.global main

main:
	// Program dictionary:
	// r4 - public key (e)
	// r5 - private key (d)
	// r6 - totient
	// r7 - modulus (n)
	// r8 - encrypt, message index register

	// push stack record
	SUB sp, sp, #4
	STR lr, [sp, #0]

	LDR r0, =introPrompt
	BL printf

p_StartLoop:
	LDR r0, =prompt1
	BL printf
	LDR r0, =format1
	LDR r1, =pValue
	BL scanf

	LDR r0, =pValue
	LDR r0, [r0]
	CMP r0, #0
	MOVLE r1, #0
	MOVGT r1, #1
	BL isPrime
	AND r0, r0, r1
	CMP r0, #1
	BNE p_error
	B p_EndLoop
p_error:
	LDR r0, =p_ErrorMsg1
	BL printf
	B p_StartLoop

p_EndLoop:
q_StartLoop:
	LDR r0, =prompt2
	BL printf
	LDR r0, =format1
	LDR r1, =qValue
	BL scanf

	LDR r0, =qValue
	LDR r0, [r0]
	CMP r0, #0
	MOVLE r1, #0
	MOVGT r1, #1
	BL isPrime
	AND r0, r0, r1
	CMP r0, #1
	BNE q_error
	B q_EndLoop
q_error:
	LDR r0, =q_ErrorMsg1
	BL printf
	B q_StartLoop

q_EndLoop:

	// Generate public key
	LDR r0, =pValue
	LDR r0, [r0]
	LDR r1, =qValue
	LDR r1, [r1]
	BL cpubexp
	MOV r4, r0
	MOV r6, r1
	MOV r7, r2

	// Generate private key
	BL cprivexp
	MOV r5, r0

	B MenuLoop

MenuLoop:
	LDR r0, =menuPrompt
	BL printf
	LDR r0, =input
	LDR r1, =num
	BL scanf
	LDR r0, =num
	LDR r0, [r0]
	CMP r0, #-1
	BLE EndProgram
	CMP r0, #1
	BEQ p_StartLoop
	CMP r0, #2
	BEQ EncryptSection
	CMP r0, #3
	BGE DecryptSection

@ ----- START ENCRYPT SECTION -----
EncryptSection:
	LDR r0, =messagePrompt
	BL printf
	BL getchar
	LDR r0, =stringFormat
	LDR r1, =messageBuffer
	BL scanf

	LDR r0, =encryptedFile
	LDR r1, =fileWriteMode
	BL fopen
	LDR r1, =fp
	STR r0, [r1]

	LDR r8, =messageBuffer

encrypt_loop:
	LDRB r3, [r8]
	CMP r3, #0
	BEQ encrypt_done

	MOV r0, r3
	MOV r1, r4
	MOV r2, r7
	BL encrypt

	MOV r2, r0
	LDR r1, =encryptWritingFormat
	LDR r3, =fp
	LDR r0, [r3]
	BL fprintf

	ADD r8, r8, #1
	B encrypt_loop

encrypt_done:
	LDR r1, =fp
	LDR r0, [r1]
	BL fclose
	LDR r0, =encryptSuccess
	BL printf
	B MenuLoop

@ ----- START DECRYPT SECTION -----
DecryptSection:
	LDR r0, =encryptedFile
	LDR r1, =fileReadMode
	BL fopen
	LDR r1, =in_fp
	STR r0, [r1]

	LDR r0, =plaintextFile
	LDR r1, =fileWriteMode
	BL fopen
	LDR r1, =out_fp
	STR r0, [r1]

decrypt_loop:
	LDR r0, =in_fp
	LDR r0, [r0]
	LDR r1, =decryptReadingFormat
	LDR r2, =decryptNum
	BL fscanf
	CMP r0, #1
	BNE decrypt_done

	LDR r0, =decryptNum
	LDR r0, [r0]
	MOV r1, r5
	MOV r2, r7
	BL decrypt

	MOV r2, r0
	LDR r0, =out_fp
	LDR r0, [r0]
	LDR r1, =decryptWritingFormat
	BL fprintf

	B decrypt_loop

decrypt_done:
	LDR r0, =in_fp
	LDR r0, [r0]
	BL fclose

	LDR r0, =out_fp
	LDR r0, [r0]
	BL fclose

	LDR r0, =decryptSuccess
	BL printf
	B MenuLoop

EndProgram:
	MOV r0, #1
	LDR lr, [sp, #0]
	ADD sp, sp, #4
	MOV pc, lr

.data
introPrompt: .asciz "Welcome to our RSA algorithm program. We first require a cipher:\n"
menuPrompt: .asciz "Please choose an encryption (1), encrypt a message using that cipher (2), or decrypt a message using that cipher (3), or exit the program (-1):\n"
prompt1: .asciz "Receiver, input a positive prime number for p: \n"
prompt2: .asciz "Receiver, input a different positive prime number for q: \n"
decryptPrompt: .asciz "Searching for a file named encrypted.txt:\n"
encryptSuccess: .asciz "\nThe message has been encrypted and exported to encrypted.txt.\n\n"
decryptSuccess: .asciz "\nThe message has been decrypted and exported to plaintext.txt.\n\n"

format1: .asciz "%d"
stringFormat: .asciz "%[^\n]"
input: .asciz "%d"
num: .word 0

pValue: .word 0
qValue: .word 0

p_ErrorMsg1: .asciz "Invalid p value. Requirement: p must be a positive prime number.\n"
q_ErrorMsg1: .asciz "Invalid q value. Requirement: q must be a different positive prime number.\n"

messagePrompt: .asciz "Please enter the message to encrypt: \n"
encryptWritingFormat: .asciz "%d\n"

messageBuffer: .space 255
messageLength: .word 100
cipherTextFile: .asciz "encrypted.txt"

encryptedFile: .asciz "encrypted.txt"
plaintextFile: .asciz "plaintext.txt"
fileReadMode: .asciz "r"
fileWriteMode: .asciz "w"
cipherTextBuffer: .space 4
plaintextBuffer: .space 1
decryptNum: .space 256
decryptReadingFormat: .asciz "%d"
decryptWritingFormat: .asciz "%c"

.bss
fp: .skip 4
in_fp: .skip 4
out_fp: .skip 4

