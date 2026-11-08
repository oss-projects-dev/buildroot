#############################################################
#
# libretls
#
#############################################################

LIBRETLS_VERSION = 3.8.1
LIBRETLS_SITE = https://causal.agency/libretls
LIBRETLS_CUSTOM_PATCH_DIR = astlinux
LIBRETLS_INSTALL_STAGING = YES

LIBRETLS_DEPENDENCIES = host-pkgconf openssl

LIBRETLS_CONF_OPTS = \
	--with-openssl=$(STAGING_DIR)/usr \

$(eval $(autotools-package))
