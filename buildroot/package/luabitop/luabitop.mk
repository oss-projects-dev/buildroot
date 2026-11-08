################################################################################
#
# luabitop
#
################################################################################

ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)
include package/luabitop/astlinux/luabitop.mk
endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

LUABITOP_VERSION = 1.0.2-1
LUABITOP_NAME_UPSTREAM = LuaBitOp
LUABITOP_LICENSE = MIT
LUABITOP_LICENSE_FILES = $(LUABITOP_SUBDIR)/README

$(eval $(luarocks-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
