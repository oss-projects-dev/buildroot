################################################################################
#
# kmod
#
################################################################################

KMOD_VERSION = 34.3
KMOD_SOURCE = kmod-$(KMOD_VERSION).tar.xz
KMOD_SITE = $(BR2_KERNEL_MIRROR)/linux/utils/kernel/kmod
KMOD_CUSTOM_PATCH_DIR = astlinux
KMOD_INSTALL_STAGING = YES
KMOD_DEPENDENCIES = host-pkgconf
HOST_KMOD_DEPENDENCIES = host-pkgconf

KMOD_CONF_OPTS = \
	--disable-static \
	--enable-shared \
	--without-zstd \
	--without-openssl

KMOD_CONF_OPTS += --disable-manpages
HOST_KMOD_CONF_OPTS = --disable-manpages

ifeq ($(BR2_PACKAGE_ZLIB),y)
KMOD_DEPENDENCIES += zlib
KMOD_CONF_OPTS += --with-zlib
else
KMOD_CONF_OPTS += --without-zlib
endif

ifeq ($(BR2_PACKAGE_XZ),y)
KMOD_DEPENDENCIES += xz
KMOD_CONF_OPTS += --with-xz
else
KMOD_CONF_OPTS += --without-xz
endif

ifeq ($(BR2_PACKAGE_KMOD_TOOLS),y)

define KMOD_INSTALL_TOOLS
	for i in depmod insmod lsmod modinfo modprobe rmmod; do \
		ln -sf ../usr/bin/kmod $(TARGET_DIR)/sbin/$$i; \
	done
endef

KMOD_POST_INSTALL_TARGET_HOOKS += KMOD_INSTALL_TOOLS
else
KMOD_CONF_OPTS += --disable-tools
endif

# We only install depmod, since that's the only tool used for the
# host.
define HOST_KMOD_INSTALL_TOOLS
	mkdir -p $(HOST_DIR)/sbin/
	ln -sf ../bin/kmod $(HOST_DIR)/sbin/depmod
endef

HOST_KMOD_POST_INSTALL_HOOKS += HOST_KMOD_INSTALL_TOOLS

$(eval $(autotools-package))
$(eval $(host-autotools-package))
