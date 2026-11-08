################################################################################
#
# netcalc
#
################################################################################

NETCALC_VERSION = 2.1.7
NETCALC_SOURCE = netcalc-$(NETCALC_VERSION).tar.gz
NETCALC_SITE = https://github.com/troglobit/netcalc/releases/download/v$(NETCALC_VERSION)
NETCALC_CUSTOM_PATCH_DIR = astlinux

NETCALC_CONF_OPTS = \
	--disable-ipcalc-symlink

$(eval $(autotools-package))
