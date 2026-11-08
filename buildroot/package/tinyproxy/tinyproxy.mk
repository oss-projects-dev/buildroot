################################################################################
#
# tinyproxy
#
################################################################################

ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)
include package/tinyproxy/astlinux/tinyproxy.mk
endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

TINYPROXY_VERSION = 1.11.2
TINYPROXY_SITE = https://github.com/tinyproxy/tinyproxy/releases/download/$(TINYPROXY_VERSION)
TINYPROXY_SOURCE = tinyproxy-$(TINYPROXY_VERSION).tar.xz
TINYPROXY_LICENSE = GPL-2.0+
TINYPROXY_LICENSE_FILES = COPYING
TINYPROXY_CPE_ID_VALID = YES

# 0001-reqs-fix-integer-overflow-in-port-number-processing.patch
TINYPROXY_IGNORE_CVES += CVE-2025-63938

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
