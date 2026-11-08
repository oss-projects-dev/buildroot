#############################################################
#
# bison
#
#############################################################

BISON_VERSION = 3.7.6
BISON_SOURCE = bison-$(BISON_VERSION).tar.xz
BISON_SITE = $(BR2_GNU_MIRROR)/bison
BISON_CUSTOM_PATCH_DIR = astlinux

HOST_BISON_DEPENDENCIES = host-m4
HOST_BISON_CONF_ENV = \
	ac_cv_path_M4=$(HOST_DIR)/bin/m4 \
	ac_cv_libtextstyle=no
HOST_BISON_CONF_OPTS = --enable-relocatable

$(eval $(host-autotools-package))
