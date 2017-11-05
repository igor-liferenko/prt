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
ifeq ($(CC),prt-gcc)
	scp $@ p:/tmp/
	@echo TODO: use pkill pgrep like in bin/hcp.fn
endif
endif

select: select.c
	clang -o $@ $< -lutil
