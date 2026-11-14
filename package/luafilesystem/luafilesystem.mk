ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# luafilesystem
#
#############################################################

LUAFILESYSTEM_VERSION = 1.6.2
LUAFILESYSTEM_SITE = http://github.com/downloads/keplerproject/luafilesystem
LUAFILESYSTEM_CUSTOM_PATCH_DIR = astlinux
LUAFILESYSTEM_DEPENDENCIES = lua

ifeq ($(BR2_LARGEFILE),y)
LFS_CFLAGS = -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE
endif

define LUAFILESYSTEM_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) CC="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS) $(LFS_CFLAGS) -fPIC"
endef

define LUAFILESYSTEM_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(@D)/src/lfs.so $(TARGET_DIR)/usr/lib/lua/lfs.so
endef

define LUAFILESYSTEM_UNINSTALL_TARGET_CMDS
	rm -f "$(TARGET_DIR)/usr/lib/lua/lfs.so"
endef

define LUAFILESYSTEM_CLEAN_CMDS
	$(MAKE) -C $(@D) clean
endef

$(eval $(generic-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# luafilesystem
#
################################################################################

LUAFILESYSTEM_VERSION = 1.8.0-1
LUAFILESYSTEM_SUBDIR = luafilesystem
LUAFILESYSTEM_LICENSE = MIT
LUAFILESYSTEM_LICENSE_FILES = $(LUAFILESYSTEM_SUBDIR)/LICENSE

$(eval $(luarocks-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
