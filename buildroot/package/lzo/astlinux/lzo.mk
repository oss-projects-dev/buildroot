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
