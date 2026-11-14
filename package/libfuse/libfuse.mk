ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

################################################################################
#
# libfuse
#
################################################################################

LIBFUSE_VERSION = 2.9.9
LIBFUSE_SOURCE = fuse-$(LIBFUSE_VERSION).tar.gz
LIBFUSE_SITE = https://github.com/libfuse/libfuse/releases/download/fuse-$(LIBFUSE_VERSION)
LIBFUSE_CUSTOM_PATCH_DIR = astlinux
LIBFUSE_INSTALL_STAGING = YES
LIBFUSE_DEPENDENCIES = $(if $(BR2_PACKAGE_LIBICONV),libiconv)
LIBFUSE_CONF_OPTS = \
	--disable-example \
	--enable-lib \
	--disable-util \
	UDEV_RULES_PATH=/usr/lib/udev/rules.d

define LIBFUSE_INSTALL_TARGET_CMDS
	cp -dpf $(STAGING_DIR)/usr/lib/libfuse.so* $(TARGET_DIR)/usr/lib/
endef

define LIBFUSE_CLEAN_CMDS
	## Ignore clean
endef

define LIBFUSE_UNINSTALL_STAGING_CMDS
	## Ignore uninstall staging
endef

define LIBFUSE_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/lib/libfuse.so*
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# libfuse
#
################################################################################

LIBFUSE_VERSION = 2.9.9
LIBFUSE_SOURCE = fuse-$(LIBFUSE_VERSION).tar.gz
LIBFUSE_SITE = https://github.com/libfuse/libfuse/releases/download/fuse-$(LIBFUSE_VERSION)
LIBFUSE_LICENSE = GPL-2.0, LGPL-2.1
LIBFUSE_LICENSE_FILES = COPYING COPYING.LIB
LIBFUSE_CPE_ID_VALID = YES
LIBFUSE_INSTALL_STAGING = YES
# We're patching configure.ac
LIBFUSE_AUTORECONF = YES
# add host-gettext for AM_ICONV macro
LIBFUSE_DEPENDENCIES = \
	host-gettext \
	$(if $(BR2_PACKAGE_LIBICONV),libiconv)
LIBFUSE_CONF_OPTS = \
	--disable-example \
	--enable-lib \
	--enable-util \
	UDEV_RULES_PATH=/lib/udev/rules.d

ifeq ($(BR2_PACKAGE_HAS_UDEV),y)
define LIBFUSE_INSTALL_UDEV
	mkdir -p $(TARGET_DIR)/lib/udev/rules.d
	cp $(STAGING_DIR)/lib/udev/rules.d/*-fuse.rules $(TARGET_DIR)/lib/udev/rules.d
endef

LIBFUSE_POST_INSTALL_TARGET_HOOKS += LIBFUSE_INSTALL_UDEV
endif

define LIBFUSE_INSTALL_TARGET_CMDS
	cp -dpf $(STAGING_DIR)/usr/bin/fusermount $(TARGET_DIR)/usr/bin/
	cp -dpf $(STAGING_DIR)/usr/lib/libfuse.so* $(TARGET_DIR)/usr/lib/
endef

define LIBFUSE_DEVICES
	/dev/fuse c 666 0 0 10 229 0 0 -
endef

define LIBFUSE_PERMISSIONS
	/usr/bin/fusermount f 4755 0 0 - - - - -
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
