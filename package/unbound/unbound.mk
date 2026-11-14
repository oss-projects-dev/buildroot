ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# unbound
#
#############################################################

UNBOUND_VERSION = 1.26.2
UNBOUND_SITE = https://nlnetlabs.nl/downloads/unbound
UNBOUND_CUSTOM_PATCH_DIR = astlinux
UNBOUND_SOURCE = unbound-$(UNBOUND_VERSION).tar.gz
UNBOUND_INSTALL_STAGING = YES

UNBOUND_DEPENDENCIES = host-bison host-flex openssl expat

UNBOUND_CONF_OPTS = \
	--disable-rpath \
	--disable-debug \
	--with-conf-file=/etc/unbound/unbound.conf \
	--with-pidfile=/var/run/unbound/unbound.pid \
	--with-rootkey-file=/etc/unbound/root.key \
	--enable-tfo-server \
	--enable-tfo-client \
	--with-libexpat="$(STAGING_DIR)/usr" \
	--with-ssl="$(STAGING_DIR)/usr"

define UNBOUND_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(STAGING_DIR)/usr/sbin/unbound $(TARGET_DIR)/usr/sbin/unbound
	$(INSTALL) -m 0755 -D $(STAGING_DIR)/usr/sbin/unbound-host $(TARGET_DIR)/usr/sbin/unbound-host
	ln -sf ../sbin/unbound-host $(TARGET_DIR)/usr/bin/host
	cp -a $(STAGING_DIR)/usr/lib/libunbound.so* $(TARGET_DIR)/usr/lib/
	ln -sf /tmp/etc/unbound $(TARGET_DIR)/etc/unbound
	$(INSTALL) -D -m 0755 package/unbound/astlinux/unbound.init $(TARGET_DIR)/etc/init.d/unbound
	ln -sf ../../init.d/unbound $(TARGET_DIR)/etc/runlevels/default/S18unbound
	ln -sf ../../init.d/unbound $(TARGET_DIR)/etc/runlevels/default/K15unbound
endef

define UNBOUND_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/sbin/unbound
	rm -f $(TARGET_DIR)/usr/sbin/unbound-host
	rm -f $(TARGET_DIR)/usr/bin/host
	rm -f $(TARGET_DIR)/usr/lib/libunbound.so*
	rm -f $(TARGET_DIR)/etc/unbound
	rm -f $(TARGET_DIR)/etc/init.d/unbound
	rm -f $(TARGET_DIR)/etc/runlevels/default/S18unbound
	rm -f $(TARGET_DIR)/etc/runlevels/default/K15unbound
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# unbound
#
################################################################################

UNBOUND_VERSION = 1.26.1
UNBOUND_SITE = https://nlnetlabs.nl/downloads/unbound
UNBOUND_INSTALL_STAGING = YES
UNBOUND_DEPENDENCIES = host-pkgconf expat libevent openssl
UNBOUND_LICENSE = BSD-3-Clause
UNBOUND_LICENSE_FILES = LICENSE
UNBOUND_CPE_ID_VENDOR = nlnetlabs
UNBOUND_CONF_OPTS = \
	--disable-rpath \
	--disable-debug \
	--with-conf-file=/etc/unbound/unbound.conf \
	--with-pidfile=/var/run/unbound.pid \
	--with-rootkey-file=/etc/unbound/root.key \
	--enable-tfo-server \
	--enable-tfo-client \
	--with-libevent=$(STAGING_DIR)/usr \
	--with-libexpat=$(STAGING_DIR)/usr \
	--with-ssl=$(STAGING_DIR)/usr

ifeq ($(BR2_TOOLCHAIN_HAS_THREADS_NPTL),y)
UNBOUND_CONF_OPTS += --with-pthreads
else
UNBOUND_CONF_OPTS += --without-pthreads
endif

ifeq ($(BR2_ENABLE_LTO),y)
UNBOUND_CONF_OPTS += --enable-flto
else
UNBOUND_CONF_OPTS += --disable-flto
endif

ifeq ($(BR2_PACKAGE_UNBOUND_DNSCRYPT),y)
UNBOUND_CONF_OPTS += --enable-dnscrypt
UNBOUND_DEPENDENCIES += libsodium
else
UNBOUND_CONF_OPTS += --disable-dnscrypt
endif

define UNBOUND_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 755 package/unbound/S70unbound \
		$(TARGET_DIR)/etc/init.d/S70unbound
endef

define UNBOUND_USERS
	unbound -1 unbound -1 * /etc/unbound - - unbound daemon
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
