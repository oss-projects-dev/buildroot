#############################################################
#
# libusb
#
#############################################################

LIBUSB_VERSION = 1.0.30
LIBUSB_SOURCE = libusb-$(LIBUSB_VERSION).tar.bz2
LIBUSB_SITE = https://github.com/libusb/libusb/releases/download/v$(LIBUSB_VERSION)
LIBUSB_CUSTOM_PATCH_DIR = astlinux
LIBUSB_DEPENDENCIES = host-pkgconf
LIBUSB_INSTALL_STAGING = YES

ifeq ($(BR2_ROOTFS_DEVICE_CREATION_DYNAMIC_UDEV),y)
LIBUSB_DEPENDENCIES += udev
else
LIBUSB_CONF_OPTS += --disable-udev
endif

$(eval $(autotools-package))
