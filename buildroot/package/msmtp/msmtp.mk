ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# msmtp
#
#############################################################

MSMTP_VERSION = 1.8.34
MSMTP_SOURCE = msmtp-$(MSMTP_VERSION).tar.xz
MSMTP_SITE = https://marlam.de/msmtp/releases
MSMTP_CUSTOM_PATCH_DIR = astlinux
MSMTP_DEPENDENCIES = libretls

MSMTP_CONF_OPTS += \
	--with-tls=libtls \
	--without-libgsasl \
	--without-libidn \
	--without-libsecret \
	--disable-gai-idn \
	--sysconfdir=/etc

define MSMTP_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/src/msmtp $(TARGET_DIR)/usr/sbin/msmtp
	$(INSTALL) -m 0755 -D $(@D)/src/msmtpd $(TARGET_DIR)/usr/sbin/msmtpd
	$(INSTALL) -m 0755 -D package/msmtp/astlinux/msmtp.init $(TARGET_DIR)/etc/init.d/msmtp
	$(INSTALL) -m 0755 -D package/msmtp/astlinux/msmtpd.init $(TARGET_DIR)/etc/init.d/msmtpd
	$(INSTALL) -m 0755 -D package/msmtp/astlinux/msmtpqueue.sh $(TARGET_DIR)/usr/sbin/msmtpqueue
	$(INSTALL) -m 0755 -D package/msmtp/astlinux/sendmail.sh $(TARGET_DIR)/usr/sbin/sendmail
	$(INSTALL) -m 0755 -D package/msmtp/astlinux/testmail.sh $(TARGET_DIR)/usr/sbin/testmail
	$(INSTALL) -m 0755 -D package/msmtp/astlinux/mime-pack.sh $(TARGET_DIR)/usr/sbin/mime-pack
	$(INSTALL) -m 0755 -D package/msmtp/astlinux/mail.sh $(TARGET_DIR)/bin/mail
	ln -sf ../../bin/mail $(TARGET_DIR)/usr/bin/mail
	ln -sf /tmp/etc/msmtprc $(TARGET_DIR)/etc/msmtprc
	ln -sf ../../init.d/msmtp $(TARGET_DIR)/etc/runlevels/default/S34msmtp
	ln -sf ../../init.d/msmtp $(TARGET_DIR)/etc/runlevels/default/K24msmtp
	ln -sf ../../init.d/msmtpd $(TARGET_DIR)/etc/runlevels/default/S08msmtpd
	ln -sf ../../init.d/msmtpd $(TARGET_DIR)/etc/runlevels/default/K30msmtpd
endef

define MSMTP_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/sbin/msmtp
	rm -f $(TARGET_DIR)/usr/sbin/msmtpd
	rm -f $(TARGET_DIR)/etc/init.d/msmtp
	rm -f $(TARGET_DIR)/etc/init.d/msmtpd
	rm -f $(TARGET_DIR)/usr/sbin/msmtpqueue
	rm -f $(TARGET_DIR)/usr/sbin/sendmail
	rm -f $(TARGET_DIR)/usr/sbin/testmail
	rm -f $(TARGET_DIR)/usr/sbin/mime-pack
	rm -f $(TARGET_DIR)/bin/mail
	rm -f $(TARGET_DIR)/usr/bin/mail
	rm -f $(TARGET_DIR)/etc/msmtprc
	rm -f $(TARGET_DIR)/etc/runlevels/default/S34msmtp
	rm -f $(TARGET_DIR)/etc/runlevels/default/K24msmtp
	rm -f $(TARGET_DIR)/etc/runlevels/default/S08msmtpd
	rm -f $(TARGET_DIR)/etc/runlevels/default/K30msmtpd
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# msmtp
#
################################################################################

MSMTP_VERSION = 1.8.28
MSMTP_SITE = https://marlam.de/msmtp/releases
MSMTP_SOURCE = msmtp-$(MSMTP_VERSION).tar.xz
MSMTP_DEPENDENCIES = host-pkgconf
MSMTP_CONF_OPTS = --disable-gai-idn
MSMTP_LICENSE = GPL-3.0+
MSMTP_LICENSE_FILES = COPYING
MSMTP_CPE_ID_VENDOR = marlam

# msmtpd needs fork
ifeq ($(BR2_USE_MMU),y)
MSMTP_CONF_OPTS += --with-msmtpd
else
MSMTP_CONF_OPTS += --without-msmtpd
endif

ifeq ($(BR2_PACKAGE_LIBGSASL),y)
MSMTP_CONF_OPTS += --with-libgsasl
MSMTP_DEPENDENCIES += libgsasl
else
MSMTP_CONF_OPTS += --without-libgsasl
endif

ifeq ($(BR2_PACKAGE_LIBIDN2),y)
MSMTP_CONF_OPTS += --with-libidn
MSMTP_DEPENDENCIES += libidn2
else
MSMTP_CONF_OPTS += --without-libidn
endif

ifeq ($(BR2_PACKAGE_LIBSECRET),y)
MSMTP_CONF_OPTS += --with-libsecret
MSMTP_DEPENDENCIES += libsecret
else
MSMTP_CONF_OPTS += --without-libsecret
endif

ifeq ($(BR2_PACKAGE_GNUTLS),y)
MSMTP_CONF_OPTS += --with-tls=gnutls
MSMTP_DEPENDENCIES += gnutls
else ifeq ($(BR2_PACKAGE_OPENSSL),y)
MSMTP_CONF_OPTS += --with-tls=openssl
MSMTP_DEPENDENCIES += openssl
else
MSMTP_CONF_OPTS += --with-tls=no
endif

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
