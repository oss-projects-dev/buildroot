ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# unixodbc
#
#############################################################

UNIXODBC_VERSION = 2.3.14
UNIXODBC_SOURCE = unixODBC-$(UNIXODBC_VERSION).tar.gz
UNIXODBC_SITE = https://www.unixodbc.org
UNIXODBC_CUSTOM_PATCH_DIR = astlinux
UNIXODBC_DEPENDENCIES = host-bison host-flex libtool $(if $(BR2_PACKAGE_FLEX),flex)

UNIXODBC_INSTALL_STAGING = YES

UNIXODBC_CONF_OPTS = \
	--disable-static \
	--disable-gui \
	--disable-readline \
	--disable-editline \
	--with-pic \
	--disable-drivers

define UNIXODBC_INSTALL_TARGET_CMDS
	cp -a $(STAGING_DIR)/usr/lib/libodbc*so* $(TARGET_DIR)/usr/lib/
	$(INSTALL) -m 0755 -D package/unixodbc/astlinux/unixodbc.init $(TARGET_DIR)/etc/init.d/unixodbc
	$(INSTALL) -m 0755 -D $(STAGING_DIR)/usr/bin/isql $(TARGET_DIR)/usr/bin/isql
	$(INSTALL) -m 0755 -D $(STAGING_DIR)/usr/bin/odbcinst $(TARGET_DIR)/usr/bin/odbcinst
	ln -sf /tmp/etc/odbc.ini $(TARGET_DIR)/etc/odbc.ini
	ln -sf /tmp/etc/odbcinst.ini $(TARGET_DIR)/etc/odbcinst.ini
	ln -sf /tmp/etc/ODBCDataSources $(TARGET_DIR)/etc/ODBCDataSources
	ln -sf ../../init.d/unixodbc $(TARGET_DIR)/etc/runlevels/default/S01unixodbc
endef

define UNIXODBC_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/lib/libodbc*so*
	rm -f $(TARGET_DIR)/etc/init.d/unixodbc
	rm -f $(TARGET_DIR)/usr/bin/isql
	rm -f $(TARGET_DIR)/usr/bin/odbcinst
	rm -f $(TARGET_DIR)/etc/odbc.ini
	rm -f $(TARGET_DIR)/etc/odbcinst.ini
	rm -f $(TARGET_DIR)/etc/ODBCDataSources
	rm -f $(TARGET_DIR)/etc/runlevels/default/S01unixodbc
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# unixodbc
#
################################################################################

UNIXODBC_VERSION = 2.3.12
UNIXODBC_SOURCE = unixODBC-$(UNIXODBC_VERSION).tar.gz
UNIXODBC_SITE = http://www.unixodbc.org
UNIXODBC_INSTALL_STAGING = YES
UNIXODBC_LICENSE = LGPL-2.1+ (library), GPL-2.0+ (programs)
UNIXODBC_LICENSE_FILES = COPYING exe/COPYING
UNIXODBC_CPE_ID_VENDOR = unixodbc

UNIXODBC_CONF_OPTS = --enable-drivers --enable-driver-conf

ifeq ($(BR2_PACKAGE_LIBEDIT),y)
UNIXODBC_CONF_OPTS += --enable-editline
UNIXODBC_DEPENDENCIES += libedit
else
UNIXODBC_CONF_OPTS += --disable-editline
endif

ifeq ($(BR2_PACKAGE_LIBICONV),y)
UNIXODBC_CONF_OPTS += --enable-iconv
UNIXODBC_DEPENDENCIES += libiconv
else
UNIXODBC_CONF_OPTS += --disable-iconv
endif

ifeq ($(BR2_PACKAGE_LIBTOOL),y)
UNIXODBC_CONF_OPTS += --without-included-ltdl
UNIXODBC_DEPENDENCIES += libtool
else
UNIXODBC_CONF_OPTS += --with-included-ltdl
endif

ifeq ($(BR2_PACKAGE_READLINE),y)
UNIXODBC_CONF_OPTS += --enable-readline
UNIXODBC_DEPENDENCIES += readline
else
UNIXODBC_CONF_OPTS += --disable-readline
endif

ifeq ($(BR2_TOOLCHAIN_HAS_THREADS),y)
UNIXODBC_CONF_OPTS += --enable-threads
else
UNIXODBC_CONF_OPTS += --disable-threads
endif

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
