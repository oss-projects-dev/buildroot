ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# PCRE
#
#############################################################

PCRE_VERSION = 8.45
PCRE_SITE = https://downloads.sourceforge.net/project/pcre/pcre/$(PCRE_VERSION)
PCRE_CUSTOM_PATCH_DIR = astlinux
PCRE_SOURCE = pcre-$(PCRE_VERSION).tar.bz2
PCRE_INSTALL_STAGING = YES

ifneq ($(BR2_INSTALL_LIBSTDCPP),y)
# pcre will use the host g++ if a cross version isn't available
PCRE_CONF_OPTS = --disable-cpp
endif

PCRE_CONF_OPTS += --enable-pcre8
PCRE_CONF_OPTS += --disable-pcre16
PCRE_CONF_OPTS += --disable-pcre32
PCRE_CONF_OPTS += --disable-utf
PCRE_CONF_OPTS += --disable-unicode-properties

define PCRE_STAGING_PCRE_CONFIG_FIXUP
	$(SED) 's,^prefix=.*,prefix=$(STAGING_DIR)/usr,' \
		-e 's,^exec_prefix=.*,exec_prefix=$(STAGING_DIR)/usr,' \
		$(STAGING_DIR)/usr/bin/pcre-config
endef
PCRE_POST_INSTALL_STAGING_HOOKS += PCRE_STAGING_PCRE_CONFIG_FIXUP

define PCRE_TARGET_REMOVE_PCRE_CONFIG
	rm -f $(TARGET_DIR)/usr/bin/pcre-config
	rm -f $(TARGET_DIR)/usr/bin/pcretest
endef
PCRE_POST_INSTALL_TARGET_HOOKS += PCRE_TARGET_REMOVE_PCRE_CONFIG

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# pcre
#
################################################################################

PCRE_VERSION = 8.45
PCRE_SITE = http://downloads.sourceforge.net/project/pcre/pcre/$(PCRE_VERSION)
PCRE_SOURCE = pcre-$(PCRE_VERSION).tar.bz2
PCRE_LICENSE = BSD-3-Clause
PCRE_LICENSE_FILES = LICENCE
PCRE_CPE_ID_VENDOR = pcre
PCRE_INSTALL_STAGING = YES
PCRE_CONFIG_SCRIPTS = pcre-config

# They're required for host-libglib2
HOST_PCRE_CONF_OPTS = --enable-unicode-properties

ifneq ($(BR2_INSTALL_LIBSTDCPP),y)
# pcre will use the host g++ if a cross version isn't available
PCRE_CONF_OPTS += --disable-cpp
endif

PCRE_CONF_OPTS += --enable-pcre8
PCRE_CONF_OPTS += $(if $(BR2_PACKAGE_PCRE_16),--enable-pcre16,--disable-pcre16)
PCRE_CONF_OPTS += $(if $(BR2_PACKAGE_PCRE_32),--enable-pcre32,--disable-pcre32)
PCRE_CONF_OPTS += $(if $(BR2_PACKAGE_PCRE_UTF),--enable-utf,--disable-utf)
PCRE_CONF_OPTS += $(if $(BR2_PACKAGE_PCRE_UCP),--enable-unicode-properties,--disable-unicode-properties)

$(eval $(autotools-package))
$(eval $(host-autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
