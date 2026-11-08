ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# nano
#
#############################################################

NANO_VERSION = 2.7.5
NANO_SITE = http://www.nano-editor.org/dist/v2.7
NANO_CUSTOM_PATCH_DIR = astlinux
NANO_MAKE_ENV = CURSES_LIB="-lncurses"
NANO_CONF_ENV = ac_cv_prog_NCURSESW_CONFIG=false
NANO_CONF_OPTS = \
	--without-slang \
	--disable-utf8 \
	--enable-tiny

NANO_DEPENDENCIES = ncurses

ifeq ($(BR2_PACKAGE_FILE),y)
	NANO_DEPENDENCIES += file
else
	NANO_CONF_ENV += ac_cv_lib_magic_magic_open=no
endif

define NANO_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 $(@D)/src/nano $(TARGET_DIR)/usr/bin/nano
endef

define NANO_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/nano
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# nano
#
################################################################################

NANO_VERSION_MAJOR = 8
NANO_VERSION = $(NANO_VERSION_MAJOR).2
NANO_SITE = https://www.nano-editor.org/dist/v$(NANO_VERSION_MAJOR)
NANO_SOURCE = nano-$(NANO_VERSION).tar.xz
NANO_LICENSE = GPL-3.0+
NANO_LICENSE_FILES = COPYING
NANO_DEPENDENCIES = ncurses

NANO_CPE_ID_VENDOR = gnu

ifeq ($(BR2_PACKAGE_NCURSES_WCHAR),y)
NANO_CONF_ENV += ac_cv_prog_NCURSESW_CONFIG=$(STAGING_DIR)/usr/bin/$(NCURSES_CONFIG_SCRIPTS)
else
NANO_CONF_ENV += ac_cv_prog_NCURSESW_CONFIG=false
NANO_MAKE_ENV += CURSES_LIB="-lncurses"
endif

ifeq ($(BR2_PACKAGE_NANO_TINY),y)
NANO_CONF_OPTS += \
	--enable-tiny \
	--disable-libmagic \
	--disable-color \
	--disable-nanorc
define NANO_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 $(@D)/src/nano $(TARGET_DIR)/usr/bin/nano
endef
else
NANO_CONF_OPTS += --disable-tiny
ifeq ($(BR2_PACKAGE_FILE),y)
NANO_DEPENDENCIES += file
NANO_CONF_OPTS += --enable-libmagic --enable-color --enable-nanorc
else
NANO_CONF_OPTS += --disable-libmagic --disable-color --disable-nanorc
endif # BR2_PACKAGE_FILE
endif # BR2_PACKAGE_NANO_TINY

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
