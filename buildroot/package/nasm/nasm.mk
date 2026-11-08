################################################################################
#
# nasm
#
################################################################################

ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)
include package/nasm/astlinux/nasm.mk
endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

NASM_VERSION = 2.16.03
NASM_SOURCE = nasm-$(NASM_VERSION).tar.xz
NASM_SITE = https://www.nasm.us/pub/nasm/releasebuilds/$(NASM_VERSION)
NASM_LICENSE = BSD-2-Clause
NASM_LICENSE_FILES = LICENSE
NASM_CPE_ID_VENDOR = nasm
NASM_CPE_ID_PRODUCT = netwide_assembler

$(eval $(host-autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
