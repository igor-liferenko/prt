#!/bin/bash -x

# TODO: add copying sysupgrade image to /usr/local/SUPER_DEBIAN/ also so that it will be possible
# to reflash via mtd and run this script again.

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
./scripts/feeds install nfs-utils netcat strace
mkdir -p files/etc/uci-defaults/
cat << EOF > files/etc/uci-defaults/my
uci set network.lan.ipaddr=192.168.1.2
uci set network.lan.gateway=192.168.1.1
uci set network.lan.dns=192.168.1.1
uci commit network
uci set dhcp.lan.ignore=1
uci commit dhcp
uci set system.@system[0].timezone=GMT-7
uci commit system
EOF
mkdir -p files/usr/sbin/
ln -s /mnt/prt files/usr/sbin/prt
mkdir -p files/etc/
cat << EOF > files/etc/rc.local
while ! mount|grep -q ^192.168.1.3; do
  mount.nfs 192.168.1.3:/home/user/prt/ /mnt/ -o nolock,vers=3
done
prt
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
EOF
make defconfig
make || exit
rm -f /usr/local/SUPER_DEBIAN/printserver-sdk.tar.bz2
cp bin/ar71xx/OpenWrt-SDK-*.tar.bz2 /usr/local/SUPER_DEBIAN/printserver-sdk.tar.bz2
rm -f /usr/local/SUPER_DEBIAN/printserver.img
mv bin/ar71xx/openwrt-ar71xx-generic-tl-wr1043nd-v1-squashfs-factory.bin /usr/local/SUPER_DEBIAN/printserver.img


# Flashing instructions:
# rm -f /srv/tftp/fw.bin
# cp /usr/local/SUPER_DEBIAN/printserver.img /srv/tftp/fw.bin
# Quickly type "tpl" when it says autobooting in 1 second.
# setenv ipaddr 192.168.1.2
# setenv serverip 192.168.1.3
# erase 0xbf020000 +7c0000 # 7c0000: size of the firmware *
# tftpboot 0x81000000 fw.bin
# cp.b 0x81000000 0xbf020000 0x7c0000 # 7c0000: size of the firmware *
# bootm 0xbf020000
# * be aware that you may have a different size thus bricking your router (to find out actual value, run this: perl -e 'printf"%x\n",(stat$ARGV[0])[7]' path/to/firmware)
