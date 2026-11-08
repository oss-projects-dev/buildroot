################################################################################
#
# bridge-utils
#
################################################################################

ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)
include package/bridge-utils/astlinux/bridge-utils.mk
endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

BRIDGE_UTILS_VERSION = 1.7.1
BRIDGE_UTILS_SITE = $(BR2_KERNEL_MIRROR)/linux/utils/net/bridge-utils
BRIDGE_UTILS_SOURCE = bridge-utils-$(BRIDGE_UTILS_VERSION).tar.xz
BRIDGE_UTILS_AUTORECONF = YES
BRIDGE_UTILS_LICENSE = GPL-2.0+
BRIDGE_UTILS_LICENSE_FILES = COPYING
BRIDGE_UTILS_CPE_ID_VENDOR = kernel
BRIDGE_UTILS_SELINUX_MODULES = brctl

# Avoid using the host's headers. Location is not important as
# required headers will anyway be found from within the sysroot.
BRIDGE_UTILS_CONF_OPTS = --with-linux-headers=$(STAGING_DIR)/usr/include

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
