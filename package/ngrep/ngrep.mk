ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# ngrep
#
#############################################################

NGREP_VERSION = 1.49.0
NGREP_SOURCE = ngrep-$(NGREP_VERSION).tar.gz
NGREP_SITE = https://github.com/jpr5/ngrep/archive/v$(NGREP_VERSION)
NGREP_CUSTOM_PATCH_DIR = astlinux
NGREP_DEPENDENCIES = libpcap pcre2

NGREP_UNINSTALL_STAGING_OPTS = --version

NGREP_CONF_ENV = \
	NGREP_PCRE2_CONFIG_SCRIPT="$(STAGING_DIR)/usr/bin/pcre2-config"

NGREP_CONF_OPTS = \
	--disable-pcap-restart \
	--disable-tcpkill \
	--with-dropprivs-user=nobody \
	--with-pcap-includes=$(STAGING_DIR)/usr/include \
	--enable-pcre2 \
	--enable-ipv6

define NGREP_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/ngrep $(TARGET_DIR)/usr/bin/ngrep
endef

define NGREP_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/ngrep
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# ngrep
#
################################################################################

NGREP_VERSION = 1.47
NGREP_SITE = $(call github,jpr5,ngrep,$(subst .,_,V$(NGREP_VERSION)))
NGREP_LICENSE = BSD-4-Clause-like, BSD-3-Clause (tcpkill)
NGREP_LICENSE_FILES = LICENSE
NGREP_INSTALL_STAGING = YES
# We're patching configure.in
NGREP_AUTORECONF = YES

ifeq ($(BR2_STATIC_LIBS),y)
NGREP_CONF_ENV += LIBS=`$(STAGING_DIR)/usr/bin/pcap-config --static --additional-libs`
endif

NGREP_CONF_OPTS = \
	--with-pcap-includes=$(STAGING_DIR)/usr/include/pcap \
	--enable-pcre \
	--disable-dropprivs \
	--disable-pcap-restart

NGREP_DEPENDENCIES = host-pkgconf libpcap pcre

ifeq ($(BR2_PACKAGE_LIBNET),y)
NGREP_DEPENDENCIES += libnet
NGREP_CONF_OPTS += --enable-tcpkill
else
NGREP_CONF_OPTS += --disable-tcpkill
endif

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
