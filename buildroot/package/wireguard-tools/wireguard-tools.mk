ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

################################################################################
#
# wireguard-tools
#
################################################################################

WIREGUARD_TOOLS_VERSION = 1.0.20260223
WIREGUARD_TOOLS_SITE = https://git.zx2c4.com/wireguard-tools/snapshot
WIREGUARD_TOOLS_CUSTOM_PATCH_DIR = astlinux
WIREGUARD_TOOLS_SOURCE = wireguard-tools-$(WIREGUARD_TOOLS_VERSION).tar.xz
WIREGUARD_TOOLS_DEPENDENCIES = host-pkgconf

WIREGUARD_TOOLS_MAKE_OPTS = \
	CC=$(TARGET_CC) \
	LD=$(TARGET_LD) \
	WITH_BASHCOMPLETION=no \
	WITH_WGQUICK=no \
	WITH_SYSTEMDUNITS=no

define WIREGUARD_TOOLS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) $(WIREGUARD_TOOLS_MAKE_OPTS) \
		-C $(@D)/src wg
endef

define WIREGUARD_TOOLS_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/src/wg $(TARGET_DIR)/usr/bin/wg
	$(INSTALL) -m 0755 -D package/wireguard-tools/astlinux/wireguard-monitor $(TARGET_DIR)/usr/sbin/wireguard-monitor
	$(INSTALL) -m 0755 -D package/wireguard-tools/astlinux/wireguard-mobile-client $(TARGET_DIR)/usr/sbin/wireguard-mobile-client
	$(INSTALL) -m 0755 -D package/wireguard-tools/astlinux/wireguard.init $(TARGET_DIR)/etc/init.d/wireguard
	ln -sf /tmp/etc/wireguard $(TARGET_DIR)/etc/wireguard
	ln -sf ../../init.d/wireguard $(TARGET_DIR)/etc/runlevels/default/S31wireguard
	ln -sf ../../init.d/wireguard $(TARGET_DIR)/etc/runlevels/default/K20wireguard
endef

define WIREGUARD_TOOLS_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/wg
	rm -f $(TARGET_DIR)/usr/sbin/wireguard-monitor
	rm -f $(TARGET_DIR)/usr/sbin/wireguard-mobile-client
	rm -f $(TARGET_DIR)/etc/init.d/wireguard
	rm -f $(TARGET_DIR)/etc/wireguard
	rm -f $(TARGET_DIR)/etc/runlevels/default/S31wireguard
	rm -f $(TARGET_DIR)/etc/runlevels/default/K20wireguard
endef

$(eval $(generic-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# wireguard-tools
#
################################################################################

WIREGUARD_TOOLS_VERSION = 1.0.20210914
WIREGUARD_TOOLS_SITE = https://git.zx2c4.com/wireguard-tools/snapshot
WIREGUARD_TOOLS_SOURCE = wireguard-tools-$(WIREGUARD_TOOLS_VERSION).tar.xz
WIREGUARD_TOOLS_LICENSE = GPL-2.0
WIREGUARD_TOOLS_LICENSE_FILES = COPYING
WIREGUARD_TOOLS_SELINUX_MODULES = wireguard

ifeq ($(BR2_INIT_SYSTEMD),y)
WIREGUARD_TOOLS_MAKE_OPTS += WITH_SYSTEMDUNITS=yes
WIREGUARD_TOOLS_DEPENDENCIES += host-pkgconf
else
WIREGUARD_TOOLS_MAKE_OPTS += WITH_SYSTEMDUNITS=no
endif

ifeq ($(BR2_PACKAGE_BASH),y)
WIREGUARD_TOOLS_MAKE_OPTS += WITH_BASHCOMPLETION=yes WITH_WGQUICK=yes
else
WIREGUARD_TOOLS_MAKE_OPTS += WITH_BASHCOMPLETION=no WITH_WGQUICK=no
endif

define WIREGUARD_TOOLS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) $(WIREGUARD_TOOLS_MAKE_OPTS) \
		-C $(@D)/src
endef

define WIREGUARD_TOOLS_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) $(WIREGUARD_TOOLS_MAKE_OPTS) \
		-C $(@D)/src install DESTDIR=$(TARGET_DIR)
endef

$(eval $(generic-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
