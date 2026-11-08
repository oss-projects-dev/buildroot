ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# vnstat
#
#############################################################

VNSTAT_VERSION = 2.14
VNSTAT_SITE = https://humdi.net/vnstat
VNSTAT_CUSTOM_PATCH_DIR = astlinux
VNSTAT_DEPENDENCIES = host-pkgconf sqlite
VNSTAT_CONF_OPTS = \
	--disable-extra-paths \
	--disable-image-output

define VNSTAT_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/vnstat $(TARGET_DIR)/usr/bin/vnstat
	$(INSTALL) -D -m 0755 $(@D)/vnstatd $(TARGET_DIR)/usr/sbin/vnstatd
	$(INSTALL) -D -m 0755 package/vnstat/astlinux/vnstat.init $(TARGET_DIR)/etc/init.d/vnstat
	ln -sf /tmp/etc/vnstat.conf $(TARGET_DIR)/etc/vnstat.conf
	ln -sf ../../init.d/vnstat $(TARGET_DIR)/etc/runlevels/default/S98vnstat
	ln -sf ../../init.d/vnstat $(TARGET_DIR)/etc/runlevels/default/K01vnstat
endef

define VNSTAT_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/vnstat
	rm -f $(TARGET_DIR)/usr/sbin/vnstatd
	rm -f $(TARGET_DIR)/etc/init.d/vnstat
	rm -f $(TARGET_DIR)/etc/vnstat.conf
	rm -f $(TARGET_DIR)/etc/runlevels/default/S98vnstat
	rm -f $(TARGET_DIR)/etc/runlevels/default/K01vnstat
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# vnstat
#
################################################################################

VNSTAT_VERSION = 2.11
VNSTAT_SITE = http://humdi.net/vnstat
VNSTAT_LICENSE = GPL-2.0
VNSTAT_LICENSE_FILES = COPYING
VNSTAT_SELINUX_MODULES = vnstatd
VNSTAT_DEPENDENCIES = host-pkgconf sqlite
VNSTAT_CONF_OPTS = --disable-extra-paths

ifeq ($(BR2_PACKAGE_GD)$(BR2_PACKAGE_LIBPNG),yy)
VNSTAT_DEPENDENCIES += gd
VNSTAT_CONF_OPTS += --enable-image-output
else
VNSTAT_CONF_OPTS += --disable-image-output
endif

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
