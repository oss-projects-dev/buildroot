################################################################################
#
# iprange
#
################################################################################

IPRANGE_VERSION = 2.1.1
IPRANGE_SOURCE = iprange-$(IPRANGE_VERSION).tar.gz
IPRANGE_SITE = https://github.com/firehol/iprange/releases/download/v$(IPRANGE_VERSION)
IPRANGE_CUSTOM_PATCH_DIR = astlinux

# patch configure.ac
IPRANGE_AUTORECONF = YES

$(eval $(autotools-package))
