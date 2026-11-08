################################################################################
#
# vnstat
#
################################################################################

ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)
include package/vnstat/astlinux/vnstat.mk
endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

VNSTAT_VERSION = 2.11
VNSTAT_SITE = http://humdi.net/vnstat
VNSTAT_LICENSE = GPL-2.0
VNSTAT_LICENSE_FILES = COPYING
VNSTAT_SELINUX_MODULES = vnstatd
VNSTAT_DEPENDENCIES = host-pkgconf sqlite
VNSTAT_CONF_OPTS = --disable-extra-paths

ifeq ($(BR2_PACKAGE_GD)$(BR2_PACKAGE_LIBPNG),yy)
VNSTAT_DEPENDENCIES += gd
VNSTAT_CONF_OPTS += --enable-image-output
else
VNSTAT_CONF_OPTS += --disable-image-output
endif

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
