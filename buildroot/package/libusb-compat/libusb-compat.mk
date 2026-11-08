ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# libusb-compat
#
#############################################################

LIBUSB_COMPAT_VERSION = 0.1.9
LIBUSB_COMPAT_SOURCE = libusb-compat-$(LIBUSB_COMPAT_VERSION).tar.bz2
LIBUSB_COMPAT_SITE = https://github.com/libusb/libusb-compat-0.1/releases/download/v$(LIBUSB_COMPAT_VERSION)
LIBUSB_COMPAT_CUSTOM_PATCH_DIR = astlinux
LIBUSB_COMPAT_DEPENDENCIES = host-pkgconf libusb
LIBUSB_COMPAT_INSTALL_STAGING = YES

LIBUSB_COMPAT_AUTORECONF = YES

define LIBUSB_COMPAT_FIXUP_CONFIG
	$(SED) 's%prefix=/usr%prefix=$(STAGING_DIR)/usr%' \
	    -e 's%exec_prefix=/usr%exec_prefix=$(STAGING_DIR)/usr%' \
		$(STAGING_DIR)/usr/bin/libusb-config
endef

LIBUSB_COMPAT_POST_INSTALL_STAGING_HOOKS+=LIBUSB_COMPAT_FIXUP_CONFIG

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# libusb-compat
#
################################################################################

LIBUSB_COMPAT_VERSION_MAJOR = 0.1
LIBUSB_COMPAT_VERSION = $(LIBUSB_COMPAT_VERSION_MAJOR).8
LIBUSB_COMPAT_SITE = https://github.com/libusb/libusb-compat-0.1/releases/download/v$(LIBUSB_COMPAT_VERSION)
LIBUSB_COMPAT_DEPENDENCIES = host-pkgconf libusb
HOST_LIBUSB_COMPAT_DEPENDENCIES = host-pkgconf host-libusb
LIBUSB_COMPAT_INSTALL_STAGING = YES
LIBUSB_COMPAT_CONFIG_SCRIPTS = libusb-config
LIBUSB_COMPAT_LICENSE = LGPL-2.1+
LIBUSB_COMPAT_LICENSE_FILES = COPYING

ifeq ($(BR2_STATIC_LIBS),)
LIBUSB_COMPAT_CONF_ENV += \
	LIBUSB_1_0_SONAME=`LC_ALL=C readelf -d $(STAGING_DIR)/usr/lib/libusb-1.0.so \
			   |sed -r -e '/\(SONAME\)/!d; s/.*\[(.+)\]$$/\1/'`
endif

$(eval $(autotools-package))
$(eval $(host-autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
