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
