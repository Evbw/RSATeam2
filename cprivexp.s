#Author: Ayush Goel
#purpose: to get the private key
#input: e and totient
#Output a binary output to say if the number is prime


.text
.global cprivexp
>>>>>>>>>>>
cprivexp:
    // Push stack frame
    SUB sp, sp, #12
    STR lr, [sp, #0]
    STR r4, [sp, #4]
    STR r5, [sp, #8]

    MOV r4, r0          // r4 = totient Φ(n)
    MOV r5, r1          // r5 = public exponent e

    MOV r2, #0          // x = 0

find_x:
    // temp = 1 + x * totient
    MOV r0, r2          // r0 = x
    MUL r0, r0, r4      // r0 = x * totient
    ADD r0, r0, #1      // r0 = (x * totient) + 1

    // check (temp mod e)
    MOV r1, r5          // r1 = e
    BL __aeabi_idivmod  // division: quotient in r0, remainder in r1

    CMP r1, #0          // check if remainder == 0
    BEQ found_x         // if yes, we found correct x

    ADD r2, r2, #1      // x = x + 1
    B find_x            // repeat

found_x:
    // compute d = (1 + x * totient) / e
    // temp = (1 + x * totient) is already calculated above

    // temp is in r0 already (after MUL + ADD)
    MOV r1, r5          // r1 = e
    BL __aeabi_idiv     // r0 = temp / e

    // r0 now holds d

    // Pop and return
    LDR lr, [sp, #0]
    LDR r4, [sp, #4]
    LDR r5, [sp, #8]
    ADD sp, sp, #12
    MOV pc, lr

.data
