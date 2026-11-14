ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# dahdi-linux
#
##############################################################
DAHDI_LINUX_VERSION := 3.4.0
DAHDI_LINUX_SOURCE := dahdi-linux-$(DAHDI_LINUX_VERSION).tar.gz
DAHDI_LINUX_SITE := https://downloads.asterisk.org/pub/telephony/dahdi-linux/releases
DAHDI_LINUX_CUSTOM_PATCH_DIR = astlinux/patches
DAHDI_LINUX_DIR := $(BUILD_DIR)/dahdi-linux-$(DAHDI_LINUX_VERSION)
DAHDI_LINUX_DRIVERS_DIR := $(DAHDI_LINUX_DIR)/drivers/dahdi
DAHDI_LINUX_BINARY := dahdi.ko
DAHDI_LINUX_TARGET_BINARY := usr/share/dahdi/XppConfig.pm
PERLLIBDIR := /usr/local/share/perl
DAHDI_LINUX_PREREQS := linux libusb libusb-compat udev
DAHDI_LINUX_CONFIGURE_ARGS :=
DEPMOD := $(HOST_DIR)/sbin/depmod

DAHDI_LINUX_DEPENDENCIES += $(DAHDI_LINUX_PREREQS)

DAHDI_LINUX_FW_SITE = http://downloads.digium.com/pub/telephony/firmware/releases
DAHDI_LINUX_FW_FILES = \
	dahdi-fwload-vpmadt032-1.25.0.tar.gz \
	dahdi-fw-oct6114-032-1.05.01.tar.gz \
	dahdi-fw-oct6114-064-1.05.01.tar.gz \
	dahdi-fw-oct6114-128-1.05.01.tar.gz \
	dahdi-fw-oct6114-256-1.05.01.tar.gz \
	dahdi-fw-tc400m-MR6.12.tar.gz \
	dahdi-fw-hx8-2.06.tar.gz \
	dahdi-fw-vpmoct032-1.12.0.tar.gz \
	dahdi-fw-te820-1.76.tar.gz \
	dahdi-fw-te133-7a001e.tar.gz \
	dahdi-fw-te134-780017.tar.gz \
	dahdi-fw-a8b-1f001e.tar.gz \
	dahdi-fw-a8a-1d0017.tar.gz \
	dahdi-fw-a4b-d001e.tar.gz \
	dahdi-fw-a4a-a0017.tar.gz \
	dahdi-fw-te435-13001e.tar.gz \
	dahdi-fw-te436-10017.tar.gz

DAHDI_LINUX_EXTRA_DOWNLOADS = \
	$(patsubst %,$(DAHDI_LINUX_FW_SITE)/%,$(DAHDI_LINUX_FW_FILES))

# $(call ndots start,end,dotted-string)
dot:=.
empty:=
space:=$(empty) $(empty)
ndots = $(subst $(space),$(dot),$(wordlist $(1),$(2),$(subst $(dot),$(space),$3)))
##
DAHDI_LINUX_VERSION_SINGLE := $(call ndots,1,1,$(DAHDI_LINUX_VERSION))
DAHDI_LINUX_VERSION_TUPLE := $(call ndots,1,2,$(DAHDI_LINUX_VERSION))

#$(DL_DIR)/$(DAHDI_LINUX_SOURCE):
#	$(WGET) -P $(DL_DIR) $(DAHDI_LINUX_SITE)/$(DAHDI_LINUX_SOURCE)

#$(DAHDI_LINUX_DIR)/.source: $(DL_DIR)/$(DAHDI_LINUX_SOURCE)  | $(DAHDI_LINUX_PREREQS)
#	zcat $(DL_DIR)/$(DAHDI_LINUX_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -

define DAHDI_LINUX_EXTRACT_FW
	$(foreach f,$(DAHDI_LINUX_FW_FILES),\
		cp $(DAHDI_LINUX_DL_DIR)/$(f) $(@D)/drivers/dahdi/firmware/$(f)$(sep))
endef
DAHDI_LINUX_POST_EXTRACT_HOOKS += DAHDI_LINUX_EXTRACT_FW

ifeq ($(strip $(BR2_PACKAGE_DAHDI_OSLEC)),y)
define DAHDI_LINUX_APPLY_DAHDI_OSLEC
	mkdir -p $(DAHDI_LINUX_DIR)/drivers/staging/echo
	cp -a $(BUILD_DIR)/linux-$(LINUX_VERSION)/drivers/misc/echo/* $(DAHDI_LINUX_DIR)/drivers/staging/echo
	$(APPLY_PATCHES) $(DAHDI_LINUX_DIR) package/dahdi-linux/astlinux/ oslec-$(DAHDI_LINUX_VERSION_TUPLE)-\*.patch
endef
DAHDI_LINUX_POST_EXTRACT_HOOKS += DAHDI_LINUX_APPLY_DAHDI_OSLEC
endif

define DAHDI_LINUX_APPLY_CUSTOM_PATCHES
	$(APPLY_PATCHES) $(DAHDI_LINUX_DIR) package/dahdi-linux/astlinux/ dahdi-linux-$(DAHDI_LINUX_VERSION_SINGLE)-\*.patch
	$(APPLY_PATCHES) $(DAHDI_LINUX_DIR) package/dahdi-linux/astlinux/ dahdi-linux-$(DAHDI_LINUX_VERSION_TUPLE)-\*.patch

endef
DAHDI_LINUX_POST_PATCH_HOOKS += DAHDI_LINUX_APPLY_CUSTOM_PATCHES

define DAHDI_LINUX_BUILD_CMDS
	$(MAKE) -C $(DAHDI_LINUX_DIR) \
		HOSTCC=gcc CC=$(TARGET_CC) LD=$(TARGET_LD) ARCH=$(NORMALIZED_ARCH) \
		KVERS=$(LINUX_VERSION_PROBED) KSRC=$(LINUX_DIR) PWD=$(DAHDI_LINUX_DIR)
endef

#$(DAHDI_LINUX_DIR)/include/dahdi/kernel.h: $(DAHDI_LINUX_DIR)/.source

define DAHDI_LINUX_INSTALL_STAGING_CMDS
	$(MAKE1) -C $(DAHDI_LINUX_DIR) \
		HOSTCC=gcc CC=$(TARGET_CC) LD=$(TARGET_LD) ARCH=$(NORMALIZED_ARCH) \
		DESTDIR=$(STAGING_DIR) KVERS=$(LINUX_VERSION_PROBED) \
		KSRC=$(LINUX_DIR) PWD=$(DAHDI_LINUX_DIR) \
		install-include
endef

define DAHDI_LINUX_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)$(PERLLIBDIR)
	$(MAKE1) -C $(DAHDI_LINUX_DIR) \
		HOSTCC=gcc CC=$(TARGET_CC) LD=$(TARGET_LD) ARCH=$(NORMALIZED_ARCH) \
		DESTDIR=$(TARGET_DIR) KVERS=$(LINUX_VERSION_PROBED) \
		KSRC=$(LINUX_DIR) PWD=$(DAHDI_LINUX_DIR) \
		PERLLIBDIR=$(PERLLIBDIR) \
		install
	rm -rf $(TARGET_DIR)/usr/include
	$(DAHDI_LINUX_INSTALL_STAGING_CMDS)
endef

ifeq ($(BR2_PACKAGE_DAHDI_NO_CARD_FIRMWARE),y)
define DAHDI_LINUX_REMOVE_FIRMWARE
	find $(TARGET_DIR)/lib/firmware/ -type f -name "*dahdi-fw-*" -print0 | xargs -0 rm -f
endef
DAHDI_LINUX_POST_INSTALL_TARGET_HOOKS += DAHDI_LINUX_REMOVE_FIRMWARE
endif

define DAHDI_LINUX_RUN_DEPMOD
	$(DEPMOD) -ae -F $(LINUX_DIR)/System.map -b $(TARGET_DIR) $(LINUX_VERSION_PROBED)
endef

DAHDI_LINUX_POST_INSTALL_TARGET_HOOKS += DAHDI_LINUX_RUN_DEPMOD


#dahdi-linux: $(TARGET_DIR)/$(DAHDI_LINUX_TARGET_BINARY) \
#       		$(STAGING_DIR)/usr/include/dahdi/kernel.h

#dahdi-linux-source: $(DAHDI_LINUX_DIR)/.source

#dahdi-linux-unpack: $(DAHDI_LINUX_DIR)/.configured

#dahdi-linux-clean:
#	rm -Rf $(STAGING_DIR)/usr/include/dahdi.h
#	rm -Rf $(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED)/dahdi
#	$(DEPMOD) -ae -F $(LINUX_DIR)/System.map -b $(TARGET_DIR) $(LINUX_VERSION_PROBED)
#	rm -f $(TARGET_DIR)/$(DAHDI_LINUX_TARGET_BINARY)

#dahdi-linux-dirclean:
#	rm -rf $(DAHDI_LINUX_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
#ifeq ($(strip $(BR2_PACKAGE_DAHDI_LINUX)),y)
#TARGETS+=dahdi-linux
#endif

$(eval $(generic-package))


endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# dahdi-linux
#
################################################################################

DAHDI_LINUX_VERSION = 3.3.0
DAHDI_LINUX_SITE = \
	http://downloads.asterisk.org/pub/telephony/dahdi-linux/releases

# We need to download all those firmware blobs ourselves, otherwise
# dahdi-linux will try to download them at install time.
DAHDI_LINUX_FW_SITE = http://downloads.digium.com/pub/telephony/firmware/releases
DAHDI_LINUX_FW_FILES = \
	dahdi-fwload-vpmadt032-1.25.0.tar.gz \
	dahdi-fw-oct6114-032-1.05.01.tar.gz \
	dahdi-fw-oct6114-064-1.05.01.tar.gz \
	dahdi-fw-oct6114-128-1.05.01.tar.gz \
	dahdi-fw-oct6114-256-1.05.01.tar.gz \
	dahdi-fw-tc400m-MR6.12.tar.gz \
	dahdi-fw-hx8-2.06.tar.gz \
	dahdi-fw-vpmoct032-1.12.0.tar.gz \
	dahdi-fw-te820-1.76.tar.gz \
	dahdi-fw-te133-7a001e.tar.gz \
	dahdi-fw-te134-780017.tar.gz \
	dahdi-fw-a8b-1f001e.tar.gz \
	dahdi-fw-a8a-1d0017.tar.gz \
	dahdi-fw-a4b-d001e.tar.gz \
	dahdi-fw-a4a-a0017.tar.gz \
	dahdi-fw-te435-13001e.tar.gz \
	dahdi-fw-te436-10017.tar.gz

DAHDI_LINUX_EXTRA_DOWNLOADS = \
	$(patsubst %,$(DAHDI_LINUX_FW_SITE)/%,$(DAHDI_LINUX_FW_FILES))

# dahdi-linux claims to be GPLv2 with parts LGPLv2.1 (not 'or later'),
# but there are the so-called firmware files (downloaded above) for
# which the license is unclear: the header claims to be GPLv2, the
# 'loader-wrapper' claims to be GPLv2, but there are two so-called
# 'firmware' binary-only .o blobs for which the license is not
# explicited, which look like they end up as part of a kernel module,
# and for which the source is nowhere to be found on the upstream site
# (they are only for x86/x86_64, but we still list them unconditionally).
DAHDI_LINUX_LICENSE = GPL-2.0, LGPL-2.1, unknown (firmware files)
DAHDI_LINUX_LICENSE_FILES = LICENSE LICENSE.LGPL

DAHDI_LINUX_INSTALL_STAGING = YES

DAHDI_LINUX_MODULE_SUBDIRS = drivers/dahdi

DAHDI_LINUX_MODULE_MAKE_OPTS = \
	KSRC=$(LINUX_DIR) \
	KVERS=$(LINUX_VERSION_PROBED) \
	DAHDI_BUILD_ALL=m \
	DAHDI_INCLUDE=$(@D)/include \
	INSTALL_MOD_DIR=dahdi

define DAHDI_LINUX_EXTRACT_FW
	$(foreach f,$(DAHDI_LINUX_FW_FILES),\
		cp $(DAHDI_LINUX_DL_DIR)/$(f) $(@D)/drivers/dahdi/firmware/$(f)$(sep))
endef
DAHDI_LINUX_POST_EXTRACT_HOOKS += DAHDI_LINUX_EXTRACT_FW

define DAHDI_LINUX_LINUX_CONFIG_FIXUPS
	$(call KCONFIG_ENABLE_OPT,CONFIG_CRC_CCITT)
endef

# Need to pass the same options as for building the modules, because
# it wants to scan Linux' .config file to check whether some options
# are set or not (like CONFIG_FW_LOADER).
define DAHDI_LINUX_CONFIGURE_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) \
		$(DAHDI_LINUX_MODULE_MAKE_OPTS) \
		prereq
endef

define DAHDI_LINUX_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) \
		$(DAHDI_LINUX_MODULE_MAKE_OPTS) \
		DESTDIR=$(STAGING_DIR) \
		install-include
endef

define DAHDI_LINUX_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) \
		$(DAHDI_LINUX_MODULE_MAKE_OPTS) \
		DESTDIR=$(TARGET_DIR) \
		install-firmware \
		install-xpp-firm
endef

$(eval $(kernel-module))
$(eval $(generic-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
