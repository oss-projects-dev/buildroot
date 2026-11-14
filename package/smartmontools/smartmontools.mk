ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# smartmontools
#
#############################################################

SMARTMONTOOLS_VERSION = 7.5
SMARTMONTOOLS_SITE = https://downloads.sourceforge.net/project/smartmontools/smartmontools/$(SMARTMONTOOLS_VERSION)
SMARTMONTOOLS_CUSTOM_PATCH_DIR = astlinux

define SMARTMONTOOLS_LATEST_DRIVEDB
	# Upstream Drive DB:
	# curl -o package/smartmontools/astlinux/drivedb.h 'https://sourceforge.net/p/smartmontools/code/HEAD/tree/trunk/smartmontools/drivedb.h?format=raw'
	# Install local snapshot
	cp package/smartmontools/astlinux/drivedb.h $(@D)/drivedb.h
endef
SMARTMONTOOLS_POST_EXTRACT_HOOKS += SMARTMONTOOLS_LATEST_DRIVEDB

SMARTMONTOOLS_CONF_OPTS = \
	--without-gnupg \
	--without-libcap-ng

define SMARTMONTOOLS_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/smartctl $(TARGET_DIR)/usr/sbin/smartctl
	$(INSTALL) -m 0755 -D package/smartmontools/astlinux/smart-status.sh $(TARGET_DIR)/usr/sbin/smart-status
	ln -sf /tmp/etc/smart_drivedb.h $(TARGET_DIR)/etc/smart_drivedb.h
endef

define SMARTMONTOOLS_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/sbin/smartctl
	rm -f $(TARGET_DIR)/usr/sbin/smart-status
	rm -f $(TARGET_DIR)/etc/smart_drivedb.h
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# smartmontools
#
################################################################################

SMARTMONTOOLS_VERSION = 7.4
SMARTMONTOOLS_SITE = http://downloads.sourceforge.net/project/smartmontools/smartmontools/$(SMARTMONTOOLS_VERSION)
SMARTMONTOOLS_LICENSE = GPL-2.0+
SMARTMONTOOLS_LICENSE_FILES = COPYING
SMARTMONTOOLS_CPE_ID_VENDOR = smartmontools
SMARTMONTOOLS_SELINUX_MODULES = smartmon

ifeq ($(BR2_PACKAGE_LIBCAP_NG),y)
SMARTMONTOOLS_CONF_OPTS += --with-libcap-ng
SMARTMONTOOLS_DEPENDENCIES += libcap-ng
else
SMARTMONTOOLS_CONF_OPTS += --without-libcap-ng
endif

ifeq ($(BR2_PACKAGE_LIBSELINUX),y)
SMARTMONTOOLS_CONF_OPTS += --with-selinux
SMARTMONTOOLS_DEPENDENCIES += libselinux
else
SMARTMONTOOLS_CONF_OPTS += --without-selinux
endif

ifeq ($(BR2_PACKAGE_SYSTEMD),y)
SMARTMONTOOLS_CONF_OPTS += --with-libsystemd
SMARTMONTOOLS_DEPENDENCIES += systemd
else
SMARTMONTOOLS_CONF_OPTS += --without-libsystemd
endif

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
