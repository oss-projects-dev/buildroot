################################################################################
#
# gperf
#
################################################################################

ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

include package/gperf/astlinux/gperf.mk

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

GPERF_VERSION = 3.1
GPERF_SITE = $(BR2_GNU_MIRROR)/gperf
GPERF_LICENSE = GPL-3.0+
GPERF_LICENSE_FILES = COPYING

$(eval $(autotools-package))
$(eval $(host-autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
