################################################################################
#
# iperf
#
################################################################################

ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

include package/iperf/astlinux/iperf.mk

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

IPERF_VERSION = 2.2.1
IPERF_SITE = https://downloads.sourceforge.net/project/iperf2
IPERF_LICENSE = MIT-like
IPERF_LICENSE_FILES = COPYING
IPERF_CPE_ID_VENDOR = iperf2_project
IPERF_CPE_ID_PRODUCT = iperf2

IPERF_CONF_OPTS = \
	--disable-web100

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
