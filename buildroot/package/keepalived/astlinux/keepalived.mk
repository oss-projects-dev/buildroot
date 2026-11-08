################################################################################
#
# keepalived
#
################################################################################

KEEPALIVED_VERSION = 2.4.3
KEEPALIVED_SOURCE = keepalived-$(KEEPALIVED_VERSION).tar.gz
KEEPALIVED_SITE = http://www.keepalived.org/software
KEEPALIVED_CUSTOM_PATCH_DIR = astlinux
KEEPALIVED_DEPENDENCIES = host-pkgconf linux openssl

KEEPALIVED_CONF_OPTS = \
	--disable-warnings \
	--disable-log-file \
	--disable-dbus \
	--disable-libnl \
	--disable-nftables \
	--disable-track-process \
	--disable-linkbeat \
	--runstatedir=/var/run \
	--with-init=SYSV

ifeq ($(BR2_PACKAGE_IPTABLES),y)
KEEPALIVED_DEPENDENCIES += iptables
KEEPALIVED_CONF_OPTS += --enable-iptables
else
KEEPALIVED_CONF_OPTS += --disable-iptables
endif

define KEEPALIVED_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/keepalived/keepalived $(TARGET_DIR)/usr/sbin/keepalived
	$(INSTALL) -m 0755 -D package/keepalived/astlinux/keepalived.init $(TARGET_DIR)/etc/init.d/keepalived
	ln -sf /tmp/etc/keepalived $(TARGET_DIR)/etc/keepalived
	ln -sf ../../init.d/keepalived $(TARGET_DIR)/etc/runlevels/default/S12keepalived
	ln -sf ../../init.d/keepalived $(TARGET_DIR)/etc/runlevels/default/K28keepalived
endef

define KEEPALIVED_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/sbin/keepalived
	rm -f $(TARGET_DIR)/etc/init.d/keepalived
	rm -f $(TARGET_DIR)/etc/keepalived
	rm -f $(TARGET_DIR)/etc/runlevels/default/S12keepalived
	rm -f $(TARGET_DIR)/etc/runlevels/default/K28keepalived
endef

$(eval $(autotools-package))
