The script migrates the currently used packages from buildroot-2011.x to buildroot-2025.02.x.

- AstLinux is currently using buildroot-2011.x
- Buildroot is currently using buildroot-2025.02.x as part of LTS
- The idea is to keep AstLinux scripts as-is to the most part as of now so it would help with merging changes easy
- The script helps to migrate AstLinux scripts into Buildroot so it can be maintained in line with Buildroot
  This helps to reduce the bottlenecks in future however the Make Shift process of migrating AstLinux scripts
  to each new buildroot release is a tedious effort
- update ASTVER and BUILDROOTVER in the script whenever an updated check has to be done.
- downloads the corresponding tar.gz files if they do not exist in the folder
- picks only packages that are documented as currently being used in astlinux from astlinux (~150 packages)
- creates two folders m-buildroot-orig-ASTVER-BUILDROOTVER and m-buildroot-merge-ASTVER-BUILDROOTVER
- m-buildroot-orig contains packages that are mostly not changed with fixes and original with only merged scripts
  except for below which has to be added only to astlinux package scripts:
  - packages are renamed if there is any package that was renamed
  - add _CUSTOM_PATCH_DIR to each package
  - change PATH for custom files from package/<pkg-name> to package/<pkg-name>/astlinux
- m-buildroot-merge contains all the packages from buildroot + packages from astlinux with merged scripts with below changes:
  - generic package fixes for the migration (fixes are near end of process function)
  - package level bug fixes
  - some packages are explicitly disabled if there if major change for example libopenssl and tools that are used in toolchain
    - autoconf, automake, bison, libtool, m4
- comparing m-buildroot-orig and m-buildroot-merge shows what are the changes done as fixes to the original (mostly) package scripts
- comparing m-buildroot-merge with buildroot folder shows what are the changes that needs to be merged or to be added as fixes to the
  automated migration script
- when comparing please check if there are any new files in the packages periodically that needs to be merged or removed.

below is the list of packages identified that needs to be migrated from buildroot-2011.x to buildroot-2025.02.x

runnix
syslinux

linux

acme
acpid
arp-scan
asterisk
asterisk-codec-silk
asterisk-fop2
autoconf
automake
avahi
bash
bc
bfdetect
bison
bridge-utils
busybox
ca-certificates
chrony
clix
darkstat
ddclient
dhcpdump
dialog
dnscrypt-proxy
dnsmasq
dosfstools
dropbear
e2fsprogs
empty
ethtool
ex-vi
expat
fakeroot
flex
fossil
fping
fxload
genext2fs
gntp-send
gnu-efi
gperf
htop
iftop
iksemel
iperf
iprange
iproute2
ipset
iptables
jansson
jitterentropy-rngd
jpeg
keepalived
kexec
kmod
libcap
libcurl
libdaemon
libedit
libfuse
libical
libidn
libmnl
libpcap
libpng
libqrencode
libretls
libsodium
libsrtp
libtool
liburiparser
libusb
libusb-compat
libxcrypt
libxml2
lighttpd
linux-firmware
lm-sensors
logrotate
lua
luabitop
luaexpat
luafilesystem
luasec
luasocket
lxc
lzo
m4
mac2vendor
miniupnpd
monit
msmtp
mtr
multimedia/beep
multimedia/libmad
multimedia/sox
nano
nasm
ncurses
ne
neon
netcalc
netsnmp
ngrep
nut
openldap
openssh
openssl
openvpn
p910nd
pciutils
pcre
pcre2
perl
php
pkg-config
popt
pppd
prosody
r8125
rsync
s3fs
screen
shellinabox
sipgrep
sipsak
smartmontools
sngrep
spandsp
sqlite
sqliteodbc
squashfs
statserial
strace
strongswan
stunnel
sudo
tarsnap
tcpdump
tiff
tinyproxy
udev
unbound
unionfs
unixodbc
usbutils
util-linux
vnstat
vsftpd
whois
wide-dhcpv6
wireguard-tools
zabbix
zlib
zoneinfo
