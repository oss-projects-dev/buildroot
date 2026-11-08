#############################################################
#
# lighttpd
#
#############################################################

LIGHTTPD_VERSION = 1.4.51
LIGHTTPD_SITE = https://download.lighttpd.net/lighttpd/releases-1.4.x
LIGHTTPD_CUSTOM_PATCH_DIR = astlinux
LIGHTTPD_DEPENDENCIES = host-pkgconf
LIGHTTPD_CONF_OPTS = \
	--libdir=/usr/lib/lighttpd \
	--libexecdir=/usr/lib \
	--localstatedir=/var \
	$(if $(BR2_LARGEFILE),,--disable-lfs)

LIGHTTPD_CONF_ENV = \
	ac_cv_func_sendfile=no \
	ac_cv_func_sendfile64=no

ifeq ($(BR2_PACKAGE_LIGHTTPD_OPENSSL),y)
LIGHTTPD_DEPENDENCIES += openssl
LIGHTTPD_CONF_OPTS += --with-openssl
else
LIGHTTPD_CONF_OPTS += --without-openssl
endif

ifeq ($(BR2_PACKAGE_LIGHTTPD_ZLIB),y)
LIGHTTPD_DEPENDENCIES += zlib
LIGHTTPD_CONF_OPTS += --with-zlib
else
LIGHTTPD_CONF_OPTS += --without-zlib
endif

ifeq ($(BR2_PACKAGE_LIGHTTPD_BZIP2),y)
LIGHTTPD_DEPENDENCIES += bzip2
LIGHTTPD_CONF_OPTS += --with-bzip2
else
LIGHTTPD_CONF_OPTS += --without-bzip2
endif

ifeq ($(BR2_PACKAGE_LIGHTTPD_PCRE),y)
LIGHTTPD_CONF_ENV += PCRECONFIG=$(STAGING_DIR)/usr/bin/pcre-config
LIGHTTPD_DEPENDENCIES += pcre
LIGHTTPD_CONF_OPTS += --with-pcre
else
LIGHTTPD_CONF_OPTS += --without-pcre
endif

ifeq ($(BR2_PACKAGE_LIGHTTPD_WEBDAV),y)
LIGHTTPD_DEPENDENCIES += libxml2 sqlite
LIGHTTPD_CONF_OPTS += --with-webdav-props --with-webdav-locks
else
LIGHTTPD_CONF_OPTS += --without-webdav-props --without-webdav-locks
endif

define LIGHTTPD_INSTALL_INITSCRIPT
	$(INSTALL) -D -m 0644 package/lighttpd/astlinux/lighttpd.conf $(TARGET_DIR)/stat/etc/lighttpd.conf
	$(INSTALL) -D -m 0644 package/lighttpd/astlinux/lighttpd-wiki.html $(TARGET_DIR)/stat/etc/docs/lighttpd-wiki.html
	$(INSTALL) -D -m 0644 package/lighttpd/astlinux/php.ini.conf $(TARGET_DIR)/stat/etc/php.ini.conf
	$(INSTALL) -D -m 0755 package/lighttpd/astlinux/lighttpd.init $(TARGET_DIR)/etc/init.d/lighttpd
	$(INSTALL) -D -m 0644 package/lighttpd/astlinux/lighttpd.logrotate $(TARGET_DIR)/etc/logrotate.d/lighttpd
	ln -sf /tmp/etc/lighttpd.conf $(TARGET_DIR)/etc/lighttpd.conf
endef

LIGHTTPD_POST_INSTALL_TARGET_HOOKS += LIGHTTPD_INSTALL_INITSCRIPT

define LIGHTTPD_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/sbin/lighttpd
	rm -f $(TARGET_DIR)/usr/sbin/lighttpd-angel
	rm -rf $(TARGET_DIR)/usr/lib/lighttpd
endef

$(eval $(autotools-package))
