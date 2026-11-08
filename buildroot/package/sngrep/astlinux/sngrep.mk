################################################################################
#
# sngrep
#
################################################################################

SNGREP_VERSION = 1.9.0
SNGREP_SOURCE = sngrep-$(SNGREP_VERSION).tar.gz
SNGREP_SITE = https://github.com/irontec/sngrep/releases/download/v$(SNGREP_VERSION)
SNGREP_CUSTOM_PATCH_DIR = astlinux
SNGREP_AUTORECONF = YES
SNGREP_DEPENDENCIES = libpcap ncurses

SNGREP_CONF_OPTS = \
	--without-pcre \
	--disable-unicode \
	--enable-ipv6 \
	--enable-eep

# openssl and gnutls can't be enabled at the same time.
ifeq ($(BR2_PACKAGE_OPENSSL),y)
SNGREP_DEPENDENCIES += openssl
SNGREP_CONF_OPTS += --with-openssl --without-gnutls
# gnutls support also requires libgcrypt
else ifeq ($(BR2_PACKAGE_GNUTLS)$(BR2_PACKAGE_LIBGCRYPT),yy)
SNGREP_DEPENDENCIES += gnutls
SNGREP_CONF_OPTS += --with-gnutls --without-openssl
else
SNGREP_CONF_OPTS += --without-gnutls --without-openssl
endif

ifeq ($(BR2_PACKAGE_PCRE2),y)
SNGREP_DEPENDENCIES += pcre2
SNGREP_CONF_OPTS += --with-pcre2
else
SNGREP_CONF_OPTS += --without-pcre2
endif

$(eval $(autotools-package))
