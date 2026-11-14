ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

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

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# keepalived
#
################################################################################

KEEPALIVED_VERSION = 2.2.8
KEEPALIVED_SITE = http://www.keepalived.org/software
KEEPALIVED_DEPENDENCIES = host-pkgconf openssl
KEEPALIVED_LICENSE = GPL-2.0+
KEEPALIVED_LICENSE_FILES = COPYING
KEEPALIVED_CPE_ID_VENDOR = keepalived
KEEPALIVED_CONF_OPTS = --disable-hardening

ifeq ($(BR2_PACKAGE_JSON_C),y)
KEEPALIVED_DEPENDENCIES += json-c
KEEPALIVED_CONF_OPTS += --enable-json
else
KEEPALIVED_CONF_OPTS += --disable-json
endif

ifeq ($(BR2_PACKAGE_LIBGLIB2),y)
KEEPALIVED_DEPENDENCIES += libglib2
KEEPALIVED_CONF_OPTS += --enable-dbus
else
KEEPALIVED_CONF_OPTS += --disable-dbus
endif

ifeq ($(BR2_PACKAGE_LIBNL)$(BR2_PACKAGE_LIBNFNETLINK),yy)
KEEPALIVED_DEPENDENCIES += libnl libnfnetlink
KEEPALIVED_CONF_OPTS += --enable-libnl
else
KEEPALIVED_CONF_OPTS += --disable-libnl
endif

ifeq ($(BR2_PACKAGE_IPTABLES),y)
KEEPALIVED_DEPENDENCIES += iptables
KEEPALIVED_CONF_OPTS += --enable-iptables
# ipset support only makes sense when iptables support is enabled.
ifeq ($(BR2_PACKAGE_IPSET),y)
KEEPALIVED_DEPENDENCIES += ipset
KEEPALIVED_CONF_OPTS += --enable-libipset
else
KEEPALIVED_CONF_OPTS += --disable-libipset
endif
else
KEEPALIVED_CONF_OPTS += --disable-iptables
endif

ifeq ($(BR2_PACKAGE_LIBNFTNL),y)
KEEPALIVED_DEPENDENCIES += libnftnl
KEEPALIVED_CONF_OPTS += --enable-nftables
else
KEEPALIVED_CONF_OPTS += --disable-nftables
endif

ifeq ($(BR2_TOOLCHAIN_GCC_AT_LEAST_4_9),)
KEEPALIVED_CONF_OPTS += --disable-track-process
endif

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
