ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# libsodium
#
#############################################################

LIBSODIUM_VERSION = 1.0.22
LIBSODIUM_SOURCE = libsodium-$(LIBSODIUM_VERSION).tar.gz
LIBSODIUM_SITE = https://github.com/jedisct1/libsodium/releases/download/$(LIBSODIUM_VERSION)-RELEASE
LIBSODIUM_CUSTOM_PATCH_DIR = astlinux

LIBSODIUM_INSTALL_STAGING = YES

LIBSODIUM_CONF_ENV = \
	ax_cv_check_cCATCHABLE_SEGV=yes \
	ax_cv_check_cCATCHABLE_ABRT=yes

LIBSODIUM_CONF_OPTS = \
	--enable-minimal

define LIBSODIUM_INSTALL_TARGET_CMDS
	cp -a $(STAGING_DIR)/usr/lib/libsodium.so* $(TARGET_DIR)/usr/lib/
endef

define LIBSODIUM_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/lib/libsodium.so*
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# libsodium
#
################################################################################

LIBSODIUM_VERSION = 1.0.22
LIBSODIUM_SITE = https://download.libsodium.org/libsodium/releases
LIBSODIUM_SOURCE = libsodium-$(LIBSODIUM_VERSION).tar.bz2
LIBSODIUM_LICENSE = ISC
LIBSODIUM_LICENSE_FILES = LICENSE
LIBSODIUM_INSTALL_STAGING = YES

ifeq ($(BR2_TOOLCHAIN_SUPPORTS_PIE),)
LIBSODIUM_CONF_OPTS += --disable-pie
endif

ifeq ($(BR2_PACKAGE_LIBSODIUM_FULL),y)
LIBSODIUM_CONF_OPTS += --disable-minimal
else
LIBSODIUM_CONF_OPTS += --enable-minimal
endif

$(eval $(autotools-package))
$(eval $(host-autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
