ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# p910nd
#
#############################################################

P910ND_VERSION = 0.97
P910ND_SOURCE:=p910nd-$(P910ND_VERSION).tar.bz2
P910ND_SITE = http://downloads.sourceforge.net/project/p910nd/p910nd/$(P910ND_VERSION)
P910ND_CUSTOM_PATCH_DIR = astlinux

P910ND_MAKE_OPTS = CC='$(TARGET_CC)' \
		  LD='$(TARGET_LD)' \
		  CFLAGS='$(TARGET_CFLAGS) $(TARGET_LDFLAGS) -DLOCKFILE_DIR=\"/var/lock\"' \
		  USE_WRAP= \
		  -C $(@D)

P910ND_UNINSTALL_STAGING_OPTS = --version

define P910ND_CONFIGURE_CMDS
        @echo "No configure"
endef

define P910ND_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/p910nd $(TARGET_DIR)/usr/sbin/p910nd
	$(INSTALL) -m 0755 -D package/p910nd/astlinux/p910nd.init $(TARGET_DIR)/etc/init.d/p910nd
	ln -sf ../../init.d/p910nd $(TARGET_DIR)/etc/runlevels/default/S63p910nd
	ln -sf ../../init.d/p910nd $(TARGET_DIR)/etc/runlevels/default/K08p910nd
endef

define P910ND_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/sbin/p910nd
	rm -f $(TARGET_DIR)/etc/init.d/p910nd
	rm -f $(TARGET_DIR)/etc/runlevels/default/S63p910nd
	rm -f $(TARGET_DIR)/etc/runlevels/default/K08p910nd
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# p910nd
#
################################################################################

P910ND_VERSION = 0.97
P910ND_SITE = $(call github,kenyapcomau,p910nd,$(P910ND_VERSION))
P910ND_LICENSE = GPL-2.0
P910ND_LICENSE_FILES = LICENSE.md

define P910ND_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)
endef

define P910ND_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/p910nd $(TARGET_DIR)/usr/sbin/p910nd
endef

$(eval $(generic-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
