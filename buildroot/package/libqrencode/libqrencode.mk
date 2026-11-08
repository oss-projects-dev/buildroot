ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

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

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# libqrencode
#
################################################################################

LIBQRENCODE_VERSION = 4.1.1
LIBQRENCODE_SITE = $(call github,fukuchi,libqrencode,v$(LIBQRENCODE_VERSION))
LIBQRENCODE_DEPENDENCIES = host-pkgconf
LIBQRENCODE_INSTALL_STAGING = YES
LIBQRENCODE_LICENSE = LGPL-2.1+
LIBQRENCODE_LICENSE_FILES = COPYING
LIBQRENCODE_AUTORECONF = YES

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

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
