ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# dialog
#
#############################################################
DIALOG_VERSION = 1.3-20210117
DIALOG_SOURCE = dialog-$(DIALOG_VERSION).tgz
DIALOG_SITE = https://invisible-mirror.net/archives/dialog
DIALOG_CUSTOM_PATCH_DIR = astlinux
DIALOG_DEPENDENCIES = host-pkgconf ncurses

DIALOG_CONF_OPTS = \
	--with-ncurses \
	--with-curses-dir=$(STAGING_DIR)/usr \
	--disable-rpath-hack \
	NCURSES_CONFIG=$(STAGING_DIR)/usr/bin/$(NCURSES_CONFIG_SCRIPTS)

ifneq ($(BR2_ENABLE_LOCALE),y)
DIALOG_DEPENDENCIES += libiconv
endif

define DIALOG_INSTALL_TARGET_CMDS
	install -c $(@D)/dialog $(TARGET_DIR)/usr/bin/dialog
endef

define DIALOG_POST_CLEAN
	-$(MAKE) -C $(@D) clean
	rm -f $(TARGET_DIR)/usr/bin/dialog
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# dialog
#
################################################################################

DIALOG_VERSION = 1.3-20220117
DIALOG_SOURCE = dialog-$(DIALOG_VERSION).tgz
DIALOG_SITE = https://invisible-mirror.net/archives/dialog
DIALOG_CONF_OPTS = --with-ncurses --with-curses-dir=$(STAGING_DIR)/usr \
	--disable-rpath-hack
DIALOG_DEPENDENCIES = host-pkgconf ncurses $(TARGET_NLS_DEPENDENCIES)
DIALOG_LICENSE = LGPL-2.1
DIALOG_LICENSE_FILES = COPYING

ifneq ($(BR2_ENABLE_LOCALE),y)
DIALOG_DEPENDENCIES += libiconv
endif

DIALOG_CONF_OPTS += NCURSES_CONFIG=$(STAGING_DIR)/usr/bin/$(NCURSES_CONFIG_SCRIPTS)

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
