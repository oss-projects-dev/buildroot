ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# libpng
#
#############################################################

LIBPNG_VERSION = 1.6.59
LIBPNG_SERIES = 16
LIBPNG_SOURCE = libpng-$(LIBPNG_VERSION).tar.xz
LIBPNG_SITE = http://downloads.sourceforge.net/project/libpng/libpng$(LIBPNG_SERIES)/$(LIBPNG_VERSION)
LIBPNG_CUSTOM_PATCH_DIR = astlinux
LIBPNG_INSTALL_STAGING = YES
LIBPNG_DEPENDENCIES = host-pkgconf zlib

HOST_LIBPNG_DEPENDENCIES = host-pkgconf host-zlib

LIBPNG_CONF_OPTS = \
	--disable-tests \
	--disable-tools \
	--disable-hardware-optimizations

define LIBPNG_STAGING_LIBPNG_SERIES_CONFIG_FIXUP
	$(SED) "s,^prefix=.*,prefix=\'$(STAGING_DIR)/usr\',g" \
		-e "s,^exec_prefix=.*,exec_prefix=\'$(STAGING_DIR)/usr\',g" \
		-e "s,^includedir=.*,includedir=\'$(STAGING_DIR)/usr/include/libpng$(LIBPNG_SERIES)\',g" \
		-e "s,^libdir=.*,libdir=\'$(STAGING_DIR)/usr/lib\',g" \
		$(STAGING_DIR)/usr/bin/libpng$(LIBPNG_SERIES)-config
endef
LIBPNG_POST_INSTALL_STAGING_HOOKS += LIBPNG_STAGING_LIBPNG_SERIES_CONFIG_FIXUP

define LIBPNG_REMOVE_CONFIG_SCRIPTS
	$(RM) $(TARGET_DIR)/usr/bin/libpng$(LIBPNG_SERIES)-config \
		 $(TARGET_DIR)/usr/bin/libpng-config
endef
LIBPNG_POST_INSTALL_TARGET_HOOKS += LIBPNG_REMOVE_CONFIG_SCRIPTS

$(eval $(autotools-package))
$(eval $(host-autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# libpng
#
################################################################################

LIBPNG_VERSION = 1.6.59
LIBPNG_SERIES = 16
LIBPNG_SOURCE = libpng-$(LIBPNG_VERSION).tar.xz
LIBPNG_SITE = http://downloads.sourceforge.net/project/libpng/libpng$(LIBPNG_SERIES)/$(LIBPNG_VERSION)
LIBPNG_LICENSE = Libpng-2.0
LIBPNG_LICENSE_FILES = LICENSE
LIBPNG_CPE_ID_VENDOR = libpng
LIBPNG_INSTALL_STAGING = YES
LIBPNG_DEPENDENCIES = host-pkgconf zlib
HOST_LIBPNG_DEPENDENCIES = host-pkgconf host-zlib
LIBPNG_CONFIG_SCRIPTS = libpng$(LIBPNG_SERIES)-config libpng-config
LIBPNG_CONF_OPTS = --disable-tools
LIBPNG_CFLAGS = $(TARGET_CFLAGS)

ifeq ($(BR2_aarch64),y)
LIBPNG_CONF_OPTS += --enable-arm-neon
else ifeq ($(BR2_ARM_CPU_HAS_NEON):$(BR2_ARM_SOFT_FLOAT),y:)
LIBPNG_CFLAGS += -mfpu=neon
LIBPNG_CONF_OPTS += --enable-arm-neon
else
LIBPNG_CONF_OPTS += --disable-arm-neon
endif

ifeq ($(BR2_X86_CPU_HAS_SSE2),y)
LIBPNG_CONF_OPTS += --enable-intel-sse
else
LIBPNG_CONF_OPTS += --disable-intel-sse
endif

LIBPNG_CONF_ENV = \
	CFLAGS="$(LIBPNG_CFLAGS)"

$(eval $(autotools-package))
$(eval $(host-autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
