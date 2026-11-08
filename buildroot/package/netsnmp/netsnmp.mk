ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# netsnmp
#
#############################################################

NETSNMP_VERSION = 5.9.4
NETSNMP_SITE = https://downloads.sourceforge.net/project/net-snmp/net-snmp/$(NETSNMP_VERSION)
NETSNMP_CUSTOM_PATCH_DIR = astlinux
NETSNMP_SOURCE = net-snmp-$(NETSNMP_VERSION).tar.gz
NETSNMP_INSTALL_STAGING = YES
NETSNMP_CONF_ENV = ac_cv_NETSNMP_CAN_USE_SYSCTL=no
NETSNMP_CONF_OPTS = \
	--with-persistent-directory=/var/lib/snmp \
	--disable-static \
	--with-defaults \
	--enable-mini-agent \
	--without-rpm \
	--with-logfile=none \
	--without-kmem-usage \
	--enable-as-needed \
	--disable-debugging \
	--without-perl-modules \
	--disable-embedded-perl \
	--disable-perl-cc-checks \
	--disable-scripts \
	--with-default-snmp-version="1" \
	--enable-silent-libtool \
	--enable-mfd-rewrites \
	--with-sys-contact="root@localhost" \
	--with-sys-location="Unknown" \
	--with-mib-modules="host ucd-snmp/dlmod agentx" \
	--with-out-mib-modules="disman/event disman/schedule utilities" \
	--disable-manuals
NETSNMP_MAKE = $(MAKE1)
NETSNMP_BLOAT_MIBS = BRIDGE DISMAN-EVENT DISMAN-SCHEDULE DISMAN-SCRIPT EtherLike RFC-1215 RFC1155-SMI RFC1213 SCTP SMUX

ifeq ($(BR2_ENDIAN),"BIG")
	NETSNMP_CONF_OPTS += --with-endianness=big
else
	NETSNMP_CONF_OPTS += --with-endianness=little
endif

# libnl - nl_connect
NETSNMP_CONF_OPTS += --without-nl

# OpenSSL
ifeq ($(BR2_PACKAGE_OPENSSL),y)
	NETSNMP_DEPENDENCIES += host-pkgconf openssl
	NETSNMP_CONF_OPTS += \
		--with-openssl=$(STAGING_DIR)/usr/include/openssl \
		--with-security-modules="tsm,usm" \
		--with-transports="DTLSUDP,TLSTCP"
else
	NETSNMP_CONF_OPTS += --without-openssl
endif

# libpci - pci_lookup_name
ifeq ($(BR2_PACKAGE_PCIUTILS),y)
	NETSNMP_DEPENDENCIES += pciutils
endif

# Remove IPv6 MIBs if there's no IPv6
ifneq ($(BR2_INET_IPV6),y)
define NETSNMP_REMOVE_MIBS_IPV6
	rm -f $(TARGET_DIR)/usr/share/snmp/mibs/IPV6*
endef
else
	NETSNMP_CONF_OPTS += --enable-ipv6
endif

define NETSNMP_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) \
		DESTDIR=$(TARGET_DIR) install
	$(INSTALL) -D -m 0755 package/netsnmp/astlinux/netsnmp.init \
		$(TARGET_DIR)/etc/init.d/snmpd
	ln -snf /tmp/etc/snmp $(TARGET_DIR)/etc/snmp
	for mib in $(NETSNMP_BLOAT_MIBS); do \
		rm -f $(TARGET_DIR)/usr/share/snmp/mibs/$$mib-MIB.txt; \
	done
	$(NETSNMP_REMOVE_MIBS_IPV6)
endef

define NETSNMP_UNINSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) \
		DESTDIR=$(TARGET_DIR) uninstall
	rm -f $(TARGET_DIR)/etc/init.d/snmpd
	rm -f $(TARGET_DIR)/usr/lib/libnetsnmp*
endef

define NETSNMP_STAGING_NETSNMP_CONFIG_FIXUP
	$(SED) "s,^prefix=.*,prefix=\'$(STAGING_DIR)/usr\',g" \
		-e "s,^exec_prefix=.*,exec_prefix=\'$(STAGING_DIR)/usr\',g" \
		-e "s,^includedir=.*,includedir=\'$(STAGING_DIR)/usr/include\',g" \
		-e "s,^libdir=.*,libdir=\'$(STAGING_DIR)/usr/lib\',g" \
		$(STAGING_DIR)/usr/bin/net-snmp-config
endef
NETSNMP_POST_INSTALL_STAGING_HOOKS += NETSNMP_STAGING_NETSNMP_CONFIG_FIXUP

define NETSNMP_TARGET_REMOVE_NETSNMP_SCRIPTS
	rm -f $(TARGET_DIR)/usr/bin/net-snmp-config
	rm -f $(TARGET_DIR)/usr/bin/net-snmp-create-v3-user
endef
NETSNMP_POST_INSTALL_TARGET_HOOKS += NETSNMP_TARGET_REMOVE_NETSNMP_SCRIPTS

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# netsnmp
#
################################################################################

NETSNMP_VERSION = 5.9.3
NETSNMP_SITE = https://downloads.sourceforge.net/project/net-snmp/net-snmp/$(NETSNMP_VERSION)
NETSNMP_SOURCE = net-snmp-$(NETSNMP_VERSION).tar.gz
NETSNMP_LICENSE = Various BSD-like
NETSNMP_LICENSE_FILES = COPYING
NETSNMP_CPE_ID_VENDOR = net-snmp
NETSNMP_CPE_ID_PRODUCT = $(NETSNMP_CPE_ID_VENDOR)
# 0001-snmp_agent-disallow-SET-with-NULL-varbind.patch
NETSNMP_IGNORE_CVES = \
	CVE-2022-44792 \
	CVE-2022-44793
# 0003-snmptrapd-Fix-out-of-bounds-trapOid-accesses.patch
NETSNMP_IGNORE_CVES += CVE-2025-68615
NETSNMP_SELINUX_MODULES = snmp
NETSNMP_INSTALL_STAGING = YES
NETSNMP_CONF_ENV = \
	ac_cv_NETSNMP_CAN_USE_SYSCTL=no \
	ac_cv_path_PSPROG=/bin/ps
NETSNMP_CONF_OPTS = \
	--with-persistent-directory=/var/lib/snmp \
	--with-defaults \
	--enable-mini-agent \
	--without-rpm \
	--with-logfile=none \
	--without-kmem-usage \
	--enable-as-needed \
	--without-perl-modules \
	--disable-embedded-perl \
	--disable-perl-cc-checks \
	--disable-scripts \
	--with-default-snmp-version="1" \
	--enable-silent-libtool \
	--enable-mfd-rewrites \
	--with-sys-contact="root@localhost" \
	--with-sys-location="Unknown" \
	--with-mib-modules="$(call qstrip,$(BR2_PACKAGE_NETSNMP_WITH_MIB_MODULES))" \
	--with-out-mib-modules="$(call qstrip,$(BR2_PACKAGE_NETSNMP_WITHOUT_MIB_MODULES))" \
	--disable-manuals
NETSNMP_INSTALL_STAGING_OPTS = DESTDIR=$(STAGING_DIR) LIB_LDCONFIG_CMD=true install
NETSNMP_INSTALL_TARGET_OPTS = DESTDIR=$(TARGET_DIR) LIB_LDCONFIG_CMD=true install
NETSNMP_CONFIG_SCRIPTS = net-snmp-config
# We're patching configure.d/config_project_types
NETSNMP_AUTORECONF = YES

define NETSNMP_USERS
	snmp -1 snmp -1 * - - - snmpd user
endef

ifeq ($(BR2_INIT_SYSTEMD),y)
NETSNMP_CONF_OPTS += --with-systemd
else
NETSNMP_CONF_OPTS += --without-systemd
endif

ifeq ($(BR2_ENDIAN),"BIG")
NETSNMP_CONF_OPTS += --with-endianness=big
else
NETSNMP_CONF_OPTS += --with-endianness=little
endif

ifeq ($(BR2_PACKAGE_LIBNL),y)
NETSNMP_DEPENDENCIES += host-pkgconf libnl
NETSNMP_CONF_OPTS += --with-nl
else
NETSNMP_CONF_OPTS += --without-nl
endif

# OpenSSL
ifeq ($(BR2_PACKAGE_OPENSSL),y)
NETSNMP_DEPENDENCIES += host-pkgconf openssl
NETSNMP_CONF_OPTS += \
	--with-openssl=$(STAGING_DIR)/usr/include/openssl \
	--with-security-modules="tsm,usm" \
	--with-transports="DTLSUDP,TLSTCP"
NETSNMP_CONF_ENV += LIBS=`$(PKG_CONFIG_HOST_BINARY) --libs openssl`
else ifeq ($(BR2_PACKAGE_NETSNMP_OPENSSL_INTERNAL),y)
NETSNMP_CONF_OPTS += --with-openssl=internal
else
NETSNMP_CONF_OPTS += --without-openssl
endif

# There's no option to forcibly enable or disable it
ifeq ($(BR2_PACKAGE_PCIUTILS),y)
NETSNMP_DEPENDENCIES += pciutils
endif

# For ucd-snmp/lmsensorsMib
ifeq ($(BR2_PACKAGE_LM_SENSORS),y)
NETSNMP_DEPENDENCIES += lm-sensors
endif

ifneq ($(BR2_PACKAGE_NETSNMP_ENABLE_MIBS),y)
NETSNMP_CONF_OPTS += --disable-mib-loading
NETSNMP_CONF_OPTS += --disable-mibs
endif

ifneq ($(BR2_PACKAGE_NETSNMP_ENABLE_DEBUGGING),y)
NETSNMP_CONF_OPTS += --disable-debugging
endif

ifeq ($(BR2_PACKAGE_NETSNMP_SERVER),y)
NETSNMP_CONF_OPTS += --enable-agent
else
NETSNMP_CONF_OPTS += --disable-agent
endif

ifeq ($(BR2_PACKAGE_NETSNMP_CLIENTS),y)
NETSNMP_CONF_OPTS += --enable-applications
else
NETSNMP_CONF_OPTS += --disable-applications
endif

ifeq ($(BR2_PACKAGE_NETSNMP_SERVER),y)
define NETSNMP_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 package/netsnmp/S59snmpd \
		$(TARGET_DIR)/etc/init.d/S59snmpd
endef
define NETSNMP_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 0644 package/netsnmp/snmpd.service \
		$(TARGET_DIR)/usr/lib/systemd/system/snmpd.service
endef
endif

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
