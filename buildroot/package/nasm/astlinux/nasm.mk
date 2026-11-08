################################################################################
#
# nasm
#
################################################################################

NASM_VERSION = 2.14.02
NASM_SOURCE = nasm-$(NASM_VERSION).tar.xz
NASM_SITE = https://www.nasm.us/pub/nasm/releasebuilds/$(NASM_VERSION)
NASM_CUSTOM_PATCH_DIR = astlinux

$(eval $(host-autotools-package))
