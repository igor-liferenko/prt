#!/bin/bash -x

# this router is to convert from IP to USB for printer

IMG=lede-imagebuilder-17.01.7-ramips-rt305x.Linux-x86_64
SDK=lede-sdk-17.01.7-ramips-rt305x_gcc-5.4.0_musl-1.1.16.Linux-x86_64
URL=https://downloads.openwrt.org/releases/17.01.7/targets/ramips/rt305x
mkdir -p ~/lede
cd ~/lede
[ -e $IMG.tar.xz ] || wget $URL/$IMG.tar.xz || exit
[ -e $SDK.tar.xz ] || wget $URL/$SDK.tar.xz || exit
rm -fr p/
mkdir p/
cd p/
tar -Jxf ../$IMG.tar.xz
tar -Jxf ../$SDK.tar.xz
cd $SDK/
ctangle ~/0000-git/openwrt/print.w
STAGING_DIR=~/lede/p/$SDK/staging_dir/toolchain* ./staging_dir/toolchain*/bin/mipsel-openwrt-linux-gcc print.c -o print
cd ../$IMG/
mkdir -p files/etc/uci-defaults/
cat <<'EOF' >files/etc/uci-defaults/my
uci set wireless.radio0.disabled=0
uci set wireless.radio0.txpower=2
uci set wireless.default_radio0.mode=sta
uci set wireless.default_radio0.ssid=MY_LINK2
uci set wireless.default_radio0.encryption=psk2
uci set wireless.default_radio0.key=mirumirmirumirmir
uci commit wireless
uci del network.lan.ifname
uci del network.lan.type
uci set network.lan.ipaddr=192.168.1.8
uci set network.lan.gateway=192.168.1.1
uci set network.lan.dns=192.168.1.1
uci commit network
uci set dhcp.lan.ignore=1
uci commit dhcp
uci set system.@system[0].timezone=GMT-7
uci commit system
EOF

mkdir -p files/bin/
cp ../$SDK/print files/bin/

make image PROFILE=wt1520-8M PACKAGES="kmod-usb-ohci kmod-usb-printer" FILES=files/
# Packages: <empty>
{ RET=$?; } 2>/dev/null
{ set +x; } 2>/dev/null
if [ $RET = 0 ]; then
  echo
  echo 'fw ~/lede/p/*imagebuilder*/bin/*/*/*/*-sysupgrade.bin p'
fi

# If you brick NEXX WT1520, flash via bootloader: use sysupgrade image, disconnect TX, power on, after 3 secs press "2", connect TX {FOOTNOTE}, press "y", follow instructions.
# FOOTNOTE: on NEXX WT1520 (sometimes?) RAM is detected incorrectly when TX is connected from router to usb2ttl adapter; the cure is not to connect the adapter first couple of seconds after poweron
