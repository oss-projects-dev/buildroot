ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# openvpn
#
#############################################################

OPENVPN_VERSION = 2.4.12
OPENVPN_SITE = https://swupdate.openvpn.net/community/releases
OPENVPN_CUSTOM_PATCH_DIR = astlinux
OPENVPN_DEPENDENCIES = host-pkgconf openssl

OPENVPN_CONF_OPTS = \
	--disable-debug \
	--disable-plugins \
	--disable-lz4 \
	--enable-iproute2 \
	--with-crypto-library=openssl

OPENVPN_CONF_ENV = \
	IFCONFIG=/sbin/ifconfig \
	NETSTAT=/bin/netstat \
	ROUTE=/sbin/route

ifeq ($(BR2_PACKAGE_IPROUTE2),y)
OPENVPN_CONF_ENV += IPROUTE=/sbin/ip
else
OPENVPN_CONF_ENV += IPROUTE=/bin/ip
endif

ifeq ($(BR2_PACKAGE_OPENVPN_LZO),y)
	OPENVPN_DEPENDENCIES += lzo
else
	OPENVPN_CONF_OPTS += --disable-lzo
endif

define OPENVPN_INSTALL_TARGET_CMDS
	$(INSTALL) -m 755 $(@D)/src/openvpn/openvpn $(TARGET_DIR)/usr/sbin/openvpn
	$(INSTALL) -m 755 -D package/openvpn/astlinux/openvpn.init $(TARGET_DIR)/etc/init.d/openvpn
	$(INSTALL) -m 644 -D package/openvpn/astlinux/openvpn.logrotate $(TARGET_DIR)/etc/logrotate.d/openvpn
	$(INSTALL) -m 755 -D package/openvpn/astlinux/openvpnclient.init $(TARGET_DIR)/etc/init.d/openvpnclient
	$(INSTALL) -m 755 -D package/openvpn/astlinux/tls-verify.sh $(TARGET_DIR)/usr/sbin/openvpn-tls-verify
	$(INSTALL) -m 755 -D package/openvpn/astlinux/user-pass-verify.sh $(TARGET_DIR)/usr/sbin/openvpn-user-pass-verify
	ln -sf /tmp/etc/openvpn.conf $(TARGET_DIR)/etc/openvpn.conf
	ln -sf /tmp/etc/openvpnclient.conf $(TARGET_DIR)/etc/openvpnclient.conf
	ln -sf /tmp/etc/openvpn $(TARGET_DIR)/etc/openvpn
endef

define OPENVPN_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/sbin/openvpn
	rm -f $(TARGET_DIR)/etc/init.d/openvpn
	rm -f $(TARGET_DIR)/etc/init.d/openvpnclient
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# openvpn
#
################################################################################

OPENVPN_VERSION = 2.6.23
OPENVPN_SITE = https://swupdate.openvpn.net/community/releases
OPENVPN_DEPENDENCIES = host-pkgconf libcap-ng
OPENVPN_LICENSE = GPL-2.0
OPENVPN_LICENSE_FILES = COPYRIGHT.GPL
OPENVPN_CPE_ID_VENDOR = openvpn
OPENVPN_SELINUX_MODULES = openvpn
OPENVPN_CONF_OPTS = \
	--disable-unit-tests \
	$(if $(BR2_STATIC_LIBS),--disable-plugins)
OPENVPN_CONF_ENV = NETSTAT=/bin/netstat

ifeq ($(BR2_PACKAGE_LIBNL)$(BR2_TOOLCHAIN_HEADERS_AT_LEAST_4_16),yy)
OPENVPN_CONF_OPTS += --enable-dco
OPENVPN_DEPENDENCIES += libnl
else
OPENVPN_CONF_OPTS += --disable-dco
endif

ifeq ($(BR2_PACKAGE_OPENVPN_SMALL),y)
OPENVPN_CONF_OPTS += \
	--enable-small \
	--disable-plugins
endif

ifeq ($(BR2_PACKAGE_OPENVPN_LZ4),y)
OPENVPN_DEPENDENCIES += lz4
else
OPENVPN_CONF_OPTS += --disable-lz4
endif

ifeq ($(BR2_PACKAGE_OPENVPN_LZO),y)
OPENVPN_DEPENDENCIES += lzo
else
OPENVPN_CONF_OPTS += --disable-lzo
endif

ifeq ($(BR2_PACKAGE_LIBSELINUX),y)
OPENVPN_DEPENDENCIES += libselinux
OPENVPN_CONF_OPTS += --enable-selinux
else
OPENVPN_CONF_OPTS += --disable-selinux
endif

ifeq ($(BR2_PACKAGE_LINUX_PAM),y)
OPENVPN_DEPENDENCIES += linux-pam
OPENVPN_CONF_OPTS += --enable-plugin-auth-pam
else
OPENVPN_CONF_OPTS += --disable-plugin-auth-pam
endif

ifeq ($(BR2_PACKAGE_OPENSSL),y)
OPENVPN_DEPENDENCIES += openssl
OPENVPN_CONF_OPTS += --with-crypto-library=openssl
else ifeq ($(BR2_PACKAGE_MBEDTLS),y)
OPENVPN_DEPENDENCIES += mbedtls
OPENVPN_CONF_OPTS += --with-crypto-library=mbedtls
endif

ifeq ($(BR2_PACKAGE_PKCS11_HELPER),y)
OPENVPN_DEPENDENCIES += pkcs11-helper
OPENVPN_CONF_OPTS += --enable-pkcs11
else
OPENVPN_CONF_OPTS += --disable-pkcs11
endif

ifeq ($(BR2_PACKAGE_SYSTEMD),y)
OPENVPN_DEPENDENCIES += systemd
OPENVPN_CONF_OPTS += --enable-systemd
else
OPENVPN_CONF_OPTS += --disable-systemd
endif

define OPENVPN_INSTALL_INIT_SYSV
	$(INSTALL) -m 755 -D package/openvpn/S60openvpn \
		$(TARGET_DIR)/etc/init.d/S60openvpn
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
