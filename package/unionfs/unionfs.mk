ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

################################################################################
#
# unionfs (fuse)
#
################################################################################

UNIONFS_VERSION = 3.7
UNIONFS_SOURCE = unionfs-fuse-$(UNIONFS_VERSION).tar.gz
UNIONFS_SITE = https://github.com/rpodgorny/unionfs-fuse/archive/v$(UNIONFS_VERSION)
UNIONFS_CUSTOM_PATCH_DIR = astlinux

UNIONFS_DEPENDENCIES = host-pkgconf libfuse

define UNIONFS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) \
		CC="$(TARGET_CC)" \
		AR="$(TARGET_AR)" \
		CFLAGS="$(TARGET_CFLAGS) -Wall -fPIC" \
	-C $(@D)/src
endef

define UNIONFS_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/src/unionfs $(TARGET_DIR)/usr/bin/unionfs
	$(INSTALL) -m 0755 -D $(@D)/src/unionfsctl $(TARGET_DIR)/usr/bin/unionfsctl
endef

define UNIONFS_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/unionfs
	rm -f $(TARGET_DIR)/usr/bin/unionfsctl
endef

$(eval $(generic-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# unionfs
#
################################################################################

UNIONFS_VERSION = 2.1
UNIONFS_SITE = $(call github,rpodgorny,unionfs-fuse,v$(UNIONFS_VERSION))
UNIONFS_DEPENDENCIES = libfuse host-pkgconf
UNIONFS_LICENSE = BSD-3-Clause
UNIONFS_LICENSE_FILES = LICENSE

$(eval $(cmake-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
