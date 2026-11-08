################################################################################
#
# libdaemon
#
################################################################################

ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)
include package/libdaemon/astlinux/libdaemon.mk
endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

LIBDAEMON_VERSION = 0.14
LIBDAEMON_SITE = http://0pointer.de/lennart/projects/libdaemon
LIBDAEMON_LICENSE = LGPL-2.1+
LIBDAEMON_LICENSE_FILES = LICENSE
LIBDAEMON_CPE_ID_VALID = YES

LIBDAEMON_INSTALL_STAGING = YES
LIBDAEMON_CONF_ENV = ac_cv_func_setpgrp_void=no
LIBDAEMON_CONF_OPTS = --disable-lynx
LIBDAEMON_DEPENDENCIES = host-pkgconf

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
