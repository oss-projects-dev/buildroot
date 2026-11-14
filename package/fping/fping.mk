ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# fping
#
#############################################################

FPING_VERSION = 5.5
FPING_SITE = https://fping.org/dist
FPING_CUSTOM_PATCH_DIR = astlinux
FPING_SOURCE = fping-$(FPING_VERSION).tar.gz

define FPING_INSTALL_TARGET_CMDS
	# Must set SUID for zabbix user
	$(INSTALL) -D -m 4711 $(@D)/src/fping $(TARGET_DIR)/usr/sbin/fping
	ln -sf fping $(TARGET_DIR)/usr/sbin/fping6
endef

define FPING_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/sbin/fping
	rm -f $(TARGET_DIR)/usr/sbin/fping6
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# fping
#
################################################################################

FPING_VERSION = 5.2
FPING_SITE = http://fping.org/dist
FPING_LICENSE = BSD-like
FPING_LICENSE_FILES = COPYING
FPING_SELINUX_MODULES = netutils

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
