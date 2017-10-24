#!/bin/bash -x

# https://wiki.openwrt.org/doc/howto/obtain.firmware.generate

if [ `whereami` = notebook ]; then
  echo superbuild is not done on notebook, so this script must not be run on notebook
  exit
fi
if [ `whereami` != home ]; then
  echo this is used only on notebook, and superbuild for notebook is done at home
  exit
fi

IMG=lede-imagebuilder-17.01.4-ar71xx-generic.Linux-x86_64
SDK=lede-sdk-17.01.4-ar71xx-generic_gcc-5.4.0_musl-1.1.16.Linux-x86_64
mkdir -p ~/lede
cd ~/lede
[ -e $IMG.tar.xz ] || wget https://downloads.lede-project.org/releases/17.01.4/targets/ar71xx/generic/$IMG.tar.xz || exit
[ -e $SDK.tar.xz ] || wget https://downloads.lede-project.org/releases/17.01.4/targets/ar71xx/generic/$SDK.tar.xz || exit
rm -fr printserver/
mkdir printserver/
cd printserver/
tar -Jxf ../$IMG.tar.xz
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
mkdir -p files/usr/sbin/
ln -s /mnt/prt files/usr/sbin/prt
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
make image PROFILE=tl-wr1043nd-v1 PACKAGES="mpc netcat kmod-usb-printer kmod-usb-serial kmod-usb-serial-ftdi nfs-utils kmod-fs-nfs strace" FILES=files/
rm -f /usr/local/SUPER_DEBIAN/printserver-sdk.tar.xz
cp ../../$SDK.tar.xz /usr/local/SUPER_DEBIAN/printserver-sdk.tar.xz
rm -f /usr/local/SUPER_DEBIAN/printserver-factory.img
cp bin/targets/ar71xx/generic/lede-17.01.4-ar71xx-generic-tl-wr1043nd-v1-squashfs-factory.bin /usr/local/SUPER_DEBIAN/printserver-factory.img
rm -f /usr/local/SUPER_DEBIAN/printserver-sysupgrade.img
cp bin/targets/ar71xx/generic/lede-17.01.4-ar71xx-generic-tl-wr1043nd-v1-squashfs-sysupgrade.bin /usr/local/SUPER_DEBIAN/printserver-sysupgrade.img

# Flashing instructions:
# rm -f /srv/tftp/fw.bin
# cp /usr/local/SUPER_DEBIAN/printserver-factory.img /srv/tftp/fw.bin
# Quickly type "tpl" when it says autobooting in 1 second.
# setenv ipaddr 192.168.1.3
# setenv serverip 192.168.1.2
# erase 0xbf020000 +7c0000 # 7c0000: size of the firmware *
# tftpboot 0x81000000 fw.bin
# cp.b 0x81000000 0xbf020000 0x7c0000 # 7c0000: size of the firmware *
# bootm 0xbf020000
# * be aware that you may have a different size thus bricking your router (to find out actual value, run this: perl -e 'printf"%x\n",(stat$ARGV[0])[7]' path/to/firmware)
