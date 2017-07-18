ifeq ($(MAKECMDGOALS),)
ifeq ($(shell whereami),notebook)
CC=prt-gcc
else
CC=
endif
else
CC=clang
endif

prt: prt.c
ifeq ($(CC),)
	@echo You are not on notebook - use \"make prt\"
else
	$(CC) -o $@ $<
endif
