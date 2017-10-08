#!/bin/bash -x

# TODO: make telnet login work by default
# For this, examine start_service() in /etc/init.d/telnet and compare with `h'
# (i.e., is it necessary to remove if-then-fi from start_service(), considering that we do
# not use `passwd'?); also, check /bin/login.sh and decide if the following
# must be added there in this build script:
#   #!/bin/sh
#   exec /bin/ash --login
# Also, see https://github.com/openwrt/openwrt/commit/a35a7afc9f15b4c084c996ab0dbcd833b45f30d5

# https://wiki.openwrt.org/doc/howto/build

if [ `whereami` = notebook ]; then
  echo superbuild is done not on notebook, so this script must not be run on notebook
  exit
fi

export PATH=$PATH:~/openwrt/printserver/staging_dir/host/bin

mkdir -p ~/openwrt/
cd ~/openwrt/
[ -d printserver ] && exit
git clone git://github.com/openwrt/openwrt.git printserver
cd printserver/
./scripts/feeds update packages
./scripts/feeds install nfs-utils netcat strace mpc
mkdir -p files/etc/uci-defaults/
cat << EOF > files/etc/uci-defaults/my
uci set network.lan.ipaddr=192.168.1.3
uci set network.lan.gateway=192.168.1.1
uci set network.lan.dns=192.168.1.1
uci commit network
uci set dhcp.lan.ignore=1
uci commit dhcp
uci set system.@system[0].timezone=GMT-7
uci set system.@system[0].log_ip=192.168.1.2
uci commit system
EOF
mkdir -p files/usr/sbin/
ln -s /mnt/prt files/usr/sbin/prt
mkdir -p files/etc/
cat << EOF > files/etc/rc.local
tel | logger -t tel &
exit 0
EOF
cat << EOF > .config
CONFIG_TARGET_ar71xx=y
CONFIG_TARGET_ar71xx_generic=y
CONFIG_TARGET_ar71xx_generic_TLWR1043=y
CONFIG_DEVEL=y
CONFIG_BUILD_NLS=y
CONFIG_SDK=y
CONFIG_PACKAGE_iconv=y
CONFIG_PACKAGE_libcharset=y
CONFIG_PACKAGE_libiconv-full=y
CONFIG_PACKAGE_libintl-full=y
CONFIG_BUSYBOX_CUSTOM=y
CONFIG_BUSYBOX_CONFIG_LAST_SUPPORTED_WCHAR=0
CONFIG_BUSYBOX_CONFIG_LOCALE_SUPPORT=y
CONFIG_BUSYBOX_CONFIG_SUBST_WCHAR=65533
CONFIG_BUSYBOX_CONFIG_UNICODE_PRESERVE_BROKEN=y
CONFIG_BUSYBOX_CONFIG_UNICODE_SUPPORT=y
CONFIG_BUSYBOX_CONFIG_UNICODE_USING_LOCALE=y
CONFIG_PACKAGE_kmod-nls-utf8=y
CONFIG_PACKAGE_kmod-fs-nfs=y
CONFIG_PACKAGE_nfs-utils=y
CONFIG_PACKAGE_strace=y
CONFIG_PACKAGE_netcat=y
CONFIG_PACKAGE_kmod-usb-printer=y
CONFIG_PACKAGE_kmod-usb-serial=y
CONFIG_PACKAGE_kmod-usb-serial-ftdi=y
CONFIG_PACKAGE_mpc=y
EOF
make defconfig
make || exit
rm -f /usr/local/SUPER_DEBIAN/printserver-sdk.tar.bz2
cp bin/ar71xx/OpenWrt-SDK-*.tar.bz2 /usr/local/SUPER_DEBIAN/printserver-sdk.tar.bz2
rm -f /usr/local/SUPER_DEBIAN/printserver-factory.img
cp bin/ar71xx/openwrt-ar71xx-generic-tl-wr1043nd-v1-squashfs-factory.bin /usr/local/SUPER_DEBIAN/printserver-factory.img
rm -f /usr/local/SUPER_DEBIAN/printserver-sysupgrade.img
cp bin/ar71xx/openwrt-ar71xx-generic-tl-wr1043nd-v1-squashfs-sysupgrade.bin /usr/local/SUPER_DEBIAN/printserver-sysupgrade.img


# Flashing instructions:
# rm -f /srv/tftp/fw.bin
# cp /usr/local/SUPER_DEBIAN/printserver.img /srv/tftp/fw.bin
# Quickly type "tpl" when it says autobooting in 1 second.
# setenv ipaddr 192.168.1.3
# setenv serverip 192.168.1.2
# erase 0xbf020000 +7c0000 # 7c0000: size of the firmware *
# tftpboot 0x81000000 fw.bin
# cp.b 0x81000000 0xbf020000 0x7c0000 # 7c0000: size of the firmware *
# bootm 0xbf020000
# * be aware that you may have a different size thus bricking your router (to find out actual value, run this: perl -e 'printf"%x\n",(stat$ARGV[0])[7]' path/to/firmware)
