ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# neon
#
#############################################################

NEON_VERSION = 0.34.2
NEON_SITE = https://notroj.github.io/neon
NEON_CUSTOM_PATCH_DIR = astlinux
NEON_INSTALL_STAGING = YES
NEON_CONF_OPTS = --without-gssapi

NEON_DEPENDENCIES = host-pkgconf

ifeq ($(BR2_PACKAGE_NEON_ZLIB),y)
NEON_CONF_OPTS += --with-zlib=yes
NEON_DEPENDENCIES += zlib
else
NEON_CONF_OPTS += --without-zlib
endif

ifeq ($(BR2_PACKAGE_NEON_SSL),y)
NEON_CONF_OPTS += --with-ssl
NEON_DEPENDENCIES += openssl
else
NEON_CONF_OPTS += --without-ssl
endif

ifeq ($(BR2_PACKAGE_NEON_EXPAT),y)
NEON_CONF_OPTS += --with-expat=$(STAGING_DIR)/usr/lib/libexpat.la
NEON_DEPENDENCIES += expat
else
NEON_CONF_OPTS += --with-expat=no
endif

ifeq ($(BR2_PACKAGE_NEON_LIBXML2),y)
NEON_CONF_OPTS += --with-libxml2=yes
NEON_CONF_ENV += ac_cv_prog_XML2_CONFIG=$(STAGING_DIR)/usr/bin/xml2-config
NEON_DEPENDENCIES += libxml2
else
NEON_CONF_OPTS += --with-libxml2=no
endif

ifeq ($(BR2_PACKAGE_NEON_NOXML),y)
# webdav needs xml support
NEON_CONF_OPTS += --disable-webdav
endif

ifneq ($(BR2_HAVE_DEVFILES),y)
define NEON_REMOVE_CONFIG_SCRIPTS
	rm -f $(TARGET_DIR)/usr/bin/neon-config
endef
NEON_POST_INSTALL_TARGET_HOOKS += NEON_REMOVE_CONFIG_SCRIPTS
endif

define NEON_STAGING_NEON_CONFIG_FIXUP
	$(SED) "s,^prefix=.*,prefix=\'$(STAGING_DIR)/usr\',g" \
		-e "s,^exec_prefix=.*,exec_prefix=\'$(STAGING_DIR)/usr\',g" \
		$(STAGING_DIR)/usr/bin/neon-config
endef
NEON_POST_INSTALL_STAGING_HOOKS += NEON_STAGING_NEON_CONFIG_FIXUP

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# neon
#
################################################################################

NEON_VERSION = 0.33.0
NEON_SITE = https://notroj.github.io/neon
NEON_LICENSE = LGPL-2.0+ (library), GPL-2.0+ (manual and tests)
NEON_LICENSE_FILES = src/COPYING.LIB test/COPYING README.md
NEON_CPE_ID_VENDOR = webdav
NEON_INSTALL_STAGING = YES
NEON_CONF_OPTS = --without-gssapi
NEON_CONFIG_SCRIPTS = neon-config
NEON_DEPENDENCIES = host-pkgconf $(TARGET_NLS_DEPENDENCIES)
NEON_CONF_ENV = ne_cv_libsfor_bindtextdomain=$(TARGET_NLS_LIBS)

ifeq ($(BR2_PACKAGE_NEON_ZLIB),y)
NEON_CONF_OPTS += --with-zlib
NEON_DEPENDENCIES += zlib
else
NEON_CONF_OPTS += --without-zlib
endif

ifeq ($(BR2_PACKAGE_NEON_SSL),y)
NEON_CONF_OPTS += --with-ssl
NEON_DEPENDENCIES += openssl
else
NEON_CONF_OPTS += --without-ssl
endif

ifeq ($(BR2_PACKAGE_NEON_EXPAT),y)
NEON_CONF_OPTS += --with-expat=yes
NEON_DEPENDENCIES += expat
else
NEON_CONF_OPTS += --with-expat=no
endif

ifeq ($(BR2_PACKAGE_NEON_LIBXML2),y)
NEON_CONF_OPTS += --with-libxml2=yes
NEON_CONF_ENV += ac_cv_prog_XML2_CONFIG=$(STAGING_DIR)/usr/bin/xml2-config
NEON_DEPENDENCIES += libxml2
else
NEON_CONF_OPTS += --with-libxml2=no
endif

ifeq ($(BR2_PACKAGE_NEON_EXPAT)$(BR2_PACKAGE_NEON_LIBXML2),)
# webdav needs xml support
NEON_CONF_OPTS += --disable-webdav
endif

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
