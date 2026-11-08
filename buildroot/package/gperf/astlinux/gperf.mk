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
