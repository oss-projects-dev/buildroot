ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# bc
#
#############################################################

BC_VERSION = 1.08.2
BC_SOURCE = bc-$(BC_VERSION).tar.gz
BC_SITE = $(BR2_GNU_MIRROR)/bc
BC_CUSTOM_PATCH_DIR = astlinux/$(BC_VERSION)
BC_DEPENDENCIES = host-bison host-flex

ifeq ($(BR2_PACKAGE_LIBEDIT),y)
BC_DEPENDENCIES += libedit
BC_CONF_OPTS += --with-libedit
endif

define BC_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/bc/bc $(TARGET_DIR)/usr/bin/bc
endef

define BC_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/bc
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# bc
#
################################################################################

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
