#!/bin/bash -x

if [ `whereami` = notebook ]; then
  echo superbuild is done not on notebook, so this script must not be run on notebook
  exit
fi

# https://wiki.openwrt.org/doc/howto/obtain.firmware.generate

# NOTE: add vsyscall=emulate to grub because of this script terminates with segfault (revert afterwards)

IMG=OpenWrt-ImageBuilder-ar71xx-generic.Linux-x86_64
SDK=OpenWrt-SDK-ar71xx-generic_gcc-5.3.0_musl-1.1.16.Linux-x86_64
mkdir -p ~/openwrt
cd ~/openwrt
[ -e $IMG.tar.bz2 ] || wget https://downloads.openwrt.org/snapshots/trunk/ar71xx/generic/$IMG.tar.bz2 || exit
[ -e $SDK.tar.bz2 ] || wget https://downloads.openwrt.org/snapshots/trunk/ar71xx/generic/$SDK.tar.bz2 || exit
rm -fr printserver/
mkdir printserver/
cd printserver/
tar -jxf ../$IMG.tar.bz2
cd $IMG/
mkdir -p files/etc/uci-defaults/
cat << EOF > files/etc/uci-defaults/my
uci set network.lan.ipaddr=192.168.1.3
uci set network.lan.gateway=192.168.1.1
uci set network.lan.dns=192.168.1.1
uci commit network
uci set dhcp.lan.ignore=1
uci commit dhcp
uci set system.@system[0].timezone=GMT-7
uci commit system
EOF
mkdir -p files/etc/
cat << EOF > files/etc/rc.local
tel &
cat <<FOE | sh &
while ! mount|grep -q ^192.168.1.2; do
  mount.nfs 192.168.1.2:/home/user/prt/ /mnt/ -o nolock,vers=3
done
prt
FOE
exit 0
EOF
make image PROFILE=TLWR1043 PACKAGES="mpc netcat kmod-usb-printer kmod-usb-serial kmod-usb-serial-ftdi strace socat" FILES=files/
rm -f /usr/local/SUPER_DEBIAN/printserver-sdk.tar.bz2
cp ../../$SDK.tar.bz2 /usr/local/SUPER_DEBIAN/printserver-sdk.tar.bz2
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
