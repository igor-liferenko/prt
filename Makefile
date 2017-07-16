ifeq ($(MAKECMDGOALS),)
CC=prt-gcc
else
CC=clang
endif

prt: prt.c
	$(CC) -o $@ $<
