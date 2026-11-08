#############################################################
#
# stunnel
#
#############################################################

STUNNEL_VERSION = 5.80
STUNNEL_SITE = https://www.stunnel.org/archive/5.x
STUNNEL_CUSTOM_PATCH_DIR = astlinux
STUNNEL_DEPENDENCIES = openssl

STUNNEL_CONF_OPTS = \
	--with-ssl=$(STAGING_DIR)/usr \
	--localstatedir=/var \
	--disable-libwrap \
	--disable-systemd \
	--disable-fips \
	--with-threads=fork

define STUNNEL_INSTALL_TARGET_CMDS
	ln -snf /tmp/etc/stunnel $(TARGET_DIR)/etc/stunnel
	$(INSTALL) -m 0755 -D package/stunnel/astlinux/stunnel.init $(TARGET_DIR)/etc/init.d/stunnel
	$(INSTALL) -m 0755 -D $(@D)/src/stunnel $(TARGET_DIR)/usr/sbin/stunnel
endef

$(eval $(autotools-package))
