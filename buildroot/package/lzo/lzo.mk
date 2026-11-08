ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# lzo
#
#############################################################
LZO_VERSION = 2.09
LZO_SITE = http://www.oberhumer.com/opensource/lzo/download
LZO_CUSTOM_PATCH_DIR = astlinux
LZO_INSTALL_STAGING = YES

# Ships a beta libtool version hence our patch doesn't apply.
# Run autoreconf to regenerate ltmain.sh.
LZO_AUTORECONF = YES

$(eval $(autotools-package))
$(eval $(host-autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# lzo
#
################################################################################

LZO_VERSION = 2.10
LZO_SITE = http://www.oberhumer.com/opensource/lzo/download
LZO_LICENSE = GPL-2.0+
LZO_LICENSE_FILES = COPYING
LZO_CPE_ID_VALID = YES
LZO_INSTALL_STAGING = YES
LZO_SUPPORTS_IN_SOURCE_BUILD = NO

ifeq ($(BR2_SHARED_LIBS)$(BR2_SHARED_STATIC_LIBS),y)
LZO_CONF_OPTS += -DENABLE_SHARED=ON
else
LZO_CONF_OPTS += -DENABLE_SHARED=OFF
endif

ifeq ($(BR2_STATIC_LIBS)$(BR2_SHARED_STATIC_LIBS),y)
LZO_CONF_OPTS += -DENABLE_STATIC=ON
else
LZO_CONF_OPTS += -DENABLE_STATIC=OFF
endif

HOST_LZO_CONF_OPTS += -DENABLE_SHARED=ON -DENABLE_STATIC=OFF

$(eval $(cmake-package))
$(eval $(host-cmake-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
