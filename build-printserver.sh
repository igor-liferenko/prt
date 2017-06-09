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
uci set p910nd.@p910nd[0].enabled=1
uci commit p910nd
EOF
rm -f /usr/local/prt/p910nd
make -C /usr/local/prt/
mkdir -p files/usr/sbin/
cp /usr/local/prt/p910nd files/usr/sbin/
mkdir -p files/etc/config/
cp /usr/local/prt/p910nd.config files/etc/config/p910nd
mkdir -p files/etc/init.d/
cp /usr/local/prt/p910nd.init files/etc/init.d/p910nd
mkdir -p files/etc/rc.d/
ln -s ../init.d/p910nd files/etc/rc.d/S50p910nd
make image PROFILE=GLINET PACKAGES="kmod-usb-printer" FILES=files/
mv bin/ar71xx/openwrt-15.05.1-ar71xx-generic-gl-inet-6416A-v1-squashfs-factory.bin bin/ar71xx/firmware.bin
