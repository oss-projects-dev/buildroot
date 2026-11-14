ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

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

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# ethtool
#
################################################################################

ETHTOOL_VERSION = 6.14
ETHTOOL_SOURCE = ethtool-$(ETHTOOL_VERSION).tar.xz
ETHTOOL_SITE = $(BR2_KERNEL_MIRROR)/software/network/ethtool
ETHTOOL_LICENSE = GPL-2.0
ETHTOOL_LICENSE_FILES = LICENSE COPYING
ETHTOOL_CPE_ID_VENDOR = kernel
ETHTOOL_CONF_OPTS = \
	$(if $(BR2_PACKAGE_ETHTOOL_PRETTY_PRINT),--enable-pretty-dump,--disable-pretty-dump)

ifeq ($(BR2_PACKAGE_LIBMNL),y)
ETHTOOL_DEPENDENCIES += host-pkgconf libmnl
ETHTOOL_CONF_OPTS += --enable-netlink
else
ETHTOOL_CONF_OPTS += --disable-netlink
endif

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
