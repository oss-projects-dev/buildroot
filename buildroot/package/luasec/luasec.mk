################################################################################
#
# luasec
#
################################################################################

ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

include package/luasec/astlinux/luasec.mk

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

LUASEC_VERSION = 1.3.2-1
LUASEC_SUBDIR = luasec
LUASEC_LICENSE = MIT
LUASEC_LICENSE_FILES = $(LUASEC_SUBDIR)/LICENSE
LUASEC_DEPENDENCIES = openssl

$(eval $(luarocks-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
