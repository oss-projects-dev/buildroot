#############################################################
#
# libdaemon
#
#############################################################

LIBDAEMON_VERSION = 0.14
LIBDAEMON_SOURCE = libdaemon-$(LIBDAEMON_VERSION).tar.gz
LIBDAEMON_SITE = http://0pointer.de/lennart/projects/libdaemon
LIBDAEMON_CUSTOM_PATCH_DIR = astlinux
LIBDAEMON_INSTALL_STAGING = YES
LIBDAEMON_DEPENDENCIES = host-pkgconf

LIBDAEMON_CONF_ENV = ac_cv_func_setpgrp_void=no

LIBDAEMON_CONF_OPTS = --disable-lynx

$(eval $(autotools-package))
