ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# genext2fs
#
#############################################################

GENEXT2FS_VERSION=1.4.1
GENEXT2FS_SOURCE=genext2fs-$(GENEXT2FS_VERSION).tar.gz
GENEXT2FS_SITE:=http://$(BR2_SOURCEFORGE_MIRROR).dl.sourceforge.net/sourceforge/genext2fs

$(eval $(autotools-package))
$(eval $(host-autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# genext2fs
#
################################################################################

GENEXT2FS_VERSION = 1.5.0
GENEXT2FS_SITE = $(call github,bestouff,genext2fs,v$(GENEXT2FS_VERSION))
GENEXT2FS_LICENSE = GPL-2.0
GENEXT2FS_LICENSE_FILES = COPYING
# From git
GENEXT2FS_AUTORECONF = YES

$(eval $(autotools-package))
$(eval $(host-autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
