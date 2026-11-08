ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# lua
#
#############################################################

LUA_VERSION = 5.1.5
LUA_SITE = http://www.lua.org/ftp
LUA_CUSTOM_PATCH_DIR = astlinux
LUA_INSTALL_STAGING = YES
LUA_DEPENDENCIES = host-lua

LUA_CFLAGS = -Wall -fPIC -DLUA_USE_POSIX -DLUA_USE_DLOPEN
LUA_MYLIBS += -ldl

# We never want to have host-readline and host-ncurses as dependencies
# of host-lua.
HOST_LUA_DEPENDENCIES =
HOST_LUA_CFLAGS = -Wall -fPIC -DLUA_USE_DLOPEN -DLUA_USE_POSIX
HOST_LUA_MYLIBS = -ldl
HOST_LUA_LDFLAGS = -Wl,-rpath,$(HOST_DIR)/lib

define LUA_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) \
	CC="$(TARGET_CC)" RANLIB="$(TARGET_RANLIB)" \
	CFLAGS="$(TARGET_CFLAGS) $(LUA_CFLAGS)" \
	MYLIBS="$(LUA_MYLIBS)" AR="$(TARGET_CROSS)ar rcu" \
	PKG_VERSION=$(LUA_VERSION) -C $(@D)/src all
endef

define HOST_LUA_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) \
	CFLAGS="$(HOST_LUA_CFLAGS)" \
	MYLIBS="$(HOST_LUA_MYLIBS)" \
	MYLDFLAGS="$(HOST_LUA_LDFLAGS)" \
	PKG_VERSION=$(LUA_VERSION) -C $(@D)/src all
endef

define LUA_INSTALL_STAGING_CMDS
	$(INSTALL) -m 0644 -D $(@D)/etc/lua.pc \
		$(STAGING_DIR)/usr/lib/pkgconfig/lua.pc
	$(INSTALL) -m 0755 -D $(@D)/src/lua $(STAGING_DIR)/usr/bin/lua
	$(INSTALL) -m 0755 -D $(@D)/src/luac $(STAGING_DIR)/usr/bin/luac
	$(INSTALL) -m 0755 -D $(@D)/src/liblua.so.$(LUA_VERSION) \
		$(STAGING_DIR)/usr/lib/liblua.so.$(LUA_VERSION)
	ln -sf liblua.so.$(LUA_VERSION) $(STAGING_DIR)/usr/lib/liblua.so
	$(INSTALL) -m 0644 -D $(@D)/src/liblua.a $(STAGING_DIR)/usr/lib/liblua.a
	$(INSTALL) -m 0644 -D $(@D)/src/lua.h $(STAGING_DIR)/usr/include/lua.h
	$(INSTALL) -m 0644 -D $(@D)/src/luaconf.h $(STAGING_DIR)/usr/include/luaconf.h
	$(INSTALL) -m 0644 -D $(@D)/src/lualib.h $(STAGING_DIR)/usr/include/lualib.h
	$(INSTALL) -m 0644 -D $(@D)/src/lauxlib.h $(STAGING_DIR)/usr/include/lauxlib.h
endef

ifeq ($(BR2_HAVE_DEVFILES),y)
define LUA_INSTALL_DEVFILES
	$(INSTALL) -m 0644 -D $(@D)/etc/lua.pc \
		$(TARGET_DIR)/usr/lib/pkgconfig/lua.pc
	$(INSTALL) -m 0644 -D $(@D)/src/lua.h $(TARGET_DIR)/usr/include/lua.h
	$(INSTALL) -m 0644 -D $(@D)/src/luaconf.h $(TARGET_DIR)/usr/include/luaconf.h
	$(INSTALL) -m 0644 -D $(@D)/src/lualib.h $(TARGET_DIR)/usr/include/lualib.h
	$(INSTALL) -m 0644 -D $(@D)/src/lauxlib.h $(TARGET_DIR)/usr/include/lauxlib.h
endef
endif


define LUA_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/src/lua $(TARGET_DIR)/usr/bin/lua
	$(INSTALL) -m 0755 -D $(@D)/src/luac $(TARGET_DIR)/usr/bin/luac
	$(INSTALL) -m 0755 -D $(@D)/src/liblua.so.$(LUA_VERSION) \
		$(TARGET_DIR)/usr/lib/liblua.so.$(LUA_VERSION)
	ln -sf liblua.so.$(LUA_VERSION) $(TARGET_DIR)/usr/lib/liblua.so
	$(INSTALL) -m 0644 -D $(@D)/src/liblua.a $(TARGET_DIR)/usr/lib/liblua.a
	$(LUA_INSTALL_DEVFILES)
endef

define HOST_LUA_INSTALL_CMDS
	$(INSTALL) -m 0755 -D $(@D)/src/lua $(HOST_DIR)/bin/lua
	$(INSTALL) -m 0755 -D $(@D)/src/luac $(HOST_DIR)/bin/luac
	$(INSTALL) -m 0755 -D $(@D)/src/liblua.so.$(LUA_VERSION) \
		$(HOST_DIR)/lib/liblua.so.$(LUA_VERSION)
	ln -sf liblua.so.$(LUA_VERSION) $(HOST_DIR)/lib/liblua.so
	$(INSTALL) -m 0644 -D $(@D)/src/liblua.a $(HOST_DIR)/lib/liblua.a
	$(INSTALL) -m 0644 -D $(@D)/etc/lua.pc \
		$(HOST_DIR)/lib/pkgconfig/lua.pc
	$(INSTALL) -m 0644 -D $(@D)/src/lua.h $(HOST_DIR)/include/lua.h
	$(INSTALL) -m 0644 -D $(@D)/src/luaconf.h $(HOST_DIR)/include/luaconf.h
	$(INSTALL) -m 0644 -D $(@D)/src/lualib.h $(HOST_DIR)/include/lualib.h
	$(INSTALL) -m 0644 -D $(@D)/src/lauxlib.h $(HOST_DIR)/include/lauxlib.h
endef

LUA_INSTALLED_FILES = \
	/usr/include/lua.h \
	/usr/include/luaconf.h \
	/usr/include/lualib.h \
	/usr/include/lauxlib.h \
	/usr/lib/pkgconfig/lua.pc \
	/usr/bin/lua \
	/usr/bin/luac \
	/usr/lib/liblua.a \
	/usr/lib/liblua.so*

define LUA_UNINSTALL_STAGING_CMDS
	for i in $(LUA_INSTALLED_FILES); do \
		rm -f $(STAGING_DIR)$$i; \
	done
endef

define LUA_UNINSTALL_TARGET_CMDS
	for i in $(LUA_INSTALLED_FILES); do \
		rm -f $(TARGET_DIR)$$i; \
	done
endef

define HOST_LUA_UNINSTALL_TARGET_CMDS
	for i in $(LUA_INSTALLED_FILES); do \
		rm -f $(HOST_DIR)$$i; \
	done
endef

define LUA_CLEAN_CMDS
	-$(MAKE) -C $(@D) clean
endef

define HOST_LUA_CLEAN_CMDS
	-$(MAKE) -C $(@D) clean
endef

$(eval $(generic-package))
$(eval $(host-generic-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# lua
#
################################################################################

ifeq ($(BR2_PACKAGE_LUA_5_4),y)
LUA_VERSION = 5.4.8
else ifeq ($(BR2_PACKAGE_LUA_5_3),y)
LUA_VERSION = 5.3.6
else
LUA_VERSION = 5.1.5
endif
LUA_SITE = https://www.lua.org/ftp
LUA_INSTALL_STAGING = YES
LUA_LICENSE = MIT
ifeq ($(BR2_PACKAGE_LUA_5_3)$(BR2_PACKAGE_LUA_5_4),y)
LUA_LICENSE_FILES = doc/readme.html
else
LUA_LICENSE_FILES = COPYRIGHT
endif
LUA_CPE_ID_VENDOR = lua

ifeq ($(BR2_PACKAGE_LUA_5_1),y)
# Only affect lua version 5.1.5
# 5.1.5/0003-Fix-stack-overflow-in-vararg-functions.patch
LUA_IGNORE_CVES += CVE-2014-5461
endif

LUA_PROVIDES = luainterpreter

LUA_CFLAGS = -Wall -fPIC -DLUA_USE_POSIX

ifeq ($(BR2_PACKAGE_LUA_5_4),y)
LUA_CFLAGS += -DLUA_COMPAT_5_3
else ifeq ($(BR2_PACKAGE_LUA_5_3),y)
LUA_CFLAGS += -DLUA_COMPAT_5_2
endif

ifeq ($(BR2_PACKAGE_LUA_CVT_N2S),)
LUA_CFLAGS += -DLUA_NOCVTN2S
endif

ifeq ($(BR2_PACKAGE_LUA_CVT_S2N),)
LUA_CFLAGS += -DLUA_NOCVTS2N
endif

ifeq ($(BR2_STATIC_LIBS),y)
LUA_BUILDMODE = static
else
LUA_BUILDMODE = dynamic
LUA_CFLAGS += -DLUA_USE_DLOPEN
LUA_MYLIBS += -ldl
endif

ifeq ($(BR2_PACKAGE_LUA_READLINE),y)
LUA_DEPENDENCIES += readline ncurses
LUA_MYLIBS += -lreadline -lhistory -lncurses
LUA_CFLAGS += -DLUA_USE_READLINE
else
ifeq ($(BR2_PACKAGE_LUA_LINENOISE),y)
LUA_DEPENDENCIES += linenoise
LUA_MYLIBS += -llinenoise
LUA_CFLAGS += -DLUA_USE_LINENOISE
endif
endif

ifeq ($(BR2_PACKAGE_LUA_32BITS),y)
define LUA_32BITS_LUACONF
	$(SED) 's/\/\* #define LUA_32BITS \*\//#define LUA_32BITS/' $(@D)/src/luaconf.h
endef

LUA_POST_PATCH_HOOKS += LUA_32BITS_LUACONF
endif

define HOST_LUA_LUACONF
	$(SED) 's|#define LUA_ROOT.*|#define LUA_ROOT "$(HOST_DIR)/"|' $(@D)/src/luaconf.h
endef
HOST_LUA_POST_PATCH_HOOKS += HOST_LUA_LUACONF

HOST_LUA_CFLAGS = -Wall -fPIC -DLUA_USE_DLOPEN -DLUA_USE_POSIX
ifeq ($(BR2_PACKAGE_LUA_5_3),y)
HOST_LUA_CFLAGS += -DLUA_COMPAT_5_2
endif
HOST_LUA_MYLIBS = -ldl

define LUA_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) \
	CC="$(TARGET_CC)" RANLIB="$(TARGET_RANLIB)" \
	CFLAGS="$(TARGET_CFLAGS) $(LUA_CFLAGS)" \
	MYLIBS="$(LUA_MYLIBS)" AR="$(TARGET_CROSS)ar rcu" \
	MYLDFLAGS="$(TARGET_LDFLAGS)" \
	BUILDMODE=$(LUA_BUILDMODE) \
	PKG_VERSION=$(LUA_VERSION) -C $(@D)/src all
	sed -e "s/@VERSION@/$(LUA_VERSION)/;s/@ABI@/$(LUAINTERPRETER_ABIVER)/;s/@MYLIBS@/$(LUA_MYLIBS)/" \
		package/lua/lua.pc.in > $(@D)/lua.pc
endef

define HOST_LUA_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) \
	CFLAGS="$(HOST_LUA_CFLAGS)" \
	MYLDFLAGS="$(HOST_LDFLAGS)" \
	MYLIBS="$(HOST_LUA_MYLIBS)" \
	BUILDMODE=dynamic \
	PKG_VERSION=$(LUA_VERSION) -C $(@D)/src all
	sed -e "s/@VERSION@/$(LUA_VERSION)/;s/@ABI@/$(LUAINTERPRETER_ABIVER)/;s/@MYLIBS@/$(HOST_LUA_MYLIBS)/" \
		package/lua/lua.pc.in > $(@D)/lua.pc
endef

define LUA_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) INSTALL_TOP="$(STAGING_DIR)/usr" -C $(@D) install
	$(INSTALL) -m 0644 -D $(@D)/lua.pc \
		$(STAGING_DIR)/usr/lib/pkgconfig/lua.pc
endef

define LUA_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) INSTALL_TOP="$(TARGET_DIR)/usr" -C $(@D) install
endef

define HOST_LUA_INSTALL_CMDS
	$(HOST_MAKE_ENV) $(MAKE) INSTALL_TOP="$(HOST_DIR)" -C $(@D) install
	$(INSTALL) -m 0644 -D $(@D)/lua.pc \
		$(HOST_DIR)/lib/pkgconfig/lua.pc
endef

$(eval $(generic-package))
$(eval $(host-generic-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
