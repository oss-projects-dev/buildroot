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
