ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# pppd
#
#############################################################

PPPD_VERSION = 2.4.9
PPPD_SOURCE = ppp-$(PPPD_VERSION).tar.gz
PPPD_SITE = https://github.com/paulusmack/ppp/archive/ppp-$(PPPD_VERSION)
PPPD_CUSTOM_PATCH_DIR = astlinux
PPPD_DEPENDENCIES = openssl libpcap

PPPD_INSTALL_STAGING = YES
PPPD_TARGET_BINS = chat pppd pppdump pppstats

PPPD_MAKE_OPTS =

define PPPD_CONFIGURE_CMDS
	$(SED) 's/^USE_EAPTLS=y/#USE_EAPTLS=y/' $(PPPD_DIR)/pppd/Makefile.linux
	( cd $(@D); $(TARGET_MAKE_ENV) ./configure --prefix=/usr )
endef

define PPPD_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) CC="$(TARGET_CC)" COPTS="$(TARGET_CFLAGS)" \
		-C $(@D) $(PPPD_MAKE_OPT)
endef

define PPPD_UNINSTALL_TARGET_CMDS
	rm -f $(addprefix $(TARGET_DIR)/usr/sbin/, $(PPPD_TARGET_BINS))
	rm -f $(TARGET_DIR)/usr/sbin/pppoe-*
	rm -rf $(TARGET_DIR)/usr/lib/pppd
endef

define PPPD_INSTALL_TARGET_CMDS
	for sbin in $(PPPD_TARGET_BINS); do \
		$(INSTALL) -D $(PPPD_DIR)/$$sbin/$$sbin \
			$(TARGET_DIR)/usr/sbin/$$sbin; \
	done
	for sbin in pppoe-start pppoe-stop pppoe-restart pppoe-status; do \
		$(INSTALL) -D -m 0755 package/pppd/astlinux/pppoe/$$sbin \
			$(TARGET_DIR)/usr/sbin/$$sbin; \
	done
	$(INSTALL) -D $(PPPD_DIR)/pppd/plugins/minconn.so \
		$(TARGET_DIR)/usr/lib/pppd/$(PPPD_VERSION)/minconn.so
	$(INSTALL) -D $(PPPD_DIR)/pppd/plugins/passprompt.so \
		$(TARGET_DIR)/usr/lib/pppd/$(PPPD_VERSION)/passprompt.so
	$(INSTALL) -D $(PPPD_DIR)/pppd/plugins/passwordfd.so \
		$(TARGET_DIR)/usr/lib/pppd/$(PPPD_VERSION)/passwordfd.so
##	No ATM kernel support
#	$(INSTALL) -D $(PPPD_DIR)/pppd/plugins/pppoatm/pppoatm.so \
#		$(TARGET_DIR)/usr/lib/pppd/$(PPPD_VERSION)/pppoatm.so
##
	$(INSTALL) -D $(PPPD_DIR)/pppd/plugins/pppoe/pppoe.so \
		$(TARGET_DIR)/usr/lib/pppd/$(PPPD_VERSION)/pppoe.so
	$(INSTALL) -D $(PPPD_DIR)/pppd/plugins/pppoe/pppoe-discovery \
		$(TARGET_DIR)/usr/sbin/pppoe-discovery
	$(INSTALL) -D $(PPPD_DIR)/pppd/plugins/winbind.so \
		$(TARGET_DIR)/usr/lib/pppd/$(PPPD_VERSION)/winbind.so
	$(INSTALL) -D $(PPPD_DIR)/pppd/plugins/pppol2tp/openl2tp.so \
		$(TARGET_DIR)/usr/lib/pppd/$(PPPD_VERSION)/openl2tp.so
	$(INSTALL) -D $(PPPD_DIR)/pppd/plugins/pppol2tp/pppol2tp.so \
		$(TARGET_DIR)/usr/lib/pppd/$(PPPD_VERSION)/pppol2tp.so
	ln -snf /tmp/etc/ppp $(TARGET_DIR)/etc/ppp
endef

define PPPD_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) INSTROOT=$(STAGING_DIR)/ -C $(@D) $(PPPD_MAKE_OPT) install-devel
endef

$(eval $(generic-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# pppd
#
################################################################################

# The tarball provided at https://download.samba.org/pub/ppp/ does not
# include the license files yet so we use the github tarball.
PPPD_VERSION = 2.5.2
PPPD_SITE = $(call github,ppp-project,ppp,v$(PPPD_VERSION))
PPPD_LICENSE = LGPL-2.0+, LGPL, BSD-4-Clause, BSD-3-Clause, GPL-2.0+
PPPD_LICENSE_FILES = LICENSE.BSD LICENSE.GPL-2
PPPD_CPE_ID_VENDOR = point-to-point_protocol_project
PPPD_CPE_ID_PRODUCT = point-to-point_protocol
PPPD_SELINUX_MODULES = ppp
PPPD_AUTORECONF = YES
PPPD_INSTALL_STAGING = YES
PPPD_CONF_OPTS = --enable-multilink

ifeq ($(BR2_PACKAGE_LINUX_PAM),y)
PPPD_CONF_OPTS += --with-pam=$(STAGING_DIR)/usr
PPPD_DEPENDENCIES += linux-pam
else
PPPD_CONF_OPTS += --without-pam
endif

ifeq ($(BR2_PACKAGE_OPENSSL),y)
PPPD_CONF_OPTS += \
	--enable-eaptls \
	--enable-openssl-engine \
	--enable-peap \
	--with-openssl=$(STAGING_DIR)/usr
PPPD_DEPENDENCIES += openssl
else
PPPD_CONF_OPTS += \
	--disable-eaptls \
	--disable-openssl-engine \
	--disable-peap \
	--without-openssl
endif

ifeq ($(BR2_PACKAGE_PPPD_FILTER),y)
PPPD_CONF_OPTS += --with-pcap=$(STAGING_DIR)/usr
PPPD_DEPENDENCIES += libpcap
else
PPPD_CONF_OPTS += --without-pcap
endif

ifeq ($(BR2_PACKAGE_SYSTEMD),y)
PPPD_CONF_OPTS += --enable-systemd
PPPD_DEPENDENCIES += systemd
else
PPPD_CONF_OPTS += --disable-systemd
endif

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
