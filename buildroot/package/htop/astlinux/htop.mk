#############################################################
#
# htop
#
#############################################################

HTOP_VERSION = 3.5.3
HTOP_SOURCE = htop-$(HTOP_VERSION).tar.xz
HTOP_SITE = https://github.com/htop-dev/htop/releases/download/$(HTOP_VERSION)
HTOP_CUSTOM_PATCH_DIR = astlinux
HTOP_DEPENDENCIES = ncurses

# Prevent htop build system from searching the host paths
HTOP_CONF_ENV = HTOP_NCURSES_CONFIG_SCRIPT=$(STAGING_DIR)/usr/bin/$(NCURSES_CONFIG_SCRIPTS)

HTOP_CONF_OPTS = \
	--disable-static \
	--disable-unicode \
	--enable-affinity

ifeq ($(BR2_PACKAGE_LIBCAP),y)
HTOP_DEPENDENCIES += libcap
HTOP_CONF_OPTS += --enable-capabilities
else
HTOP_CONF_OPTS += --disable-capabilities
endif

ifeq ($(BR2_PACKAGE_LM_SENSORS),y)
HTOP_DEPENDENCIES += lm-sensors
HTOP_CONF_OPTS += --enable-sensors
else
HTOP_CONF_OPTS += --disable-sensors
endif

define HTOP_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/htop $(TARGET_DIR)/usr/bin/htop
endef

define HTOP_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/htop
endef

$(eval $(autotools-package))
