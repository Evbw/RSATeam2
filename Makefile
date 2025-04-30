ALL: main
LIB=libRSA.o
CC=gcc

main: main.o $(LIB) 
	$(CC) $@.o $(LIB) -g -o $@
.s.o:
	$(CC) $(@:.o=.s) -g -c -o $@
