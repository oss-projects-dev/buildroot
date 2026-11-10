ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# slang
#
#############################################################
SLANG_VERSION = 1.4.5
SLANG_SOURCE = slang-$(SLANG_VERSION)-mini.tar.bz2
SLANG_SITE = http://www.uclibc.org
SLANG_CUSTOM_PATCH_DIR = astlinux
SLANG_INSTALL_STAGING = YES

# We need to add -fPIC since we're busting original CFLAGS
# that have it, see bug #3295
define SLANG_BUILD_CMDS
	$(MAKE1) CC="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS) -fPIC" \
	LDFLAGS="$(TARGET_LDFLAGS)" -C $(@D)
endef

define SLANG_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0644 $(@D)/libslang.a $(STAGING_DIR)/usr/lib/libslang.a
	$(INSTALL) -D -m 0755 $(@D)/libslang.so $(STAGING_DIR)/usr/lib/libslang.so
	$(INSTALL) -D -m 0644 $(@D)/slang.h $(STAGING_DIR)/usr/include/slang.h
	$(INSTALL) -D -m 0644 $(@D)/slcurses.h $(STAGING_DIR)/usr/include/slcurses.h
	(cd $(STAGING_DIR)/usr/lib; ln -fs libslang.so libslang.so.1)
endef

define SLANG_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/libslang.a $(TARGET_DIR)/usr/lib/libslang.a
	$(INSTALL) -D -m 0755 $(@D)/libslang.so $(TARGET_DIR)/usr/lib/libslang.so
	$(INSTALL) -D -m 0644 $(@D)/slang.h $(TARGET_DIR)/usr/include/slang.h
	$(INSTALL) -D -m 0644 $(@D)/slcurses.h $(TARGET_DIR)/usr/include/slcurses.h
	(cd $(TARGET_DIR)/usr/lib; ln -fs libslang.so libslang.so.1)
endef

define SLANG_UNINSTALL_STAGING_CMDS
	rm -f $(STAGING_DIR)/usr/lib/libslang.a
	rm -f $(STAGING_DIR)/usr/lib/libslang.so
	rm -f $(STAGING_DIR)/usr/lib/libslang.so.1
	rm -f $(STAGING_DIR)/usr/include/slang.h
	rm -f $(STAGING_DIR)/usr/include/slcurses.h
endef

define SLANG_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/lib/libslang.a
	rm -f $(TARGET_DIR)/usr/lib/libslang.so
	rm -f $(TARGET_DIR)/usr/lib/libslang.so.1
	rm -f $(TARGET_DIR)/usr/include/slang.h
	rm -f $(TARGET_DIR)/usr/include/slcurses.h
endef

define SLANG_CLEAN_CMDS
	$(MAKE) -C $(@D) clean
endef

$(eval $(generic-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# slang
#
################################################################################

SLANG_VERSION = 2.3.3
SLANG_SOURCE = slang-$(SLANG_VERSION).tar.bz2
SLANG_SITE = http://www.jedsoft.org/releases/slang
SLANG_LICENSE = GPL-2.0+
SLANG_LICENSE_FILES = COPYING
SLANG_INSTALL_STAGING = YES
SLANG_CONF_OPTS = --with-onig=no
SLANG_MAKE = $(MAKE1)

# Racy and we don't have/do libtermcap
define SLANG_DISABLE_TERMCAP
	$(SED) '/^TERMCAP=/s:=.*:=:' $(@D)/configure
endef
SLANG_POST_PATCH_HOOKS += SLANG_DISABLE_TERMCAP

# Absolute path hell, sigh...
ifeq ($(BR2_PACKAGE_LIBPNG),y)
SLANG_CONF_OPTS += --with-png=$(STAGING_DIR)/usr
SLANG_DEPENDENCIES += libpng
else
SLANG_CONF_OPTS += --with-png=no
endif
ifeq ($(BR2_PACKAGE_PCRE),y)
SLANG_CONF_OPTS += --with-pcre=$(STAGING_DIR)/usr
SLANG_DEPENDENCIES += pcre
else
SLANG_CONF_OPTS += --with-pcre=no
endif
ifeq ($(BR2_PACKAGE_ZLIB),y)
SLANG_CONF_OPTS += --with-z=$(STAGING_DIR)/usr
SLANG_DEPENDENCIES += zlib
else
SLANG_CONF_OPTS += --with-z=no
endif

ifeq ($(BR2_PACKAGE_NCURSES),y)
SLANG_DEPENDENCIES += ncurses
SLANG_CONF_ENV += ac_cv_path_nc5config=$(STAGING_DIR)/usr/bin/$(NCURSES_CONFIG_SCRIPTS)
else
SLANG_CONF_OPTS += ac_cv_path_nc5config=no
endif

ifeq ($(BR2_PACKAGE_READLINE),y)
SLANG_CONF_OPTS += --with-readline=gnu
SLANG_DEPENDENCIES += readline
ifeq ($(BR2_STATIC_LIBS),y)
SLANG_CONF_ENV += LIBS="`$(STAGING_DIR)/usr/bin/$(NCURSES_CONFIG_SCRIPTS) --libs`"
endif
endif

ifeq ($(BR2_STATIC_LIBS),y)
SLANG_MAKE_OPTS = static
SLANG_INSTALL_STAGING_OPTS = DESTDIR=$(STAGING_DIR) install-static
SLANG_INSTALL_TARGET_OPTS = DESTDIR=$(TARGET_DIR) install-static
endif

ifeq ($(BR2_PACKAGE_SLANG_SLSH),)
define SLANG_REMOVE_SLSH
	rm -rf $(TARGET_DIR)/etc/slsh.rc \
		$(TARGET_DIR)/usr/share/slsh \
		$(TARGET_DIR)/usr/bin/slsh
endef
SLANG_POST_INSTALL_TARGET_HOOKS += SLANG_REMOVE_SLSH
endif

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
