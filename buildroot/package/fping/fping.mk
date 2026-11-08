################################################################################
#
# fping
#
################################################################################

ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)
include package/fping/astlinux/fping.mk
endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

FPING_VERSION = 5.2
FPING_SITE = http://fping.org/dist
FPING_LICENSE = BSD-like
FPING_LICENSE_FILES = COPYING
FPING_SELINUX_MODULES = netutils

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
