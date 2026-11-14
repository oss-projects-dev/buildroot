ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

################################################################################
#
# libedit
#
################################################################################

LIBEDIT_VERSION = 20260512-3.1
LIBEDIT_SITE = https://thrysoee.dk/editline
LIBEDIT_CUSTOM_PATCH_DIR = astlinux
LIBEDIT_INSTALL_STAGING = YES

LIBEDIT_DEPENDENCIES = ncurses

define LIBEDIT_INSTALL_TARGET_CMDS
	cp -a $(STAGING_DIR)/usr/lib/libedit.so* $(TARGET_DIR)/usr/lib/
endef

define LIBEDIT_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/lib/libedit.so*
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# libedit
#
################################################################################

LIBEDIT_VERSION = 20230828-3.1
LIBEDIT_SITE = https://www.thrysoee.dk/editline
LIBEDIT_INSTALL_STAGING = YES
LIBEDIT_DEPENDENCIES = ncurses
LIBEDIT_LICENSE = BSD-3-Clause
LIBEDIT_LICENSE_FILES = COPYING
LIBEDIT_CPE_ID_VALID = YES

# We're patching configure.ac
LIBEDIT_AUTORECONF = YES

# musl is ISO 10646 compliant but doesn't define __STDC_ISO_10646__,
# so let's define it manually
ifeq ($(BR2_TOOLCHAIN_USES_MUSL),y)
LIBEDIT_CONF_OPTS += CFLAGS="$(TARGET_CFLAGS) -D__STDC_ISO_10646__=201103L"
endif

# Note: libbsd required for *vis functions, but works only with a toolchain
# with __progname; otherwise, some features are disabled, as if libbsd was
# missing entirely.
ifeq ($(BR2_PACKAGE_LIBBSD),y)
LIBEDIT_DEPENDENCIES += libbsd
endif

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
