prt: prt.c
	STAGING_DIR=${SDK}/staging_dir/toolchain* ${SDK}/staging_dir/toolchain*/bin/mips-openwrt-linux-gcc -o prt prt.c
