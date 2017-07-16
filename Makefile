ifeq ($(MAKECMDGOALS),)
CC=prt-gcc
else
CC=cc
endif

prt: prt.c
	$(CC) -o $@ $<
