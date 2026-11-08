ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# mtr
#
#############################################################

MTR_VERSION = 0.96
MTR_SITE = https://github.com/traviscross/mtr/archive/v$(MTR_VERSION)
MTR_CUSTOM_PATCH_DIR = astlinux
MTR_SOURCE = mtr-$(MTR_VERSION).tar.gz

MTR_DEPENDENCIES = host-pkgconf ncurses libcap

# no configure built
MTR_AUTORECONF = YES

MTR_CONF_OPTS = \
	--disable-braille \
	--without-gtk

ifeq ($(BR2_PACKAGE_JANSSON),y)
MTR_CONF_OPTS += --with-jansson
MTR_DEPENDENCIES += jansson
else
MTR_CONF_OPTS += --without-jansson
endif

define MTR_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/mtr $(TARGET_DIR)/usr/sbin/
	$(INSTALL) -D -m 4711 $(@D)/mtr-packet $(TARGET_DIR)/usr/sbin/
endef

define MTR_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/sbin/mtr
	rm -f $(TARGET_DIR)/usr/sbin/mtr-packet
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# mtr
#
################################################################################

MTR_VERSION = 0.95
MTR_SITE = $(call github,traviscross,mtr,v$(MTR_VERSION))
MTR_AUTORECONF = YES
MTR_DEPENDENCIES = \
	host-pkgconf \
	$(if $(BR2_PACKAGE_LIBCAP),libcap)
MTR_LICENSE = GPL-2.0
MTR_LICENSE_FILES = COPYING
MTR_SELINUX_MODULES = netutils

ifeq ($(BR2_PACKAGE_JANSSON),y)
MTR_CONF_OPTS += --with-jansson
MTR_DEPENDENCIES += jansson
else
MTR_CONF_OPTS += --without-jansson
endif

ifeq ($(BR2_PACKAGE_LIBGTK3),y)
MTR_CONF_OPTS += --with-gtk
MTR_DEPENDENCIES += libgtk3
else
MTR_CONF_OPTS += --without-gtk
endif

ifeq ($(BR2_PACKAGE_NCURSES),y)
MTR_CONF_OPTS += --with-ncurses
MTR_DEPENDENCIES += ncurses
else
MTR_CONF_OPTS += --without-ncurses
endif

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
