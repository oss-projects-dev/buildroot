################################################################################
#
# bc
#
################################################################################

ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)
include package/bc/astlinux/bc.mk
endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

BC_VERSION = 1.07.1
BC_SITE = $(BR2_GNU_MIRROR)/bc
BC_DEPENDENCIES = host-flex
BC_LICENSE = GPL-2.0+, LGPL-2.1+
BC_LICENSE_FILES = COPYING COPYING.LIB
BC_CPE_ID_VENDOR = gnu
BC_CONF_ENV = MAKEINFO=true

# 0001-bc-use-MAKEINFO-variable-for-docs.patch and 0004-no-gen-libmath.patch
# are patching doc/Makefile.am and Makefile.am respectively
BC_AUTORECONF = YES

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
