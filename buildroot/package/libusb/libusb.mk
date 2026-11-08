ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

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

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# libusb
#
################################################################################

LIBUSB_VERSION_MAJOR = 1.0
LIBUSB_VERSION = $(LIBUSB_VERSION_MAJOR).30
LIBUSB_SOURCE = libusb-$(LIBUSB_VERSION).tar.bz2
LIBUSB_SITE = https://github.com/libusb/libusb/releases/download/v$(LIBUSB_VERSION)
LIBUSB_LICENSE = LGPL-2.1+
LIBUSB_LICENSE_FILES = COPYING
LIBUSB_CPE_ID_VENDOR = libusb
LIBUSB_DEPENDENCIES = host-pkgconf
LIBUSB_INSTALL_STAGING = YES

# Avoid the discovery of udev for the host variant
HOST_LIBUSB_CONF_OPTS = --disable-udev
HOST_LIBUSB_DEPENDENCIES = host-pkgconf

ifeq ($(BR2_PACKAGE_HAS_UDEV),y)
LIBUSB_DEPENDENCIES += udev
else
LIBUSB_CONF_OPTS += --disable-udev
endif

ifeq ($(BR2_PACKAGE_LIBUSB_EXAMPLES),y)
LIBUSB_CONF_OPTS += --enable-examples-build
define LIBUSB_INSTALL_TARGET_EXAMPLES
	$(foreach example,listdevs xusb fxload hotplugtest testlibusb dpfp dpfp_threaded sam3u_benchmark,
		$(INSTALL) -D -m0755 $(@D)/examples/$(example) $(TARGET_DIR)/usr/bin/$(example)
	)
endef
LIBUSB_POST_INSTALL_TARGET_HOOKS += LIBUSB_INSTALL_TARGET_EXAMPLES
endif

$(eval $(autotools-package))
$(eval $(host-autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
