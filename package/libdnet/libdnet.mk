ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# libdnet
#
#############################################################

LIBDNET_VERSION = 1.14
LIBDNET_SOURCE = libdnet-$(LIBDNET_VERSION).tar.gz
LIBDNET_SITE = https://github.com/ofalk/libdnet/archive/refs/tags
LIBDNET_CUSTOM_PATCH_DIR = astlinux/patches
LIBDNET_INSTALL_STAGING = YES
#LIBDNET_AUTORECONF = YES
LIBDNET_CONF_OPTS = \
	--with-gnu-ld \
	--with-check=no

ifneq ($(BR2_PACKAGE_LIBDNET_PYTHON),)
LIBDNET_DEPENDENCIES = python3
LIBDNET_CONF_OPTS += --with-python
LIBDNET_MAKE_OPTS = PYINCDIR=$(STAGING_DIR)/usr/include/python$(PYTHON_VERSION_MAJOR) PYLIBDIR=$(STAGING_DIR)/usr/lib
LIBDNET_INSTALL_TARGET_OPTS = $(LIBDNET_MAKE_OPTS) DESTDIR=$(TARGET_DIR) INSTALL_STRIP_FLAG=-s install-exec
LIBDNET_INSTALL_STAGING_OPTS = $(LIBDNET_MAKE_OPTS) DESTDIR=$(STAGING_DIR) install
endif

# Needed for autoreconf to work properly
define LIBDNET_FIXUP_ACINCLUDE_M4
	ln -sf config/acinclude.m4 $(@D)
endef

#LIBDNET_POST_EXTRACT_HOOKS += LIBDNET_FIXUP_ACINCLUDE_M4

define LIBDNET_REMOVE_CONFIG_SCRIPT
	$(RM) -f $(TARGET_DIR)/usr/bin/dnet-config
endef

LIBDNET_POST_INSTALL_TARGET_HOOKS += LIBDNET_REMOVE_CONFIG_SCRIPT

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# libdnet
#
################################################################################

LIBDNET_VERSION = 1.18.0
LIBDNET_SITE = $(call github,ofalk,libdnet,libdnet-$(LIBDNET_VERSION))
LIBDNET_LICENSE = BSD-3-Clause
LIBDNET_LICENSE_FILES = LICENSE
LIBDNET_INSTALL_STAGING = YES
LIBDNET_AUTORECONF = YES
LIBDNET_CONF_OPTS = \
	--with-gnu-ld \
	--with-check=no
LIBDNET_CONFIG_SCRIPTS = dnet-config
LIBDNET_DEPENDENCIES = host-pkgconf

ifeq ($(BR2_PACKAGE_LIBDNET_PYTHON),y)
LIBDNET_DEPENDENCIES += libbsd host-python-cython python3
LIBDNET_CONF_OPTS += --with-python=$(HOST_DIR)/bin
LIBDNET_MAKE_ENV += $(PKG_PYTHON_SETUPTOOLS_ENV)
LIBDNET_INSTALL_TARGET_OPTS = $(LIBDNET_MAKE_OPTS) DESTDIR=$(TARGET_DIR) INSTALL_STRIP_FLAG=-s install-exec
LIBDNET_INSTALL_STAGING_OPTS = $(LIBDNET_MAKE_OPTS) DESTDIR=$(STAGING_DIR) install
endif

# Needed for autoreconf to work properly
define LIBDNET_FIXUP_ACINCLUDE_M4
	ln -sf config/acinclude.m4 $(@D)
endef

LIBDNET_POST_EXTRACT_HOOKS += LIBDNET_FIXUP_ACINCLUDE_M4

define LIBDNET_REMOVE_CONFIG_SCRIPT
	$(RM) -f $(TARGET_DIR)/usr/bin/dnet-config
endef

LIBDNET_POST_INSTALL_TARGET_HOOKS += LIBDNET_REMOVE_CONFIG_SCRIPT

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
