ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

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

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# expat
#
################################################################################

EXPAT_VERSION = 2.9.0
EXPAT_SITE = https://github.com/libexpat/libexpat/releases/download/R_$(subst .,_,$(EXPAT_VERSION))
EXPAT_SOURCE = expat-$(EXPAT_VERSION).tar.xz
EXPAT_INSTALL_STAGING = YES
EXPAT_LICENSE = MIT
EXPAT_LICENSE_FILES = COPYING
EXPAT_CPE_ID_VENDOR = libexpat_project
EXPAT_CPE_ID_PRODUCT = libexpat

EXPAT_CONF_OPTS = \
	--with-dev-urandom \
	--without-docbook \
	--without-examples \
	--without-tests \
	--without-xmlwf

HOST_EXPAT_CONF_OPTS = \
	--without-docbook \
	--without-examples \
	--without-tests

$(eval $(autotools-package))
$(eval $(host-autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
