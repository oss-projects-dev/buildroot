ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# luasec
#
#############################################################

LUASEC_VERSION = 1.3.2
LUASEC_SOURCE = luasec-$(LUASEC_VERSION).tar.gz
LUASEC_SITE = https://github.com/brunoos/luasec/archive/v$(LUASEC_VERSION)
LUASEC_CUSTOM_PATCH_DIR = astlinux
LUASEC_DEPENDENCIES = lua openssl luasocket

define LUASEC_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) linux \
		INC_PATH="" \
		LIB_PATH="" \
		LIBDIR="-L$(STAGING_DIR)/usr/lib/ -L$(@D)/src/luasocket" \
		RANLIB="$(TARGET_RANLIB)" \
		AR="$(TARGET_AR)" \
		CC="$(TARGET_CC) -std=gnu99" \
		LD="$(TARGET_LD) -shared"
endef

define LUASEC_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) install \
		LUACPATH="$(TARGET_DIR)/usr/lib/lua" \
		LUAPATH="$(TARGET_DIR)/usr/share/lua"
endef

define LUASEC_UNINSTALL_TARGET_CMDS
	rm -rf "$(TARGET_DIR)/usr/share/lua/ssl"
	rm -f "$(TARGET_DIR)/usr/share/lua/ssl.lua"
	rm -f "$(TARGET_DIR)/usr/lib/lua/ssl.so"
endef

define LUASEC_CLEAN_CMDS
	$(MAKE) -C $(@D) -f makefile clean
endef

$(eval $(generic-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# luasec
#
################################################################################

LUASEC_VERSION = 1.3.2-1
LUASEC_SUBDIR = luasec
LUASEC_LICENSE = MIT
LUASEC_LICENSE_FILES = $(LUASEC_SUBDIR)/LICENSE
LUASEC_DEPENDENCIES = openssl

$(eval $(luarocks-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
