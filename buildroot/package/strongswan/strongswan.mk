ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

################################################################################
#
# strongswan
#
################################################################################

STRONGSWAN_VERSION = 5.5.3
STRONGSWAN_SOURCE = strongswan-$(STRONGSWAN_VERSION).tar.bz2
STRONGSWAN_SITE = https://download.strongswan.org
STRONGSWAN_CUSTOM_PATCH_DIR = astlinux
STRONGSWAN_DEPENDENCIES = openssl host-pkgconf
STRONGSWAN_TARGET_ETC = ipsec.conf ipsec.d ipsec.secrets strongswan.conf strongswan.d $(if $(BR2_PACKAGE_STRONGSWAN_VICI),swanctl)

STRONGSWAN_CONF_OPTS += \
	--disable-static \
	--without-lib-prefix \
	--enable-updown=no \
	--enable-led=no \
	--enable-pkcs11=no \
	--enable-kernel-netlink=yes \
	--enable-socket-default=yes \
	--enable-openssl=yes \
	--enable-gcrypt=no \
	--enable-gmp=no \
	--enable-af-alg=$(if $(BR2_PACKAGE_STRONGSWAN_AF_ALG),yes,no) \
	--enable-curl=no \
	--enable-charon=$(if $(BR2_PACKAGE_STRONGSWAN_CHARON),yes,no) \
	--enable-tnccs-11=no \
	--enable-tnccs-20=no \
	--enable-tnccs-dynamic=no \
	--enable-tpm=no \
	--enable-xauth-generic=yes \
	--enable-xauth-eap=yes \
	--enable-unity=yes \
	--enable-stroke=yes \
	--enable-sqlite=$(if $(BR2_PACKAGE_STRONGSWAN_SQLITE),yes,no) \
	--enable-sql=$(if $(BR2_PACKAGE_STRONGSWAN_SQLITE),yes,no) \
	--enable-attr-sql=$(if $(BR2_PACKAGE_STRONGSWAN_SQLITE),yes,no) \
	--enable-pki=no \
	--enable-scepclient=no \
	--enable-scripts=no \
	--enable-vici=$(if $(BR2_PACKAGE_STRONGSWAN_VICI),yes,no) \
	--enable-swanctl=$(if $(BR2_PACKAGE_STRONGSWAN_VICI),yes,no) \
	--enable-addrblock=yes \
	--enable-cmd=yes

ifeq ($(BR2_PACKAGE_STRONGSWAN_EAP),y)
STRONGSWAN_CONF_OPTS += \
	--enable-eap-identity \
	--enable-eap-md5 \
	--enable-eap-mschapv2 \
	--enable-eap-tls \
	--enable-eap-ttls \
	--enable-eap-peap
endif

# Diable plugins so OpenSSL handles them
STRONGSWAN_CONF_OPTS += \
	--disable-aes \
	--disable-des \
	--disable-rc2 \
	--disable-md5 \
	--disable-sha1 \
	--disable-sha2 \
	--disable-hmac

ifeq ($(BR2_PACKAGE_STRONGSWAN_SQLITE),y)
STRONGSWAN_DEPENDENCIES += \
	$(if $(BR2_PACKAGE_SQLITE),sqlite)
endif

define STRONGSWAN_POST_INSTALL
	mkdir -p $(TARGET_DIR)/stat/etc/strongswan
	for i in $(STRONGSWAN_TARGET_ETC); do \
	  cp -a $(TARGET_DIR)/etc/$$i $(TARGET_DIR)/stat/etc/strongswan/ ; \
	  rm -rf $(TARGET_DIR)/etc/$$i ; \
	  ln -s /tmp/etc/strongswan/$$i $(TARGET_DIR)/etc/$$i ; \
	done
	rm -rf $(TARGET_DIR)/usr/share/strongswan
	$(INSTALL) -m 755 -D package/strongswan/astlinux/ipsec.init $(TARGET_DIR)/etc/init.d/ipsec
	$(INSTALL) -m 644 -D package/strongswan/astlinux/charon.logrotate $(TARGET_DIR)/etc/logrotate.d/charon
	$(INSTALL) -m 644 -D package/strongswan/astlinux/charon-logging.conf $(TARGET_DIR)/stat/etc/strongswan/strongswan.d/charon-logging.conf
	ln -sf ../../init.d/ipsec $(TARGET_DIR)/etc/runlevels/default/S31ipsec
	ln -sf ../../init.d/ipsec $(TARGET_DIR)/etc/runlevels/default/K20ipsec
endef

STRONGSWAN_POST_INSTALL_TARGET_HOOKS = STRONGSWAN_POST_INSTALL

STRONGSWAN_UNINSTALL_STAGING_OPTS = --version

define STRONGSWAN_UNINSTALL_TARGET_CMDS
	rm -rf $(TARGET_DIR)/stat/etc/strongswan
	rm -rf $(TARGET_DIR)/usr/lib/ipsec
	rm -rf $(TARGET_DIR)/usr/libexec/ipsec
	rm -f $(addprefix $(TARGET_DIR)/etc/, $(STRONGSWAN_TARGET_ETC))
	rm -f $(TARGET_DIR)/etc/init.d/ipsec
	rm -f $(TARGET_DIR)/etc/runlevels/default/S31ipsec
	rm -f $(TARGET_DIR)/etc/runlevels/default/K20ipsec
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# strongswan
#
################################################################################

STRONGSWAN_VERSION = 5.9.14
STRONGSWAN_SOURCE = strongswan-$(STRONGSWAN_VERSION).tar.bz2
STRONGSWAN_SITE = http://download.strongswan.org
STRONGSWAN_LICENSE = GPL-2.0+
STRONGSWAN_LICENSE_FILES = COPYING LICENSE
STRONGSWAN_CPE_ID_VENDOR = strongswan
STRONGSWAN_DEPENDENCIES = host-pkgconf
STRONGSWAN_INSTALL_STAGING = YES
# 0001-eap_mschapv2_failure_request_len.patch
STRONGSWAN_IGNORE_CVES += CVE-2025-62291
# 0002-fix-cve-2026-25075.patch
STRONGSWAN_IGNORE_CVES += CVE-2026-25075
STRONGSWAN_CONF_OPTS += \
	--without-lib-prefix \
	--enable-led \
	--enable-pkcs11=yes \
	--enable-kernel-netlink=yes \
	--enable-socket-default=yes \
	--enable-botan=$(if $(BR2_PACKAGE_STRONGSWAN_BOTAN),yes,no) \
	--enable-openssl=$(if $(BR2_PACKAGE_STRONGSWAN_OPENSSL),yes,no) \
	--enable-gcrypt=$(if $(BR2_PACKAGE_STRONGSWAN_GCRYPT),yes,no) \
	--enable-gmp=$(if $(BR2_PACKAGE_STRONGSWAN_GMP),yes,no) \
	--enable-af-alg=$(if $(BR2_PACKAGE_STRONGSWAN_AF_ALG),yes,no) \
	--enable-curl=$(if $(BR2_PACKAGE_STRONGSWAN_CURL),yes,no) \
	--enable-charon=$(if $(BR2_PACKAGE_STRONGSWAN_CHARON),yes,no) \
	--enable-tnccs-11=$(if $(BR2_PACKAGE_STRONGSWAN_TNCCS_11),yes,no) \
	--enable-tnccs-20=$(if $(BR2_PACKAGE_STRONGSWAN_TNCCS_20),yes,no) \
	--enable-tnccs-dynamic=$(if $(BR2_PACKAGE_STRONGSWAN_TNCCS_DYNAMIC),yes,no) \
	--enable-eap-sim-pcsc=$(if $(BR2_PACKAGE_STRONGSWAN_EAP_SIM_PCSC),yes,no) \
	--enable-unity=$(if $(BR2_PACKAGE_STRONGSWAN_UNITY),yes,no) \
	--enable-stroke=$(if $(BR2_PACKAGE_STRONGSWAN_STROKE),yes,no) \
	--enable-sql=$(if $(BR2_PACKAGE_STRONGSWAN_SQL),yes,no) \
	--enable-pki=$(if $(BR2_PACKAGE_STRONGSWAN_PKI),yes,no) \
	--enable-scripts=$(if $(BR2_PACKAGE_STRONGSWAN_SCRIPTS),yes,no) \
	--enable-vici=$(if $(BR2_PACKAGE_STRONGSWAN_VICI),yes,no) \
	--enable-swanctl=$(if $(BR2_PACKAGE_STRONGSWAN_VICI),yes,no) \
	--enable-wolfssl=$(if $(BR2_PACKAGE_STRONGSWAN_WOLFSSL),yes,no) \
	--enable-md4=$(if $(BR2_PACKAGE_STRONGSWAN_MD4),yes,no) \
	--enable-systime-fix=$(if $(BR2_PACKAGE_STRONGSWAN_SYSTIME_FIX),yes,no) \
	--enable-eap-sim=$(if $(BR2_PACKAGE_STRONGSWAN_EAP_SIM),yes,no) \
	--enable-eap-sim-file=$(if $(BR2_PACKAGE_STRONGSWAN_EAP_SIM_FILE),yes,no) \
	--enable-eap-aka=$(if $(BR2_PACKAGE_STRONGSWAN_EAP_AKA),yes,no) \
	--enable-eap-aka-3gpp2=$(if $(BR2_PACKAGE_STRONGSWAN_EAP_AKA_3GPP2),yes,no) \
	--enable-eap-simaka-sql=$(if $(BR2_PACKAGE_STRONGSWAN_EAP_SIMAKA_SQL),yes,no) \
	--enable-eap-simaka-pseudonym=$(if $(BR2_PACKAGE_STRONGSWAN_EAP_SIMAKA_PSEUDONYM),yes,no) \
	--enable-eap-simaka-reauth=$(if $(BR2_PACKAGE_STRONGSWAN_EAP_SIMAKA_REAUTH),yes,no) \
	--enable-eap-identity=$(if $(BR2_PACKAGE_STRONGSWAN_EAP_IDENTITY),yes,no) \
	--enable-eap-md5=$(if $(BR2_PACKAGE_STRONGSWAN_EAP_MD5),yes,no) \
	--enable-eap-gtc=$(if $(BR2_PACKAGE_STRONGSWAN_EAP_GTC),yes,no) \
	--enable-eap-mschapv2=$(if $(BR2_PACKAGE_STRONGSWAN_EAP_MSCHAPV2),yes,no) \
	--enable-eap-tls=$(if $(BR2_PACKAGE_STRONGSWAN_EAP_TLS),yes,no) \
	--enable-eap-ttls=$(if $(BR2_PACKAGE_STRONGSWAN_EAP_TTLS),yes,no) \
	--enable-eap-peap=$(if $(BR2_PACKAGE_STRONGSWAN_EAP_PEAP),yes,no) \
	--enable-eap-tnc=$(if $(BR2_PACKAGE_STRONGSWAN_EAP_TNC),yes,no) \
	--enable-eap-dynamic=$(if $(BR2_PACKAGE_STRONGSWAN_EAP_DYNAMIC),yes,no) \
	--enable-eap-radius=$(if $(BR2_PACKAGE_STRONGSWAN_EAP_RADIUS),yes,no) \
	--enable-bypass-lan=$(if $(BR2_PACKAGE_STRONGSWAN_BYPASS_LAN),yes,no) \
	--with-ipseclibdir=/usr/lib \
	--with-plugindir=/usr/lib/ipsec/plugins \
	--with-imcvdir=/usr/lib/ipsec/imcvs \
	--with-dev-headers=/usr/include

ifeq ($(BR2_TOOLCHAIN_HAS_LIBATOMIC),y)
STRONGSWAN_CONF_ENV += LIBS='-latomic'
endif

STRONGSWAN_DEPENDENCIES += \
	$(if $(BR2_PACKAGE_STRONGSWAN_BOTAN),botan) \
	$(if $(BR2_PACKAGE_STRONGSWAN_OPENSSL),openssl) \
	$(if $(BR2_PACKAGE_STRONGSWAN_GCRYPT),libgcrypt) \
	$(if $(BR2_PACKAGE_STRONGSWAN_GMP),gmp) \
	$(if $(BR2_PACKAGE_STRONGSWAN_EAP_AKA_3GPP2),gmp) \
	$(if $(BR2_PACKAGE_STRONGSWAN_CURL),libcurl) \
	$(if $(BR2_PACKAGE_STRONGSWAN_TNCCS_11),libxml2) \
	$(if $(BR2_PACKAGE_STRONGSWAN_EAP_SIM_PCSC),pcsc-lite) \
	$(if $(BR2_PACKAGE_STRONGSWAN_WOLFSSL),wolfssl)

ifeq ($(BR2_PACKAGE_STRONGSWAN_SQL),y)
STRONGSWAN_DEPENDENCIES += \
	$(if $(BR2_PACKAGE_SQLITE),sqlite) \
	$(if $(BR2_PACKAGE_MARIADB),mariadb)
endif

# disable connmark/forecast until net/if.h vs. linux/if.h conflict resolved
# problem exist since linux 4.5 header changes
STRONGSWAN_CONF_OPTS += \
	--disable-connmark \
	--disable-forecast

# bare minimum to start charon
define STRONGSWAN_LINUX_CONFIG_FIXUPS
	$(call KCONFIG_ENABLE_OPT,CONFIG_INET)
	$(call KCONFIG_ENABLE_OPT,CONFIG_NET)
	$(call KCONFIG_ENABLE_OPT,CONFIG_NETLINK)
	$(call KCONFIG_ENABLE_OPT,CONFIG_INET_AH)
	$(call KCONFIG_ENABLE_OPT,CONFIG_INET_ESP)
	$(call KCONFIG_ENABLE_OPT,CONFIG_XFRM)
	$(call KCONFIG_ENABLE_OPT,CONFIG_XFRM_USER)
	$(call KCONFIG_ENABLE_OPT,CONFIG_XFRM_INTERFACE)
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
