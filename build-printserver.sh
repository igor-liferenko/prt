#!/bin/bash -x

if [ `whereami` = notebook ]; then
  { echo superbuild is not done on notebook, so this script must not be run on notebook; } 2>/dev/null
  exit
fi
if [ `whereami` != home ]; then
  { echo this is used only on notebook, and superbuild for notebook is done at home; } 2>/dev/null
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
rm -r /www
ln -s /mnt /www
rm -fr /etc/asterisk/*
EOF
mkdir -p files/bin/
ln -s /mnt/lfk/lfk files/bin/lfk
ln -s /mnt/prt files/bin/prt
mkdir -p files/etc/
cat <<'EOF' >files/etc/rc.local
mount /dev/sda1 /mnt
lfk &
prt &
exit 0
EOF
cat <<'EOF' >files/bin/pkill
#!/bin/sh
kill `pgrep "$@"`
EOF
chmod +x files/bin/pkill
make image PROFILE=tl-wr1043nd-v1 PACKAGES="uhttpd kmod-usb-storage kmod-fs-ext4 kmod-lib-crc32c kmod-usb-printer lsof netcat strace asterisk13 asterisk13-chan-iax2" FILES=files/
rm -f /usr/local/SUPER_DEBIAN/printserver-sdk.tar.xz
cp ../../$SDK.tar.xz /usr/local/SUPER_DEBIAN/printserver-sdk.tar.xz
rm -f /usr/local/SUPER_DEBIAN/printserver-sysupgrade.img
cp bin/targets/ar71xx/generic/lede-17.01.4-ar71xx-generic-tl-wr1043nd-v1-squashfs-sysupgrade.bin /usr/local/SUPER_DEBIAN/printserver-sysupgrade.img
