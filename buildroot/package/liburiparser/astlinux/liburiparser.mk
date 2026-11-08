################################################################################
#
# liburiparser
#
################################################################################

LIBURIPARSER_VERSION = 0.9.1
LIBURIPARSER_SOURCE = uriparser-$(LIBURIPARSER_VERSION).tar.bz2
LIBURIPARSER_SITE = https://github.com/uriparser/uriparser/releases/download/uriparser-$(LIBURIPARSER_VERSION)
LIBURIPARSER_CUSTOM_PATCH_DIR = astlinux
LIBURIPARSER_INSTALL_STAGING = YES

LIBURIPARSER_CONF_OPTS = \
		--disable-test \
		--disable-doc

ifeq ($(BR2_USE_WCHAR),)
LIBURIPARSER_CONF_OPTS += --disable-wchar_t
endif

$(eval $(autotools-package))
