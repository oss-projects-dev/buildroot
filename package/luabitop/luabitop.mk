ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# luabitop
#
#############################################################

LUABITOP_VERSION = 1.0.2
LUABITOP_SOURCE = LuaBitOp-$(LUABITOP_VERSION).tar.gz
LUABITOP_SITE = https://bitop.luajit.org/download
LUABITOP_CUSTOM_PATCH_DIR = astlinux
LUABITOP_DEPENDENCIES = lua

LUABITOP_MFLAGS += CC="$(TARGET_CC)"
LUABITOP_MFLAGS += INCLUDES="-I$(STAGING_DIR)/usr/include"
LUABITOP_MFLAGS += CFLAGS="$(TARGET_CFLAGS)"
LUABITOP_MFLAGS += LDFLAGS="$(TARGET_LDFLAGS)"

define LUABITOP_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) $(LUABITOP_MFLAGS)
endef

define LUABITOP_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(@D)/bit.so $(TARGET_DIR)/usr/lib/lua/bit.so
endef

define LUABITOP_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/lib/lua/bit.so
endef

define LUABITOP_CLEAN_CMDS
	$(MAKE) -C $(@D) clean
endef

$(eval $(generic-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# luabitop
#
################################################################################

LUABITOP_VERSION = 1.0.2-1
LUABITOP_NAME_UPSTREAM = LuaBitOp
LUABITOP_LICENSE = MIT
LUABITOP_LICENSE_FILES = $(LUABITOP_SUBDIR)/README

$(eval $(luarocks-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
