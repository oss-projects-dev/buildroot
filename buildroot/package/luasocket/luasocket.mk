################################################################################
#
# luasocket
#
################################################################################

ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

include package/luasocket/astlinux/luasocket.mk

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

LUASOCKET_VERSION = 3.1.0-1
LUASOCKET_SUBDIR = luasocket
LUASOCKET_LICENSE = MIT
LUASOCKET_LICENSE_FILES = $(LUASOCKET_SUBDIR)/LICENSE

$(eval $(luarocks-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
