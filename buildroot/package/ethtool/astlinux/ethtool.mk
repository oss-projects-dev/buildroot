#############################################################
#
# ethtool
#
#############################################################

ETHTOOL_VERSION = 6.19
ETHTOOL_SITE = $(BR2_KERNEL_MIRROR)/software/network/ethtool
ETHTOOL_CUSTOM_PATCH_DIR = astlinux

ETHTOOL_DEPENDENCIES = host-pkgconf

ETHTOOL_CONF_OPTS = \
	--without-bash-completion-dir \
	--disable-pretty-dump

ifeq ($(BR2_PACKAGE_LIBMNL),y)
ETHTOOL_DEPENDENCIES += host-pkgconf libmnl
ETHTOOL_CONF_OPTS += --enable-netlink
else
ETHTOOL_CONF_OPTS += --disable-netlink
endif

$(eval $(autotools-package))
