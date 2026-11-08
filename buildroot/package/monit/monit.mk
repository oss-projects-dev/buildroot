ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

################################################################################
#
# monit
#
################################################################################

MONIT_VERSION = 6.0.0
MONIT_SITE = https://mmonit.com/monit/dist
MONIT_CUSTOM_PATCH_DIR = astlinux
MONIT_DEPENDENCIES = host-bison host-flex
#
# Touching Makefile.am and configure.ac:
#MONIT_AUTORECONF = YES
define MONIT_BOOTSTRAP_AFTER_PATCH
	(cd $(@D); \
		$(HOST_CONFIGURE_OPTS) \
		./bootstrap \
	)
endef
MONIT_POST_PATCH_HOOKS += MONIT_BOOTSTRAP_AFTER_PATCH

MONIT_CONF_ENV = \
	ac_cv_ipv6=yes \
	libmonit_cv_setjmp_available=yes \
	libmonit_cv_vsnprintf_c99_conformant=yes

MONIT_CONF_OPTS += \
	--sysconfdir=/etc/monit \
	--with-piddir=/var/run \
	--without-pam

ifeq ($(BR2_PACKAGE_OPENSSL),y)
MONIT_CONF_OPTS += --with-ssl-dir=$(STAGING_DIR)/usr
MONIT_DEPENDENCIES += openssl
else
MONIT_CONF_OPTS += --without-ssl
endif

ifeq ($(BR2_LARGEFILE),y)
MONIT_CONF_OPTS += --with-largefiles
else
MONIT_CONF_OPTS += --without-largefiles
endif

define MONIT_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/monit $(TARGET_DIR)/usr/sbin/monit
	$(INSTALL) -m 0600 -D package/monit/astlinux/monit.services $(TARGET_DIR)/stat/etc/monit/monit.d/services.conf
	$(INSTALL) -m 0755 -D package/monit/astlinux/monit.init $(TARGET_DIR)/etc/init.d/monit
	ln -sf /tmp/etc/monit $(TARGET_DIR)/etc/monit
	ln -sf ../../init.d/monit $(TARGET_DIR)/etc/runlevels/default/S98monit
	ln -sf ../../init.d/monit $(TARGET_DIR)/etc/runlevels/default/K01monit
endef

define MONIT_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/sbin/monit
	rm -rf $(TARGET_DIR)/stat/etc/monit
	rm -f $(TARGET_DIR)/etc/init.d/monit
	rm -f $(TARGET_DIR)/etc/monit
	rm -f $(TARGET_DIR)/etc/runlevels/default/S98monit
	rm -f $(TARGET_DIR)/etc/runlevels/default/K01monit
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# monit
#
################################################################################

MONIT_VERSION = 5.34.3
MONIT_SITE = https://mmonit.com/monit/dist
MONIT_LICENSE = AGPL-3.0 with OpenSSL exception
MONIT_LICENSE_FILES = COPYING
MONIT_CPE_ID_VENDOR = mmonit
MONIT_SELINUX_MODULES = monit

# Touching Makefile.am:
# 0001-configure.ac-fixes-missing-config-macro-dir.patch touches configure.ac
MONIT_AUTORECONF = YES

MONIT_CONF_ENV = \
	libmonit_cv_setjmp_available=yes \
	libmonit_cv_vsnprintf_c99_conformant=yes \
	ax_cv_check_cflags___fstack_protector_all=$(if $(BR2_TOOLCHAIN_HAS_SSP),yes,no) \
	ac_cv_ipv6=yes

MONIT_CONF_OPTS += \
	--without-pam \
	--with-largefiles

ifeq ($(BR2_PACKAGE_LIBXCRYPT),y)
MONIT_DEPENDENCIES += libxcrypt
endif

ifeq ($(BR2_PACKAGE_OPENSSL),y)
MONIT_CONF_ENV += LIBS=`$(PKG_CONFIG_HOST_BINARY) --libs openssl`
ifeq ($(BR2_STATIC_LIBS),y)
MONIT_CONF_OPTS += --with-ssl-static=$(STAGING_DIR)/usr
else
MONIT_CONF_OPTS += --with-ssl --with-ssl-dir=$(STAGING_DIR)/usr
endif
MONIT_DEPENDENCIES += host-pkgconf openssl
else
MONIT_CONF_OPTS += --without-ssl
endif

ifeq ($(BR2_PACKAGE_ZLIB),y)
MONIT_CONF_OPTS += --with-zlib
MONIT_DEPENDENCIES += zlib
else
MONIT_CONF_OPTS += --without-zlib
endif

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
