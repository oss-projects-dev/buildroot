ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# iperf
#
#############################################################

IPERF_VERSION = 2.2.1
IPERF_SOURCE = iperf-$(IPERF_VERSION).tar.gz
IPERF_SITE = https://downloads.sourceforge.net/project/iperf2
IPERF_CUSTOM_PATCH_DIR = astlinux

IPERF_CONF_OPTS = \
	--disable-dependency-tracking

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# iperf
#
################################################################################

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
