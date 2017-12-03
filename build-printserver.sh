#!/bin/bash -x

if [ `whereami` = notebook ]; then
  echo superbuild is not done on notebook, so this script must not be run on notebook
  exit
fi
if [ `whereami` != home ]; then
  echo this is used only on notebook, and superbuild for notebook is done at home
  exit
fi

IMG=lede-imagebuilder-17.01.4-ramips-rt305x.Linux-x86_64
SDK=lede-sdk-17.01.4-ramips-rt305x_gcc-5.4.0_musl-1.1.16.Linux-x86_64
mkdir -p ~/lede
cd ~/lede
[ -e $IMG.tar.xz ] || wget https://downloads.lede-project.org/releases/17.01.4/targets/ramips/rt305x/$IMG.tar.xz || exit
[ -e $SDK.tar.xz ] || wget https://downloads.lede-project.org/releases/17.01.4/targets/ramips/rt305x/$SDK.tar.xz || exit
rm -fr printserver/
mkdir printserver/
cd printserver/
tar -Jxf ../$IMG.tar.xz
cd $IMG/
mkdir -p files/etc/uci-defaults/
cat << EOF > files/etc/uci-defaults/my
uci set wireless.radio0.disabled=0
uci set wireless.radio0.txpower=2
uci set wireless.default_radio0.mode=sta
uci set wireless.default_radio0.ssid=MY_LINK2
uci set wireless.default_radio0.encryption=psk2
uci set wireless.default_radio0.key=mirumirmirumirmir
uci commit wireless
uci del network.lan.ifname
uci del network.lan.type
uci set network.lan.ipaddr=192.168.1.3
uci set network.lan.gateway=192.168.1.1
uci set network.lan.dns=192.168.1.1
uci commit network
uci set dhcp.lan.ignore=1
uci commit dhcp
uci set system.@system[0].timezone=GMT-7
uci commit system
EOF
mkdir -p files/bin/
ln -s /mnt/prt files/bin/prt
mkdir -p files/etc/
cat <<'EOF' >files/etc/rc.local
cat <<'FOE' | sh &
while ! mount|grep -q ^192.168.1.8; do
  mount -t nfs -o nolock 192.168.1.8:/mnt/ /mnt/
done
prt &
FOE
exit 0
EOF
cat <<'EOF' >files/bin/pkill
#!/bin/sh
kill `pgrep "$@"`
EOF
chmod +x files/bin/pkill
make image PROFILE=wt1520-8M PACKAGES="lsof netcat strace kmod-usb-printer kmod-fs-nfs nfs-utils" FILES=files/ # NOTE: if printer will not work, install kmod-usb2 (see via git lg if it was used for 1043nd and if not - mark here that it is required specifically for this device)
rm -f /usr/local/SUPER_DEBIAN/printserver-sdk.tar.xz
cp ../../$SDK.tar.xz /usr/local/SUPER_DEBIAN/printserver-sdk.tar.xz
rm -f /usr/local/SUPER_DEBIAN/printserver-sysupgrade.img
cp bin/targets/ramips/rt305x/lede-17.01.4-ramips-rt305x-wt1520-8M-squashfs-sysupgrade.bin /usr/local/SUPER_DEBIAN/printserver-sysupgrade.img
