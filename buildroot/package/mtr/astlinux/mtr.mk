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
