ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# kexec
#
#############################################################

KEXEC_VERSION = 2.0.30
KEXEC_SOURCE = kexec-tools-$(KEXEC_VERSION).tar.xz
KEXEC_SITE = $(BR2_KERNEL_MIRROR)/linux/utils/kernel/kexec
KEXEC_CUSTOM_PATCH_DIR = astlinux

ifeq ($(BR2_PACKAGE_KEXEC_ZLIB),y)
KEXEC_CONF_OPTS += --with-zlib
KEXEC_DEPENDENCIES = zlib
else
KEXEC_CONF_OPTS += --without-zlib
endif

ifeq ($(BR2_PACKAGE_XZ),y)
KEXEC_CONF_OPTS += --with-lzma
KEXEC_DEPENDENCIES += xz
else
KEXEC_CONF_OPTS += --without-lzma
endif

# Only install kexec
define KEXEC_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/build/sbin/kexec $(TARGET_DIR)/sbin/kexec
endef

KEXEC_UNINSTALL_STAGING_OPTS = --version

define KEXEC_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/sbin/kexec
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# kexec
#
################################################################################

KEXEC_VERSION = 2.0.30
KEXEC_SOURCE = kexec-tools-$(KEXEC_VERSION).tar.xz
KEXEC_SITE = $(BR2_KERNEL_MIRROR)/linux/utils/kernel/kexec
KEXEC_LICENSE = GPL-2.0
KEXEC_LICENSE_FILES = COPYING
KEXEC_CPE_ID_PRODUCT = kexec-tools
KEXEC_CPE_ID_VENDOR = kexec-tools_project
KEXEC_SELINUX_MODULES = kdump

# Makefile expects $STRIP -o to work, so needed for !BR2_STRIP_strip
KEXEC_MAKE_OPTS = STRIP="$(TARGET_CROSS)strip"

# kexec requires at least -O1 optimization level. Its code uses a
# trick to detect unaligned accesses at link time which needs at least
# dead-code-removal to work. See put/get_unaligned() macros in
# kexec/kexec.h
ifeq ($(BR2_OPTIMIZE_0),y)
KEXEC_CONF_ENV += CFLAGS="$(TARGET_CFLAGS) -O1"
endif

ifeq ($(BR2_PACKAGE_KEXEC_ZLIB),y)
KEXEC_CONF_OPTS += --with-zlib
KEXEC_DEPENDENCIES += zlib
else
KEXEC_CONF_OPTS += --without-zlib
endif

ifeq ($(BR2_PACKAGE_XZ),y)
KEXEC_CONF_OPTS += --with-lzma
KEXEC_DEPENDENCIES += xz
else
KEXEC_CONF_OPTS += --without-lzma
endif

define KEXEC_REMOVE_LIB_TOOLS
	rm -rf $(TARGET_DIR)/usr/lib/kexec-tools
endef

KEXEC_POST_INSTALL_TARGET_HOOKS += KEXEC_REMOVE_LIB_TOOLS

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
