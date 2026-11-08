ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# popt
#
#############################################################
POPT_VERSION = 1.16
# rpm5.org down
POPT_SITE = http://anduin.linuxfromscratch.org/sources/BLFS/svn/p/
POPT_CUSTOM_PATCH_DIR = astlinux
POPT_INSTALL_STAGING = YES

POPT_CONF_ENV = ac_cv_va_copy=yes

ifeq ($(BR2_PACKAGE_LIBICONV),y)
POPT_CONF_ENV += am_cv_lib_iconv=yes
POPT_CONF_OPTS += --with-libiconv-prefix=$(STAGING_DIR)/usr
endif

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# popt
#
################################################################################

POPT_VERSION = 1.19
POPT_SITE = http://ftp.rpm.org/popt/releases/popt-1.x
POPT_INSTALL_STAGING = YES
POPT_LICENSE = MIT
POPT_LICENSE_FILES = COPYING
POPT_CPE_ID_VALID = YES

POPT_DEPENDENCIES = $(TARGET_NLS_DEPENDENCIES)

POPT_CONF_ENV = ac_cv_va_copy=yes

ifeq ($(BR2_PACKAGE_LIBICONV),y)
POPT_CONF_ENV += am_cv_lib_iconv=yes
POPT_CONF_OPTS += --with-libiconv-prefix=$(STAGING_DIR)/usr
POPT_DEPENDENCIES += libiconv
endif

$(eval $(autotools-package))
$(eval $(host-autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
