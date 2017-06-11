#!/bin/bash -x
# https://wiki.openwrt.org/doc/howto/obtain.firmware.generate

# FIXME: recall what was the problem about building firmware image on new year

IMG=OpenWrt-ImageBuilder-15.05.1-ar71xx-generic.Linux-x86_64
SDK=OpenWrt-SDK-15.05.1-ar71xx-generic_gcc-4.8-linaro_uClibc-0.9.33.2.Linux-x86_64
mkdir -p ~/openwrt
cd ~/openwrt
[ -e $IMG.tar.bz2 ] || wget https://downloads.openwrt.org/chaos_calmer/15.05.1/ar71xx/generic/$IMG.tar.bz2 || exit
[ -e $SDK.tar.bz2 ] || wget https://downloads.openwrt.org/chaos_calmer/15.05.1/ar71xx/generic/$SDK.tar.bz2 || exit
rm -fr printserver/
mkdir printserver/
cd printserver/
tar -jxf ../$IMG.tar.bz2
tar -jxf ../$SDK.tar.bz2
cd $IMG/
mkdir -p files/etc/uci-defaults/
cat << EOF > files/etc/uci-defaults/my
uci set network.lan.ipaddr=192.168.1.2
uci commit network
uci set dhcp.lan.ignore=1
uci commit dhcp
EOF
mkdir -p files/usr/sbin/
ln -s /mnt/prt files/usr/sbin/prt
mkdir -p files/etc/config/
cp /usr/local/prt/prt.config files/etc/config/prt
mkdir -p files/etc/init.d/
cp /usr/local/prt/prt.init files/etc/init.d/prt
mkdir -p files/etc/rc.d/
ln -s ../init.d/prt files/etc/rc.d/S50prt
mkdir -p files/etc/
cat << EOF > files/etc/rc.local
while ! mount|grep -q ^192.168.1.3; do
  mount.nfs 192.168.1.3:/usr/local/prt/ /mnt/ -o nolock,vers=3
done
exit 0
EOF
make image PROFILE=TLWR1043 PACKAGES="kmod-usb-printer nfs-utils kmod-fs-nfs" FILES=files/
mv bin/ar71xx/openwrt-15.05.1-ar71xx-generic-tl-wr1043nd-v1-squashfs-factory.bin bin/ar71xx/firmware.bin
