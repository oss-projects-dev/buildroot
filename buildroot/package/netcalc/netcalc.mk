################################################################################
#
# netcalc
#
################################################################################

ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

include package/netcalc/astlinux/netcalc.mk

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

NETCALC_VERSION = 2.1.7
NETCALC_SITE = https://github.com/troglobit/netcalc/releases/download/v$(NETCALC_VERSION)
NETCALC_LICENSE = BSD-3-Clause
NETCALC_LICENSE_FILES = LICENSE
NETCALC_CONF_OPTS = --disable-ipcalc-symlink

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
