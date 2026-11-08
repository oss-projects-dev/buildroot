ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# gperf
#
#############################################################

GPERF_VERSION = 3.1
GPERF_SITE = $(BR2_GNU_MIRROR)/gperf
GPERF_CUSTOM_PATCH_DIR = astlinux

$(eval $(autotools-package))
$(eval $(host-autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# gperf
#
################################################################################

GPERF_VERSION = 3.1
GPERF_SITE = $(BR2_GNU_MIRROR)/gperf
GPERF_LICENSE = GPL-3.0+
GPERF_LICENSE_FILES = COPYING

$(eval $(autotools-package))
$(eval $(host-autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
