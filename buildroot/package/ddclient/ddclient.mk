#############################################################
#
# ddclient
#
#############################################################

DDCLIENT_VERSION = 3.8.3-08
DDCLIENT_SOURCE = ddclient-curl-$(DDCLIENT_VERSION).tar.gz
DDCLIENT_SITE = https://github.com/astlinux-project/ddclient-curl/archive/$(DDCLIENT_VERSION)
DDCLIENT_CUSTOM_PATCH_DIR = astlinux

define DDCLIENT_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D package/ddclient/astlinux/dynamicdns.init $(TARGET_DIR)/etc/init.d/dynamicdns
	$(INSTALL) -m 0755 -D $(@D)/ddclient $(TARGET_DIR)/usr/sbin/ddclient
	$(INSTALL) -m 0755 -D $(@D)/contrib/get-ipv6-from-ipv4/get-ipv6-from-ipv4.pl $(TARGET_DIR)/usr/sbin/get-ipv6-from-ipv4
	$(INSTALL) -m 0644 -D package/ddclient/astlinux/ddclient.conf $(TARGET_DIR)/stat/etc/ddclient.conf
	ln -sf /tmp/etc/ddclient.conf $(TARGET_DIR)/etc/ddclient.conf
endef

define DDCLIENT_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/etc/init.d/dynamicdns
	rm -f $(TARGET_DIR)/usr/sbin/ddclient
	rm -f $(TARGET_DIR)/usr/sbin/get-ipv6-from-ipv4
	rm -f $(TARGET_DIR)/stat/etc/ddclient.conf
endef

$(eval $(generic-package))
