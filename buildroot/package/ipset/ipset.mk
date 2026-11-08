ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# ipset
#
#############################################################

IPSET_VERSION = 6.38
IPSET_SOURCE = ipset-$(IPSET_VERSION).tar.bz2
IPSET_SITE = http://ipset.netfilter.org
IPSET_CUSTOM_PATCH_DIR = astlinux
IPSET_DEPENDENCIES = libmnl host-pkgconf

IPSET_CONF_OPTS = \
	--disable-static \
	--with-kmod=no

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# ipset
#
################################################################################

IPSET_VERSION = 7.16
IPSET_SOURCE = ipset-$(IPSET_VERSION).tar.bz2
IPSET_SITE = http://ipset.netfilter.org
IPSET_DEPENDENCIES = libmnl host-pkgconf
IPSET_CONF_OPTS = --with-kmod=no
IPSET_LICENSE = GPL-2.0
IPSET_LICENSE_FILES = COPYING
IPSET_CPE_ID_VENDOR = netfilter
IPSET_INSTALL_STAGING = YES
IPSET_SELINUX_MODULES = iptables

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
