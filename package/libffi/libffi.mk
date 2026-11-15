ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# libffi
#
#############################################################

LIBFFI_VERSION = 3.2.1
LIBFFI_SITE = ftp://sourceware.org/pub/libffi
LIBFFI_CUSTOM_PATCH_DIR = astlinux

LIBFFI_INSTALL_STAGING = YES
LIBFFI_AUTORECONF = YES

# Move the headers to the usual location, and adjust the .pc file
# accordingly
define LIBFFI_MOVE_HEADERS
	mv $(1)/usr/lib/libffi-$(LIBFFI_VERSION)/include/*.h $(1)/usr/include/
	$(SED) '/^includedir.*/d' -e '/^Cflags:.*/d' \
		$(1)/usr/lib/pkgconfig/libffi.pc
	rm -rf $(1)/usr/lib/libffi-*
endef

LIBFFI_MOVE_STAGING_HEADERS = $(call LIBFFI_MOVE_HEADERS,$(STAGING_DIR))
LIBFFI_POST_INSTALL_STAGING_HOOKS += LIBFFI_MOVE_STAGING_HEADERS

HOST_LIBFFI_MOVE_HOST_HEADERS = $(call LIBFFI_MOVE_HEADERS,$(HOST_DIR))
HOST_LIBFFI_POST_INSTALL_HOOKS += HOST_LIBFFI_MOVE_HOST_HEADERS

# Remove headers that are not at the usual location from the target
define LIBFFI_REMOVE_TARGET_HEADERS
	rm -rf $(TARGET_DIR)/usr/lib/libffi-$(LIBFFI_VERSION)
endef

LIBFFI_POST_INSTALL_TARGET_HOOKS += LIBFFI_REMOVE_TARGET_HEADERS

$(eval $(autotools-package))
$(eval $(host-autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# libffi
#
################################################################################

LIBFFI_VERSION = 3.4.6
LIBFFI_SITE = \
	https://github.com/libffi/libffi/releases/download/v$(LIBFFI_VERSION)
LIBFFI_LICENSE = MIT
LIBFFI_LICENSE_FILES = LICENSE
LIBFFI_CPE_ID_VALID = YES
LIBFFI_INSTALL_STAGING = YES
# We're patching configure.ac
LIBFFI_AUTORECONF = YES
LIBFFI_CONF_OPTS = --disable-multi-os-directory

# The static exec trampolines is enabled by default since
# libffi 3.4.2. However it doesn't work with gobject-introspection.
LIBFFI_CONF_OPTS += --disable-exec-static-tramp

$(eval $(autotools-package))
$(eval $(host-autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
