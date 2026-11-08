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
