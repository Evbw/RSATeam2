ALL: RSAlibTest
LIB=libRSA.o
CC=gcc

RSAlibTest: RSAlibTest.o $(LIB) 
	$(CC) $@.o $(LIB) -g -o $@
.s.o:
	$(CC) $(@:.o=.s) -g -c -o $@
