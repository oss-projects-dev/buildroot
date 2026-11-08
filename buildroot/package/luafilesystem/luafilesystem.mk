################################################################################
#
# luafilesystem
#
################################################################################

ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

include package/luafilesystem/astlinux/luafilesystem.mk

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

LUAFILESYSTEM_VERSION = 1.8.0-1
LUAFILESYSTEM_SUBDIR = luafilesystem
LUAFILESYSTEM_LICENSE = MIT
LUAFILESYSTEM_LICENSE_FILES = $(LUAFILESYSTEM_SUBDIR)/LICENSE

$(eval $(luarocks-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
