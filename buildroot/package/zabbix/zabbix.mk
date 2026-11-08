ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# zabbix
#
#############################################################

ZABBIX_VERSION = 4.0.50
ZABBIX_SOURCE = zabbix-$(ZABBIX_VERSION).tar.gz
ZABBIX_SITE = https://cdn.zabbix.com/zabbix/sources/oldstable/4.0
ZABBIX_CUSTOM_PATCH_DIR = astlinux

ZABBIX_CONF_OPTS = \
	--disable-static \
	--enable-agent \
	--enable-ipv6

ifeq ($(BR2_PACKAGE_ZABBIX_PROXY),y)
ZABBIX_DEPENDENCIES += sqlite fping
ZABBIX_CONF_OPTS += \
	--enable-proxy \
	--with-sqlite3="$(STAGING_DIR)/usr"

 ifeq ($(BR2_PACKAGE_CURL),y)
ZABBIX_DEPENDENCIES += libcurl
ZABBIX_CONF_OPTS += \
	--with-libcurl="$(STAGING_DIR)/usr/bin/curl-config"
 endif

 ifeq ($(BR2_PACKAGE_NETSNMP),y)
ZABBIX_DEPENDENCIES += netsnmp
ZABBIX_CONF_OPTS += \
	--with-net-snmp="$(STAGING_DIR)/usr/bin/net-snmp-config"
 endif
endif

ifeq ($(BR2_PACKAGE_OPENSSL),y)
ZABBIX_DEPENDENCIES += openssl
ZABBIX_CONF_OPTS += --with-openssl=$(STAGING_DIR)/usr
else
ZABBIX_CONF_OPTS += --without-openssl
endif

ifeq ($(BR2_PACKAGE_PCRE),y)
ZABBIX_DEPENDENCIES += pcre
ZABBIX_CONF_OPTS += --with-libpcre=$(STAGING_DIR)/usr
else
ZABBIX_CONF_OPTS += --without-libpcre
endif

define ZABBIX_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/src/zabbix_agent/zabbix_agentd $(TARGET_DIR)/usr/bin/zabbix_agentd
	if [ -f $(@D)/src/zabbix_proxy/zabbix_proxy ]; then \
	  $(INSTALL) -m 0755 -D $(@D)/src/zabbix_proxy/zabbix_proxy $(TARGET_DIR)/usr/bin/zabbix_proxy ; \
          ln -sf /tmp/etc/zabbix_proxy.conf $(TARGET_DIR)/etc/zabbix_proxy.conf ; \
	fi
	$(INSTALL) -m 0755 -D package/zabbix/astlinux/zabbix.init $(TARGET_DIR)/etc/init.d/zabbix
	ln -sf /tmp/etc/zabbix_agentd.conf $(TARGET_DIR)/etc/zabbix_agentd.conf
	ln -sf ../../init.d/zabbix $(TARGET_DIR)/etc/runlevels/default/S98zabbix
	ln -sf ../../init.d/zabbix $(TARGET_DIR)/etc/runlevels/default/K01zabbix
endef

define ZABBIX_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/zabbix_agentd
	rm -f $(TARGET_DIR)/usr/bin/zabbix_proxy
	rm -f $(TARGET_DIR)/etc/init.d/zabbix
	rm -f $(TARGET_DIR)/etc/zabbix_agentd.conf
	rm -f $(TARGET_DIR)/etc/zabbix_proxy.conf
	rm -f $(TARGET_DIR)/etc/runlevels/default/S98zabbix
	rm -f $(TARGET_DIR)/etc/runlevels/default/K01zabbix
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# zabbix
#
################################################################################

ZABBIX_VERSION_MAJOR = 7.2
ZABBIX_VERSION = $(ZABBIX_VERSION_MAJOR).15
ZABBIX_SITE = https://cdn.zabbix.com/zabbix/sources/oldstable/$(ZABBIX_VERSION_MAJOR)
ZABBIX_SELINUX_MODULES = zabbix
ZABBIX_LICENSE = AGPL-3.0
ZABBIX_LICENSE_FILES = COPYING
ZABBIX_CPE_ID_VENDOR = zabbix
# We're patching m4/netsnmp.m4
ZABBIX_AUTORECONF = YES

ZABBIX_DEPENDENCIES = host-pkgconf pcre2
ZABBIX_CONF_OPTS = \
	--with-libpcre2 \
	--without-sqlite3 \
	--enable-agent \
	--disable-agent2 \
	--disable-java \
	--disable-proxy \
	--disable-webservice

define ZABBIX_USERS
	zabbix -1 zabbix -1 * /var/lib/zabbix - - zabbix user
endef

ZABBIX_SYSTEMD_UNITS += zabbix-agent.service

define ZABBIX_CHANGE_PIDFILE_LOCATION
	$(SED) 's%\#\ PidFile=/tmp/zabbix\(.*\).pid%PidFile=/run/zabbix/zabbix\1.pid%g' $(@D)/conf/zabbix_*.conf
endef
ZABBIX_POST_PATCH_HOOKS += ZABBIX_CHANGE_PIDFILE_LOCATION

ifeq ($(BR2_PACKAGE_OPENIPMI),y)
ZABBIX_CONF_OPTS += --with-openipmi=$(STAGING_DIR)/usr
ZABBIX_DEPENDENCIES += openipmi
else
ZABBIX_CONF_OPTS += --without-openipmi
endif

ifeq ($(BR2_PACKAGE_LIBCURL),y)
ZABBIX_CONF_OPTS += --with-libcurl=$(STAGING_DIR)/usr/bin/curl-config
ZABBIX_DEPENDENCIES += libcurl
else
ZABBIX_CONF_OPTS += --without-libcurl
endif

ifeq ($(BR2_PACKAGE_LIBXML2),y)
ZABBIX_CONF_OPTS += --with-libxml2=$(STAGING_DIR)/usr
ZABBIX_DEPENDENCIES += libxml2
else
ZABBIX_CONF_OPTS += --without-libxml2
endif

ifeq ($(BR2_PACKAGE_NETSNMP_ENABLE_MIBS),y)
ZABBIX_CONF_OPTS += --with-net-snmp=$(STAGING_DIR)/usr/bin/net-snmp-config
ZABBIX_DEPENDENCIES += netsnmp
else
ZABBIX_CONF_OPTS += --without-net-snmp
endif

ifeq ($(BR2_PACKAGE_OPENLDAP),y)
ZABBIX_CONF_OPTS += --with-ldap=$(STAGING_DIR)/usr
ZABBIX_DEPENDENCIES += openldap
else
ZABBIX_CONF_OPTS += --without-ldap
endif

ifeq ($(BR2_PACKAGE_LIBSSH2),y)
ZABBIX_CONF_OPTS += --with-ssh2=$(STAGING_DIR)/usr
ZABBIX_DEPENDENCIES += libssh2
else
ZABBIX_CONF_OPTS += --without-ssh2
endif

# Only one of openssl or gnutls should be enabled. libressl is not
# supported, which is why we test BR2_PACKAGE_LIBOPENSSL, not
# BR2_PACKAGE_OPENSSL
ifeq ($(BR2_PACKAGE_LIBOPENSSL),y)
ZABBIX_CONF_OPTS += --with-openssl=$(STAGING_DIR)/usr --without-gnutls
ZABBIX_DEPENDENCIES += openssl
else ifeq ($(BR2_PACKAGE_GNUTLS),y)
ZABBIX_CONF_OPTS += --with-gnutls=$(STAGING_DIR)/usr --without-openssl
ZABBIX_DEPENDENCIES += gnutls
else
ZABBIX_CONF_OPTS += --without-gnutls --without-openssl
endif

ifeq ($(BR2_PACKAGE_ZABBIX_SERVER),y)

ZABBIX_DEPENDENCIES += libevent zlib
ZABBIX_CONF_OPTS += \
	--enable-server \
	--with-libevent=$(STAGING_DIR)/usr \
	--with-libpthread=$(STAGING_DIR)/usr \
	--with-zlib=$(STAGING_DIR)/usr
ZABBIX_SYSTEMD_UNITS += zabbix-server.service

ifeq ($(BR2_PACKAGE_ZABBIX_SERVER_COPY_FRONTEND),y)
define ZABBIX_SERVER_COPY_FRONTEND
	mkdir -p $(TARGET_DIR)/var/www/zabbix/
	cp -dpfr $(@D)/ui/* $(TARGET_DIR)/var/www/zabbix/
endef
ZABBIX_POST_INSTALL_TARGET_HOOKS += ZABBIX_SERVER_COPY_FRONTEND
endif

ifeq ($(BR2_PACKAGE_ZABBIX_SERVER_MYSQL),y)
ZABBIX_DEPENDENCIES += mariadb
ZABBIX_CONF_OPTS += --with-mysql=$(STAGING_DIR)/usr/bin/mysql_config --without-postgresql
ZABBIX_DATABASE = mysql
else ifeq ($(BR2_PACKAGE_ZABBIX_SERVER_POSTGRESQL),y)
ZABBIX_DEPENDENCIES += postgresql
ZABBIX_CONF_OPTS += --with-postgresql=$(STAGING_DIR)/usr/bin/pg_config --without-mysql
ZABBIX_DATABASE = postgresql
endif

ifeq ($(BR2_PACKAGE_ZABBIX_SERVER_COPY_DUMPS),y)
define ZABBIX_SERVER_COPY_DUMPS
	mkdir -p $(TARGET_DIR)/var/lib/zabbix/schema/
	install -m 644 $(@D)/database/$(ZABBIX_DATABASE)/*.sql $(TARGET_DIR)/var/lib/zabbix/schema/
endef
ZABBIX_POST_INSTALL_TARGET_HOOKS += ZABBIX_SERVER_COPY_DUMPS
endif

endif # BR2_PACKAGE_ZABBIX_SERVER

# zabbix uses custom --enable-{static,shared} options, instead of
# standard libtool directives resulting in a build failure with libcurl
# or openssl.
ifeq ($(BR2_SHARED_STATIC_LIBS),y)
ZABBIX_CONF_OPTS += --disable-static
endif

define ZABBIX_INSTALL_INIT_SYSTEMD
	$(foreach unit,$(ZABBIX_SYSTEMD_UNITS),\
		$(INSTALL) -D -m 0644 $(ZABBIX_PKGDIR)/$(unit) $(TARGET_DIR)/usr/lib/systemd/system/$(unit) && \
		mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants && \
		ln -fs -r $(TARGET_DIR)/usr/lib/systemd/system/$(unit) $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/$(unit)
	)
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
