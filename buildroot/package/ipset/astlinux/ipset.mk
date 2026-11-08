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
