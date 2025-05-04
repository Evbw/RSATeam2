ALL: RSA
LIB=RSAlib.o
CC=gcc

RSA: RSA.o $(LIB) 
	$(CC) $@.o $(LIB) -g -o $@
.s.o:
	$(CC) $(@:.o=.s) -g -c -o $@
