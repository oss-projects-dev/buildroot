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
