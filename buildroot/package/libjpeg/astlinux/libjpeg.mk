#############################################################
#
# jpeg (libjpeg)
#
#############################################################

LIBJPEG_VERSION = 10
LIBJPEG_SITE = https://www.ijg.org/files
LIBJPEG_CUSTOM_PATCH_DIR = astlinux
LIBJPEG_SOURCE = jpegsrc.v$(LIBJPEG_VERSION).tar.gz
LIBJPEG_INSTALL_STAGING = YES

define LIBJPEG_REMOVE_USELESS_TOOLS
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,cjpeg djpeg jpegtrans rdjpgcom wrjpgcom)
endef

LIBJPEG_POST_INSTALL_TARGET_HOOKS += LIBJPEG_REMOVE_USELESS_TOOLS

$(eval $(autotools-package))
