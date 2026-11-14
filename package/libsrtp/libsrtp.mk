ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# libsrtp
#
#############################################################

LIBSRTP_VERSION = 2.8.1
LIBSRTP_SITE = https://github.com/cisco/libsrtp/archive/v$(LIBSRTP_VERSION)
LIBSRTP_CUSTOM_PATCH_DIR = astlinux
LIBSRTP_SOURCE = libsrtp-$(LIBSRTP_VERSION).tar.gz
LIBSRTP_INSTALL_STAGING = YES
LIBSRTP_DEPENDENCIES = host-pkgconf openssl

LIBSRTP_CONF_OPTS = \
	--prefix=/usr \
	--disable-nss \
	--enable-openssl

LIBSRTP_MAKE_OPTS = shared_library

define LIBSRTP_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/lib/libsrtp2.so*
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# libsrtp
#
################################################################################

LIBSRTP_VERSION = 2.6.0
LIBSRTP_SITE = $(call github,cisco,libsrtp,v$(LIBSRTP_VERSION))
LIBSRTP_INSTALL_STAGING = YES
LIBSRTP_LICENSE = BSD-3-Clause
LIBSRTP_LICENSE_FILES = LICENSE
LIBSRTP_CPE_ID_VENDOR = cisco

ifeq ($(BR2_STATIC_LIBS),y)
LIBSRTP_MAKE_OPTS = libsrtp2.a
else ifeq ($(BR2_SHARED_LIBS),y)
LIBSRTP_MAKE_OPTS = shared_library
else
LIBSRTP_MAKE_OPTS = libsrtp2.a shared_library
endif

LIBSRTP_DEPENDENCIES = host-pkgconf

ifeq ($(BR2_PACKAGE_OPENSSL),y)
LIBSRTP_DEPENDENCIES += openssl
LIBSRTP_CONF_OPTS += --disable-nss --enable-openssl
else ifeq ($(BR2_PACKAGE_LIBNSS),y)
LIBSRTP_DEPENDENCIES += libnss
LIBSRTP_CONF_OPTS += --enable-nss --disable-openssl
else
LIBSRTP_CONF_OPTS += --disable-nss --disable-openssl
endif

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
