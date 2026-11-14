ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# openldap
#
#############################################################

OPENLDAP_VERSION = 2.4.59
OPENLDAP_SOURCE = openldap-$(OPENLDAP_VERSION).tgz
OPENLDAP_SITE = http://www.openldap.org/software/download/OpenLDAP/openldap-release
OPENLDAP_CUSTOM_PATCH_DIR = astlinux
OPENLDAP_INSTALL_STAGING = YES
OPENLDAP_DEPENDENCIES += openssl

OPENLDAP_UNINSTALL_STAGING_OPTS = --version

OPENLDAP_CONF_OPTS = \
	--enable-shared \
	--disable-static \
	--disable-debug \
	--enable-syslog \
	--enable-ipv6 \
	--enable-crypt \
	--with-tls \
	--with-yielding_select=yes \
	--without-fetch \
	--without-cyrus-sasl \
	--enable-slapd \
	--enable-mdb \
	--enable-null \
	--disable-local \
	--disable-bdb \
	--disable-hdb \
	--disable-monitor \
	--disable-relay \
	-enable-dynamic=$(if $(BR2_STATIC_LIBS),no,yes)

ifeq ($(BR2_PACKAGE_OPENLDAP_SERVER),y)
define OPENLDAP_INSTALL_TARGET_SERVER
	cp -a $(STAGING_DIR)/etc/openldap/schema $(TARGET_DIR)/etc/openldap/
	$(INSTALL) -D -m 0755 $(STAGING_DIR)/usr/libexec/slapd $(TARGET_DIR)/usr/sbin/
	$(INSTALL) -D -m 0755 $(STAGING_DIR)/usr/bin/ldap* $(TARGET_DIR)/usr/bin/
	$(INSTALL) -m 0755 -D package/openldap/astlinux/slapd.init $(TARGET_DIR)/etc/init.d/slapd
	$(INSTALL) -m 0444 -D package/openldap/astlinux/schema/*.schema $(TARGET_DIR)/etc/openldap/schema/
	$(INSTALL) -m 0755 -D package/openldap/astlinux/scripts/ldap* $(TARGET_DIR)/usr/bin/
	$(INSTALL) -m 0755 -D package/openldap/astlinux/vcard-export $(TARGET_DIR)/usr/sbin/
	ln -sf /tmp/etc/openldap/slapd.conf $(TARGET_DIR)/etc/openldap/slapd.conf
	ln -sf ../../init.d/slapd $(TARGET_DIR)/etc/runlevels/default/S45slapd
	ln -sf ../../init.d/slapd $(TARGET_DIR)/etc/runlevels/default/K16slapd
endef
endif

define OPENLDAP_INSTALL_TARGET_CMDS
	cp -a $(STAGING_DIR)/usr/lib/libldap*.so* $(TARGET_DIR)/usr/lib/
	cp -a $(STAGING_DIR)/usr/lib/liblber*.so* $(TARGET_DIR)/usr/lib/
	chmod +x $(TARGET_DIR)/usr/lib/libldap*.so* \
		 $(TARGET_DIR)/usr/lib/liblber*.so*
	$(INSTALL) -D -m 0755 $(STAGING_DIR)/usr/bin/ldapsearch $(TARGET_DIR)/usr/bin/ldapsearch
	$(INSTALL) -D -m 0755 $(STAGING_DIR)/usr/bin/ldapwhoami $(TARGET_DIR)/usr/bin/ldapwhoami
	$(INSTALL) -m 0755 -D package/openldap/astlinux/ldap.init $(TARGET_DIR)/etc/init.d/ldap
	mkdir -p $(TARGET_DIR)/etc/openldap
	ln -sf /tmp/etc/openldap/ldap.conf $(TARGET_DIR)/etc/openldap/ldap.conf
	ln -sf ../../init.d/ldap $(TARGET_DIR)/etc/runlevels/default/S01ldap
	$(OPENLDAP_INSTALL_TARGET_SERVER)
endef

define OPENLDAP_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/lib/libldap*
	rm -f $(TARGET_DIR)/usr/lib/liblber*
	rm -f $(TARGET_DIR)/usr/bin/ldap*
	rm -f $(TARGET_DIR)/etc/init.d/ldap
	rm -f $(TARGET_DIR)/etc/init.d/slapd
	rm -rf $(TARGET_DIR)/etc/openldap
	rm -f $(TARGET_DIR)/etc/runlevels/default/S01ldap
	rm -f $(TARGET_DIR)/etc/runlevels/default/S45slapd
	rm -f $(TARGET_DIR)/etc/runlevels/default/K16slapd
	rm -f $(TARGET_DIR)/usr/sbin/slapd
	rm -f $(TARGET_DIR)/usr/sbin/vcard-export
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# openldap
#
################################################################################

OPENLDAP_VERSION = 2.5.19
OPENLDAP_SOURCE = openldap-$(OPENLDAP_VERSION).tgz
OPENLDAP_SITE = https://www.openldap.org/software/download/OpenLDAP/openldap-release
OPENLDAP_LICENSE = OpenLDAP Public License
OPENLDAP_LICENSE_FILES = LICENSE
OPENLDAP_CPE_ID_VENDOR = openldap
OPENLDAP_SELINUX_MODULES = ldap
OPENLDAP_INSTALL_STAGING = YES
OPENLDAP_DEPENDENCIES = host-pkgconf

ifeq ($(BR2_PACKAGE_OPENSSL),y)
OPENLDAP_TLS = openssl
OPENLDAP_DEPENDENCIES += openssl
else ifeq ($(BR2_PACKAGE_GNUTLS),y)
OPENLDAP_TLS = gnutls
OPENLDAP_DEPENDENCIES += gnutls
else ifeq ($(BR2_PACKAGE_LIBNSS),y)
OPENLDAP_TLS = moznss
OPENLDAP_DEPENDENCIES += libnss
OPENLDAP_CPPFLAGS = \
	-I$(STAGING_DIR)/usr/include/nss \
	-I$(STAGING_DIR)/usr/include/nspr
else
OPENLDAP_TLS = no
endif

ifeq ($(BR2_PACKAGE_OPENSSL),y)
OPENLDAP_MP = bignum
OPENLDAP_DEPENDENCIES += openssl
OPENLDAP_CONF_ENV = LIBS="`$(PKG_CONFIG_HOST_BINARY) --libs libssl libcrypto`"
else ifeq ($(BR2_PACKAGE_GMP),y)
OPENLDAP_MP = gmp
OPENLDAP_DEPENDENCIES += gmp
else
OPENLDAP_MP = longlong
endif

OPENLDAP_CONF_ENV += ac_cv_func_memcmp_working=yes

OPENLDAP_CONF_OPTS += \
	--enable-syslog \
	--disable-proctitle \
	--disable-slapd \
	--with-yielding-select \
	--sysconfdir=/etc \
	--enable-dynamic=$(if $(BR2_STATIC_LIBS),no,yes) \
	--with-tls=$(OPENLDAP_TLS) \
	--with-mp=$(OPENLDAP_MP) \
	CPPFLAGS="$(TARGET_CPPFLAGS) $(OPENLDAP_CPPFLAGS)"

# Somehow, ${STRIP} does not percolates through to the shtool script
# used to install the executables; thus, that script tries to run the
# executable it is supposed to install, resulting in an error.
OPENLDAP_MAKE_ENV = STRIP="$(TARGET_STRIP)"

ifeq ($(BR2_PACKAGE_OPENLDAP_CLIENTS),)
OPENLDAP_CLIENTS = \
	ldapurl ldapexop ldapcompare ldapwhoami \
	ldappasswd ldapmodrdn ldapdelete ldapmodify \
	ldapsearch
define OPENLDAP_REMOVE_CLIENTS
	$(RM) -f $(foreach p,$(OPENLDAP_CLIENTS),$(TARGET_DIR)/usr/bin/$(p))
	$(RM) -rf $(TARGET_DIR)/etc/openldap
endef
OPENLDAP_POST_INSTALL_TARGET_HOOKS += OPENLDAP_REMOVE_CLIENTS
endif

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
