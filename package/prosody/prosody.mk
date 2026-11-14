ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# prosody
#
#############################################################

PROSODY_VERSION = 0.11.14
PROSODY_SOURCE = prosody-$(PROSODY_VERSION).tar.gz
PROSODY_SITE = https://prosody.im/downloads/source
PROSODY_CUSTOM_PATCH_DIR = astlinux
PROSODY_DEPENDENCIES = lua libidn openssl luafilesystem luaexpat luasocket luasec

define PROSODY_CONFIGURE_CMDS
	# this is *NOT* GNU autoconf stuff
        (cd $(@D); \
                ./configure \
		--prefix=/usr \
		--with-lua-bin="$(HOST_DIR)/bin" \
		--with-lua="$(STAGING_DIR)/usr" \
		--with-lua-include="$(STAGING_DIR)/usr/include" \
		--with-lua-lib="$(STAGING_DIR)/usr/lib" \
		--cflags="$(TARGET_CFLAGS) -fPIC -std=gnu99" \
		--ldflags="$(TARGET_LDFLAGS) -shared" \
		--datadir="/etc/prosody/data" \
		--c-compiler='$(TARGET_CC)' \
		--linker='$(TARGET_CC)' \
		--no-example-certs \
        )
endef

define PROSODY_POST_INSTALL
	mkdir -p $(TARGET_DIR)/stat/etc/prosody
	cp $(TARGET_DIR)/etc/prosody/prosody.cfg.lua $(TARGET_DIR)/stat/etc/prosody/prosody.cfg.lua
	rm -rf $(TARGET_DIR)/etc/prosody
	$(INSTALL) -m 0644 -D package/prosody/astlinux/modules/mod_listusers.lua $(TARGET_DIR)/usr/lib/prosody/modules/
	$(INSTALL) -m 0644 -D package/prosody/astlinux/modules/mod_log_auth.lua $(TARGET_DIR)/usr/lib/prosody/modules/
	$(INSTALL) -m 0644 -D package/prosody/astlinux/modules/mod_pinger.lua $(TARGET_DIR)/usr/lib/prosody/modules/
	$(INSTALL) -m 0755 -D package/prosody/astlinux/prosody.init $(TARGET_DIR)/etc/init.d/prosody
	$(INSTALL) -m 0644 -D package/prosody/astlinux/prosody.logrotate $(TARGET_DIR)/etc/logrotate.d/prosody
	$(INSTALL) -m 0755 -D package/prosody/astlinux/prosodycmd $(TARGET_DIR)/usr/bin/prosodycmd
	ln -s /tmp/etc/prosody $(TARGET_DIR)/etc/prosody
	ln -sf ../../init.d/prosody $(TARGET_DIR)/etc/runlevels/default/S58prosody
	ln -sf ../../init.d/prosody $(TARGET_DIR)/etc/runlevels/default/K02prosody
endef

PROSODY_POST_INSTALL_TARGET_HOOKS = PROSODY_POST_INSTALL

PROSODY_UNINSTALL_STAGING_OPTS = --version

define PROSODY_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/prosody
	rm -f $(TARGET_DIR)/usr/bin/prosodyctl
	rm -f $(TARGET_DIR)/usr/bin/prosodycmd
	rm -rf $(TARGET_DIR)/usr/lib/prosody
	rm -rf $(TARGET_DIR)/stat/etc/prosody
	rm -f $(TARGET_DIR)/etc/prosody
	rm -f $(TARGET_DIR)/etc/init.d/prosody
	rm -f $(TARGET_DIR)/etc/runlevels/default/S58prosody
	rm -f $(TARGET_DIR)/etc/runlevels/default/K02prosody
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# prosody
#
################################################################################

PROSODY_VERSION = 0.11.14
PROSODY_SITE = https://prosody.im/downloads/source
PROSODY_LICENSE = MIT
PROSODY_LICENSE_FILES = COPYING
PROSODY_CPE_ID_VENDOR = prosody
PROSODY_DEPENDENCIES = host-luainterpreter luainterpreter libidn openssl

PROSODY_CFLAGS = $(TARGET_CFLAGS) -fPIC -std=c99 \
	$(if BR2_TOOLCHAIN_USES_MUSL,-DWITHOUT_MALLINFO)

PROSODY_CONF_OPTS = \
	--with-lua-bin=$(HOST_DIR)/bin \
	--with-lua=$(STAGING_DIR)/usr \
	--lua-version=$(LUAINTERPRETER_ABIVER) \
	--c-compiler=$(TARGET_CC) \
	--cflags="$(PROSODY_CFLAGS)" \
	--linker=$(TARGET_CC) \
	--ldflags="$(TARGET_LDFLAGS) -shared" \
	--sysconfdir=/etc/prosody \
	--prefix=/usr

ifeq ($(BR2_PACKAGE_LUAJIT),y)
PROSODY_CONF_OPTS += --runwith=luajit
endif

define PROSODY_CONFIGURE_CMDS
	cd $(@D) && \
		$(TARGET_CONFIGURE_OPTS) \
		./configure $(PROSODY_CONF_OPTS)
endef

define PROSODY_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define PROSODY_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) DESTDIR="$(TARGET_DIR)" -C $(@D) install
endef

define PROSODY_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 package/prosody/S50prosody \
		$(TARGET_DIR)/etc/init.d/S50prosody
endef

define PROSODY_USERS
	prosody -1 prosody -1 * - - - Prosody user
endef

# make install installs a Makefile and meta data to generate certs
define PROSODY_REMOVE_CERT_GENERATOR
	rm -f $(TARGET_DIR)/etc/prosody/certs/Makefile
	rm -f $(TARGET_DIR)/etc/prosody/certs/*.cnf
endef

PROSODY_POST_INSTALL_TARGET_HOOKS += PROSODY_REMOVE_CERT_GENERATOR

$(eval $(generic-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
