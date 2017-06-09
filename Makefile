SDK=~/openwrt/printserver/OpenWrt-SDK-15.05.1-ar71xx-generic_gcc-4.8-linaro_uClibc-0.9.33.2.Linux-x86_64

p910nd: p910nd.c
	STAGING_DIR=$(SDK)/staging_dir/toolchain* $(SDK)/staging_dir/toolchain*/bin/mips-openwrt-linux-gcc -Wall -Wextra -Wconversion -Wsign-compare -Wsign-conversion -fno-show-column -fno-diagnostics-show-caret -DLOCKFILE_DIR=\"/tmp\" -o p910nd p910nd.c
