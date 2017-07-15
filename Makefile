ifeq ($(MAKECMDGOALS),)
CC=prt-gcc
else
CC=gcc
endif

prt: prt.c
	$(CC) -o $@ $<
