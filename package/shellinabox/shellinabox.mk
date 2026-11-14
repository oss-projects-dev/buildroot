ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# shellinabox
#
#############################################################

SHELLINABOX_VERSION = 2.21
SHELLINABOX_SOURCE = shellinabox-$(SHELLINABOX_VERSION).tar.gz
SHELLINABOX_SITE = https://github.com/shellinabox/shellinabox/archive/v$(SHELLINABOX_VERSION)
SHELLINABOX_CUSTOM_PATCH_DIR = astlinux
SHELLINABOX_DEPENDENCIES = zlib openssl

SHELLINABOX_AUTORECONF = YES

SHELLINABOX_CONF_OPTS = \
	--enable-ssl \
	--disable-pam \
	--disable-runtime-loading

define SHELLINABOX_GREEN_ON_BLACK
	cp $(@D)/shellinabox/white-on-black.css $(@D)/shellinabox/green-on-black.css
	$(SED) 's/white/green/g' \
	    -e 's/#ffffff/#00ff00/g' \
		$(@D)/shellinabox/green-on-black.css
endef
SHELLINABOX_POST_BUILD_HOOKS = SHELLINABOX_GREEN_ON_BLACK

define SHELLINABOX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/shellinaboxd $(TARGET_DIR)/usr/bin/shellinaboxd
	$(INSTALL) -D -m 0755 package/shellinabox/astlinux/shellinaboxd.init $(TARGET_DIR)/etc/init.d/shellinaboxd
	$(INSTALL) -D -m 0644 $(@D)/shellinabox/black-on-white.css $(TARGET_DIR)/usr/share/shellinabox/00xBlack_on_White.css
	$(INSTALL) -D -m 0644 $(@D)/shellinabox/white-on-black.css $(TARGET_DIR)/usr/share/shellinabox/01-White_on_Black.css
	$(INSTALL) -D -m 0644 $(@D)/shellinabox/green-on-black.css $(TARGET_DIR)/usr/share/shellinabox/02-Green_on_Black.css
endef

define SHELLINABOX_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/shellinaboxd
	rm -f $(TARGET_DIR)/etc/init.d/shellinaboxd
	rm -rf $(TARGET_DIR)/usr/share/shellinabox
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# shellinabox
#
################################################################################

SHELLINABOX_VERSION = 2.20
SHELLINABOX_SITE = $(call github,shellinabox,shellinabox,v$(SHELLINABOX_VERSION))
SHELLINABOX_LICENSE = GPL-2.0 with OpenSSL exception
SHELLINABOX_LICENSE_FILES = COPYING GPL-2
SHELLINABOX_CPE_ID_VALID = YES

# 0002-CVE-2018-16789-fix-for-broken-multipart-form-data.patch
SHELLINABOX_IGNORE_CVES += CVE-2018-16789

# Fetching from Github, and patching Makefile.am, so we need to autoreconf
SHELLINABOX_AUTORECONF = YES

# The OpenSSL support is supposed to be optional, but in practice,
# with OpenSSL disabled, it fails to build. See
# https://github.com/shellinabox/shellinabox/issues/385.
SHELLINABOX_DEPENDENCIES = zlib openssl
SHELLINABOX_CONF_OPTS = \
	--disable-runtime-loading \
	--enable-ssl

# musl's implementation of utmpx is a dummy one, and some aspects of
# it cause build failures in shellinabox
ifeq ($(BR2_TOOLCHAIN_USES_MUSL),y)
SHELLINABOX_CONF_OPTS += --disable-utmp
endif

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
