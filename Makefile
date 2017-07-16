ifeq ($(MAKECMDGOALS),)
CC=prt-gcc
else
CC=clang -Weverything
endif

prt: prt.c
	$(CC) -o $@ $<
