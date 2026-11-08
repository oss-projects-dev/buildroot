################################################################################
#
# unionfs
#
################################################################################

ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

include package/unionfs/astlinux/unionfs.mk

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

UNIONFS_VERSION = 2.1
UNIONFS_SITE = $(call github,rpodgorny,unionfs-fuse,v$(UNIONFS_VERSION))
UNIONFS_DEPENDENCIES = libfuse host-pkgconf
UNIONFS_LICENSE = BSD-3-Clause
UNIONFS_LICENSE_FILES = LICENSE

$(eval $(cmake-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
