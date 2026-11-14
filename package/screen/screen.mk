ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# screen
#
#############################################################

SCREEN_VERSION = 5.0.2
SCREEN_SITE = $(BR2_GNU_MIRROR)/screen
SCREEN_CUSTOM_PATCH_DIR = astlinux
SCREEN_DEPENDENCIES = ncurses
SCREEN_AUTORECONF = YES
SCREEN_CONF_ENV = CFLAGS="$(TARGET_CFLAGS)"
SCREEN_INSTALL_TARGET_OPTS = DESTDIR=$(TARGET_DIR) SCREEN=screen install_bin

SCREEN_CONF_OPTS = \
	--disable-pam

define SCREEN_INSTALL_SCREENRC
	$(INSTALL) -m 0644 -D $(@D)/etc/screenrc $(TARGET_DIR)/etc/screenrc
endef

SCREEN_POST_INSTALL_TARGET_HOOKS += SCREEN_INSTALL_SCREENRC

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# screen
#
################################################################################

SCREEN_VERSION = 5.0.2
SCREEN_SITE = $(BR2_GNU_MIRROR)/screen
SCREEN_LICENSE = GPL-3.0+
SCREEN_LICENSE_FILES = COPYING
SCREEN_CPE_ID_VENDOR = gnu
SCREEN_SELINUX_MODULES = screen
SCREEN_DEPENDENCIES = ncurses
SCREEN_AUTORECONF = YES
SCREEN_CONF_ENV = CFLAGS="$(TARGET_CFLAGS)"
SCREEN_CONF_OPTS = --enable-colors256 --enable-socket-dir
SCREEN_INSTALL_TARGET_OPTS = DESTDIR=$(TARGET_DIR) SCREEN=screen install_bin

ifeq ($(BR2_PACKAGE_LIBXCRYPT),y)
SCREEN_DEPENDENCIES += libxcrypt
endif

ifeq ($(BR2_PACKAGE_LINUX_PAM),y)
SCREEN_DEPENDENCIES += linux-pam
SCREEN_CONF_OPTS += --enable-pam
else
SCREEN_CONF_OPTS += --disable-pam
endif

define SCREEN_INSTALL_SCREENRC
	$(INSTALL) -m 0644 -D $(@D)/etc/screenrc $(TARGET_DIR)/etc/screenrc
endef
SCREEN_POST_INSTALL_TARGET_HOOKS += SCREEN_INSTALL_SCREENRC

# Add /usr/bin/screen to /etc/shells otherwise some login tools like dropbear
# can reject the user connection. See man shells.
define SCREEN_ADD_SCREEN_TO_SHELLS
	grep -qsE '^/usr/bin/screen$$' $(TARGET_DIR)/etc/shells \
		|| echo "/usr/bin/screen" >> $(TARGET_DIR)/etc/shells
endef
SCREEN_TARGET_FINALIZE_HOOKS += SCREEN_ADD_SCREEN_TO_SHELLS

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
