ifeq ($(MAKECMDGOALS),)
CC=prt-gcc
endif

prt: prt.c
	$(CC) -o $@ $<
