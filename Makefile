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
	@ssh p pkill $@
	@if ssh p pgrep $@; then echo SOMETHING IS WRONG; false; else true; fi
	scp $@ f:/mnt/
endif
endif

select: select.c
	clang -o $@ $< -lutil
