ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# fxload
#
#############################################################
FXLOAD_VERSION:=2008_10_13
FXLOAD_SOURCE:=fxload-$(FXLOAD_VERSION).tar.gz
FXLOAD_SITE:=http://$(BR2_SOURCEFORGE_MIRROR).dl.sourceforge.net/sourceforge/linux-hotplug/fxload/$(FXLOAD_VERSION)
FXLOAD_CUSTOM_PATCH_DIR = astlinux
#FXLOAD_DIR:=$(BUILD_DIR)/fxload-$(FXLOAD_VERSION)
#FXLOAD_CAT:=zcat
#FXLOAD_BINARY:=fxload
#FXLOAD_TARGET_BINARY:=usr/sbin/fxload
#
#$(DL_DIR)/$(FXLOAD_SOURCE):
#	$(WGET) -P $(DL_DIR) $(FXLOAD_SITE)/$(FXLOAD_SOURCE)
#
#$(FXLOAD_DIR)/.unpacked: $(DL_DIR)/$(FXLOAD_SOURCE)
#	$(FXLOAD_CAT) $(DL_DIR)/$(FXLOAD_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
#	touch $@
#
#$(FXLOAD_DIR)/$(FXLOAD_BINARY): $(FXLOAD_DIR)/.unpacked
#	$(TARGET_CONFIGURE_OPTS) $(MAKE) CC=$(TARGET_CC) -C $(FXLOAD_DIR)
#
#$(TARGET_DIR)/$(FXLOAD_TARGET_BINARY): $(FXLOAD_DIR)/$(FXLOAD_BINARY)
#	$(INSTALL) -D $(FXLOAD_DIR)/$(FXLOAD_BINARY) $(TARGET_DIR)/$(FXLOAD_TARGET_BINARY)
#
#fxload: $(TARGET_DIR)/$(FXLOAD_TARGET_BINARY)
#
#fxload-source: $(FXLOAD_DIR)/.unpacked
#
#fxload-clean:
#	rm -f $(TARGET_DIR)/$(FXLOAD_TARGET_BINARY)
#	-$(MAKE) -C $(FXLOAD_DIR) clean
#
#fxload-dirclean:
#	rm -rf $(FXLOAD_DIR)
#
##############################################################
##
## Toplevel Makefile options
##
##############################################################
#ifeq ($(strip $(BR2_PACKAGE_FXLOAD)),y)
#TARGETS+=fxload
#endif

define FXLOAD_CONFIGURE_CMDS
        @echo "No configure"
endef

define FXLOAD_BUILD_CMDS
        $(TARGET_MAKE_ENV) $(MAKE) CC=$(TARGET_CC) $(TARGET_CONFIGURE_OPTS) -C $(@D)
endef

define FXLOAD_INSTALL_TARGET_CMDS
        $(INSTALL) -D $(@D)/fxload $(TARGET_DIR)/usr/sbin/fxload
endef

$(eval $(generic-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# fxload
#
################################################################################

FXLOAD_VERSION = 2008_10_13
FXLOAD_SITE = http://downloads.sourceforge.net/project/linux-hotplug/fxload/$(FXLOAD_VERSION)
FXLOAD_LICENSE = GPL-2.0+
FXLOAD_LICENSE_FILES = COPYING

FXLOAD_CFLAGS = $(TARGET_CFLAGS)

ifeq ($(BR2_TOOLCHAIN_HAS_GCC_BUG_63261),y)
FXLOAD_CFLAGS += -O0
endif

define FXLOAD_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(FXLOAD_CFLAGS)" -C $(@D) all
endef

define FXLOAD_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) prefix=$(TARGET_DIR) -C $(@D) install
endef

$(eval $(generic-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
