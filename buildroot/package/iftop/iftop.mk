################################################################################
#
# iftop
#
################################################################################

ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

include package/iftop/astlinux/iftop.mk

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

IFTOP_VERSION = 1.0pre4
IFTOP_SITE = http://www.ex-parrot.com/pdw/iftop/download
IFTOP_DEPENDENCIES = ncurses libpcap
IFTOP_LICENSE = GPL-2.0+
IFTOP_LICENSE_FILES = COPYING

IFTOP_LIBS = -lpcap
ifeq ($(BR2_STATIC_LIBS),y)
IFTOP_LIBS += `$(STAGING_DIR)/usr/bin/pcap-config --static --additional-libs`
endif
IFTOP_CONF_ENV += LIBS+="$(IFTOP_LIBS)"

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
