SDK=~/openwrt/printserver/OpenWrt-SDK-15.05.1-ar71xx-generic_gcc-4.8-linaro_uClibc-0.9.33.2.Linux-x86_64

prt: prt.c
	STAGING_DIR=$(SDK)/staging_dir/toolchain* $(SDK)/staging_dir/toolchain*/bin/mips-openwrt-linux-gcc -o prt prt.c
