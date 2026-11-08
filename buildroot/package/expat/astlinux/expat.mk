#############################################################
#
# expat
#
#############################################################

EXPAT_VERSION = 2.10.0
EXPAT_SITE = https://github.com/libexpat/libexpat/releases/download/R_$(subst .,_,$(EXPAT_VERSION))
EXPAT_CUSTOM_PATCH_DIR = astlinux
EXPAT_SOURCE = expat-$(EXPAT_VERSION).tar.bz2
EXPAT_INSTALL_STAGING = YES

EXPAT_DEPENDENCIES = host-pkgconf

HOST_EXPAT_DEPENDENCIES = host-pkgconf

EXPAT_CONF_OPTS = \
	--without-docbook \
	--without-xmlwf

HOST_EXPAT_CONF_OPTS = \
	--without-docbook

$(eval $(autotools-package))
$(eval $(host-autotools-package))
