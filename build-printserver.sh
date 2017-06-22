#!/bin/bash -x
# https://wiki.openwrt.org/doc/howto/obtain.firmware.generate

IMG=OpenWrt-ImageBuilder-15.05.1-ar71xx-generic.Linux-x86_64
SDK=OpenWrt-SDK-15.05.1-ar71xx-generic_gcc-4.8-linaro_uClibc-0.9.33.2.Linux-x86_64

if ! [ -d /var/local/printserver/$SDK/ ]; then
  rm -f /usr/local/SUPER_DEBIAN/printserver-sdk.tar.bz2
  wget -O /usr/local/SUPER_DEBIAN/printserver-sdk.tar.bz2 https://downloads.openwrt.org/chaos_calmer/15.05.1/ar71xx/generic/$SDK.tar.bz2 || exit
  rm -fr /var/local/printserver/
  mkdir /var/local/printserver/
  tar -C /var/local/printserver -jxf /usr/local/SUPER_DEBIAN/printserver-sdk.tar.bz2
  rm -f /var/local/printserver-sdk
  ln -s /var/local/printserver/*/staging_dir/toolchain* /var/local/printserver-sdk
fi
mkdir -p ~/openwrt
cd ~/openwrt
[ -e $IMG.tar.bz2 ] || wget https://downloads.openwrt.org/chaos_calmer/15.05.1/ar71xx/generic/$IMG.tar.bz2 || exit
rm -fr printserver/
mkdir printserver/
cd printserver/
tar -jxf ../$IMG.tar.bz2
cd $IMG/
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
  mount.nfs 192.168.1.3:/usr/local/prt/ /mnt/ -o nolock,vers=3
done
prt
exit 0
EOF
make image PROFILE=TLWR1043 PACKAGES="kmod-usb-printer nfs-utils kmod-fs-nfs netcat strace" FILES=files/
mv bin/ar71xx/openwrt-15.05.1-ar71xx-generic-tl-wr1043nd-v1-squashfs-factory.bin /srv/tftp/fw.bin

# Flashing instructions:
# Quickly type "tpl" when it says autobooting in 1 second.
# setenv ipaddr 192.168.1.2
# setenv serverip 192.168.1.3
# erase 0xbf020000 +7c0000 # 7c0000: size of the firmware *
# tftpboot 0x81000000 fw.bin
# cp.b 0x81000000 0xbf020000 0x7c0000 # 7c0000: size of the firmware *
# bootm 0xbf020000
# * be aware that you may have a different size thus bricking your router (to find out actual value, run this: perl -e 'printf"%x\n",(stat$ARGV[0])[7]' path/to/firmware)
