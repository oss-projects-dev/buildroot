ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# libpcap
#
#############################################################

LIBPCAP_VERSION = 1.11.0
LIBPCAP_SITE = https://www.tcpdump.org/release
LIBPCAP_CUSTOM_PATCH_DIR = astlinux
LIBPCAP_SOURCE = libpcap-$(LIBPCAP_VERSION).tar.gz
LIBPCAP_INSTALL_STAGING = YES
LIBPCAP_DEPENDENCIES = zlib host-flex host-bison host-pkgconf

LIBPCAP_CONF_ENV = \
	ac_cv_header_linux_wireless_h=yes \
	CFLAGS="$(LIBPCAP_CFLAGS)"

LIBPCAP_CFLAGS = $(TARGET_CFLAGS)

LIBPCAP_CONF_OPTS = \
	--disable-yydebug \
	--with-pcap=linux \
	--without-dag \
	--disable-dbus \
	--disable-bluetooth

# Omit -rpath from pcap-config output
define LIBPCAP_CONFIG_REMOVE_RPATH
	$(SED) 's/^V_RPATH_OPT=.*/V_RPATH_OPT=""/g' $(@D)/pcap-config
endef
LIBPCAP_POST_BUILD_HOOKS = LIBPCAP_CONFIG_REMOVE_RPATH

ifeq ($(BR2_PACKAGE_LIBUSB),y)
LIBPCAP_CONF_OPTS += --enable-usb
LIBPCAP_DEPENDENCIES += libusb
else
LIBPCAP_CONF_OPTS += --disable-usb
endif

ifeq ($(BR2_PACKAGE_LIBNL),y)
LIBPCAP_DEPENDENCIES += libnl
LIBPCAP_CONF_OPTS += --with-libnl
else
LIBPCAP_CONF_OPTS += --without-libnl
endif

define LIBPCAP_STAGING_FIXUP_PCAP_CONFIG
        $(SED) "s,prefix=\"/usr\",prefix=\"$(STAGING_DIR)/usr\",g" $(STAGING_DIR)/usr/bin/pcap-config
endef
LIBPCAP_POST_INSTALL_STAGING_HOOKS += LIBPCAP_STAGING_FIXUP_PCAP_CONFIG

define LIBPCAP_TARGET_REMOVE_PCAP_CONFIG
        rm -f $(TARGET_DIR)/usr/bin/pcap-config
endef
LIBPCAP_POST_INSTALL_TARGET_HOOKS += LIBPCAP_TARGET_REMOVE_PCAP_CONFIG

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# libpcap
#
################################################################################

LIBPCAP_VERSION = 1.10.7
LIBPCAP_SITE = https://www.tcpdump.org/release
LIBPCAP_LICENSE = BSD-3-Clause
LIBPCAP_LICENSE_FILES = LICENSE
LIBPCAP_CPE_ID_VENDOR = tcpdump
LIBPCAP_INSTALL_STAGING = YES
LIBPCAP_DEPENDENCIES = host-flex host-bison host-pkgconf
HOST_LIBPCAP_DEPENDENCIES = host-flex host-bison host-pkgconf

# ac_cv_prog_cc_c99 is required for BR2_USE_WCHAR=n because the C99 test
# provided by autoconf relies on wchar_t.
LIBPCAP_CONF_ENV = \
	ac_cv_header_linux_wireless_h=yes \
	ac_cv_prog_cc_c99=-std=gnu99 \
	CFLAGS="$(LIBPCAP_CFLAGS)"
LIBPCAP_CFLAGS = $(TARGET_CFLAGS)
LIBPCAP_CONF_OPTS = --disable-yydebug --with-pcap=linux --without-dag \
	--without-dpdk
# Disable dbus to break recursive dependencies
LIBPCAP_CONF_OPTS += --disable-dbus
HOST_LIBPCAP_CONF_OPTS = \
	--disable-bluetooth \
	--disable-dbus \
	--disable-yydebug \
	--with-pcap=linux \
	--without-dag \
	--without-libnl
LIBPCAP_CONFIG_SCRIPTS = pcap-config

# Omit -rpath from pcap-config output
define LIBPCAP_CONFIG_REMOVE_RPATH
	$(SED) 's/^V_RPATH_OPT=.*/V_RPATH_OPT=""/g' $(@D)/pcap-config
endef
LIBPCAP_POST_BUILD_HOOKS = LIBPCAP_CONFIG_REMOVE_RPATH

ifeq ($(BR2_PACKAGE_BLUEZ5_UTILS_HEADERS),y)
LIBPCAP_DEPENDENCIES += bluez5_utils-headers
else
LIBPCAP_CONF_OPTS += --disable-bluetooth
endif

ifeq ($(BR2_PACKAGE_LIBNL),y)
LIBPCAP_DEPENDENCIES += libnl
LIBPCAP_CONF_OPTS += --with-libnl
else
LIBPCAP_CONF_OPTS += --without-libnl
endif

# microblaze/sparc/sparc64 need -fPIC instead of -fpic
ifeq ($(BR2_microblaze)$(BR2_sparc)$(BR2_sparc64),y)
LIBPCAP_CFLAGS += -fPIC
endif

ifeq ($(BR2_TOOLCHAIN_HAS_GCC_BUG_104028),y)
LIBPCAP_CFLAGS += -O2
endif

$(eval $(autotools-package))
$(eval $(host-autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
