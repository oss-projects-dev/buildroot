################################################################################
#
# liburiparser
#
################################################################################

ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)
include package/liburiparser/astlinux/liburiparser.mk
endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

LIBURIPARSER_VERSION = 1.0.2
LIBURIPARSER_SOURCE = uriparser-$(LIBURIPARSER_VERSION).tar.xz
LIBURIPARSER_SITE = https://github.com/uriparser/uriparser/releases/download/uriparser-$(LIBURIPARSER_VERSION)
LIBURIPARSER_LICENSE = BSD-3-Clause
LIBURIPARSER_LICENSE_FILES = COPYING.BSD-3-Clause
LIBURIPARSER_CPE_ID_VENDOR = uriparser_project
LIBURIPARSER_CPE_ID_PRODUCT = uriparser
LIBURIPARSER_INSTALL_STAGING = YES
LIBURIPARSER_CONF_OPTS = -DURIPARSER_BUILD_DOCS=OFF -DURIPARSER_BUILD_TESTS=OFF

ifeq ($(BR2_SHARED_LIBS)$(BR2_SHARED_STATIC_LIBS),y)
LIBURIPARSER_CONF_OPTS += -DBUILD_SHARED_LIBS=ON
else
LIBURIPARSER_CONF_OPTS += -DBUILD_SHARED_LIBS=OFF
endif

ifeq ($(BR2_USE_WCHAR),)
LIBURIPARSER_CONF_OPTS += -DURIPARSER_BUILD_WCHAR_T=OFF
endif

$(eval $(cmake-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
