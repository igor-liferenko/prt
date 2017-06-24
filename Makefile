CC:=$(shell if [ `whereami` != notebook ]; then echo gcc; else echo STAGING_DIR=/var/local/printserver-sdk /var/local/printserver-sdk/bin/mips-openwrt-linux-gcc; fi)

prt: prt.c
	$(CC) -Wall -Wextra -Wconversion -Wsign-compare -Wsign-conversion -fno-show-column -fno-diagnostics-show-caret -o prt prt.c
