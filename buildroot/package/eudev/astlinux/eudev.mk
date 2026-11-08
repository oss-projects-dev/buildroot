#############################################################
#
# udev (eudev)
#
#############################################################

EUDEV_VERSION = 3.2.14
EUDEV_SOURCE = eudev-$(EUDEV_VERSION).tar.gz
EUDEV_SITE = https://github.com/eudev-project/eudev/releases/download/v$(EUDEV_VERSION)
EUDEV_CUSTOM_PATCH_DIR = astlinux
EUDEV_INSTALL_STAGING = YES

EUDEV_CONF_OPTS = \
	--disable-manpages \
	--sbindir=/sbin \
	--with-rootrundir=/var/run \
	--disable-selinux \
	--disable-introspection \
	--disable-hwdb \
	--enable-rule-generator \
	--enable-kmod \
	--enable-blkid

EUDEV_DEPENDENCIES = host-gperf host-pkgconf util-linux kmod

define EUDEV_INSTALL_USBTTY
	$(INSTALL) -m 0644 -D package/udev/usbtty/usbtty.rules $(TARGET_DIR)/etc/udev/rules.d/usbtty.rules
	$(INSTALL) -m 0755 -D package/udev/usbtty/usb-getty $(TARGET_DIR)/usr/share/usbtty/usb-getty
	$(INSTALL) -m 0755 -D package/udev/usbtty/usb-getty-background $(TARGET_DIR)/usr/share/usbtty/usb-getty-background
endef
EUDEV_POST_INSTALL_TARGET_HOOKS += EUDEV_INSTALL_USBTTY

$(eval $(autotools-package))
