################################################################################
#
# libqrencode
#
################################################################################

LIBQRENCODE_VERSION = 4.1.1
LIBQRENCODE_SOURCE = qrencode-$(LIBQRENCODE_VERSION).tar.gz
LIBQRENCODE_SITE = https://github.com/fukuchi/libqrencode/archive/v$(LIBQRENCODE_VERSION)
LIBQRENCODE_CUSTOM_PATCH_DIR = astlinux
LIBQRENCODE_DEPENDENCIES = host-pkgconf
LIBQRENCODE_AUTORECONF = YES
LIBQRENCODE_INSTALL_STAGING = YES

ifeq ($(BR2_TOOLCHAIN_HAS_THREADS),y)
LIBQRENCODE_CONF_ENV += LIBS='-pthread'
else
LIBQRENCODE_CONF_OPTS += --disable-thread-safety
endif

ifeq ($(BR2_PACKAGE_LIBPNG),y)
LIBQRENCODE_CONF_OPTS += --with-png
LIBQRENCODE_DEPENDENCIES += libpng
else
LIBQRENCODE_CONF_OPTS += --without-png
endif

ifeq ($(BR2_PACKAGE_LIBQRENCODE_TOOLS),y)
LIBQRENCODE_CONF_OPTS += --with-tools=yes
else
LIBQRENCODE_CONF_OPTS += --with-tools=no
endif

$(eval $(autotools-package))
