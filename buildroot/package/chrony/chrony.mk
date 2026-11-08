ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

################################################################################
#
# chrony
#
################################################################################

CHRONY_VERSION = 4.9
CHRONY_SITE = https://chrony-project.org/releases
CHRONY_CUSTOM_PATCH_DIR = astlinux
CHRONY_DEPENDENCIES = host-pkgconf libcap

CHRONY_CONF_OPTS = \
	--host-system=Linux \
	--host-release="" \
	--host-machine=$(BR2_ARCH) \
	--prefix=/usr \
	--with-sendmail=/usr/sbin/sendmail \
	--with-user=ntp \
	--disable-ipv6 \
	--disable-phc \
	--disable-nts \
	--without-gnutls \
	--without-nettle \
	--without-seccomp \
	--without-tomcrypt

ifeq ($(BR2_PACKAGE_LIBNSS),y)
CHRONY_DEPENDENCIES += host-pkgconf libnss
else
CHRONY_CONF_OPTS += --without-nss
endif

ifeq ($(BR2_PACKAGE_LIBEDIT),y)
CHRONY_DEPENDENCIES += libedit
else
CHRONY_CONF_OPTS += --without-editline
endif

# If pps-tools is available, build it before so the package can use it
# (HAVE_SYS_TIMEPPS_H).
ifeq ($(BR2_PACKAGE_PPS_TOOLS),y)
CHRONY_DEPENDENCIES += pps-tools
else
CHRONY_CONF_OPTS += --disable-pps
endif

define CHRONY_CONFIGURE_CMDS
	cd $(@D) && $(TARGET_CONFIGURE_OPTS) ./configure $(CHRONY_CONF_OPT)
endef

define CHRONY_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define CHRONY_INSTALL_TARGET_CMDS
	#touch $(@D)/doc/chrony{.conf,c,d}.man.in  # needed for snapshot tarball missing man pages
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR="$(TARGET_DIR)" install
	$(INSTALL) -D -m 755 package/chrony/astlinux/ntpd.init $(TARGET_DIR)/etc/init.d/ntpd
	ln -sf /tmp/etc/chrony.conf $(TARGET_DIR)/etc/chrony.conf
endef

define CHRONY_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/sbin/chronyd
	rm -f $(TARGET_DIR)/usr/bin/chronyc
	rm -f $(TARGET_DIR)/etc/init.d/ntpd
	rm -f $(TARGET_DIR)/etc/chrony.conf
endef

$(eval $(generic-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# chrony
#
################################################################################

CHRONY_VERSION = 4.6.1
CHRONY_SITE = https://chrony-project.org/releases
CHRONY_LICENSE = GPL-2.0
CHRONY_LICENSE_FILES = COPYING
CHRONY_CPE_ID_VENDOR = tuxfamily
CHRONY_SELINUX_MODULES = chronyd
CHRONY_DEPENDENCIES = host-pkgconf libcap

CHRONY_CONF_OPTS = \
	--host-system=Linux \
	--host-machine=$(BR2_ARCH) \
	--prefix=/usr \
	--without-tomcrypt \
	--with-user=chrony \
	$(if $(BR2_PACKAGE_CHRONY_DEBUG_LOGGING),--enable-debug,--disable-debug)

define CHRONY_USERS
	chrony -1 chrony -1 * /run/chrony - - Time daemon
endef

define CHRONY_PERMISSIONS
	/var/lib/chrony d 755 chrony chrony - - - - -
endef

ifeq ($(BR2_PACKAGE_LIBNSS),y)
CHRONY_DEPENDENCIES += libnss
else
CHRONY_CONF_OPTS += --without-nss
endif

ifeq ($(BR2_PACKAGE_LIBSECCOMP),y)
CHRONY_CONF_OPTS += --enable-scfilter
CHRONY_DEPENDENCIES += libseccomp
else
CHRONY_CONF_OPTS += --without-seccomp
endif

ifeq ($(BR2_PACKAGE_LIBEDIT),y)
CHRONY_DEPENDENCIES += libedit
else
CHRONY_CONF_OPTS += --without-editline --disable-readline
endif

# If pps-tools is available, build it before so the package can use it
# (HAVE_SYS_TIMEPPS_H).
ifeq ($(BR2_PACKAGE_PPS_TOOLS),y)
CHRONY_DEPENDENCIES += pps-tools
endif

ifeq ($(BR2_PACKAGE_GNUTLS),y)
CHRONY_DEPENDENCIES += gnutls
else
CHRONY_CONF_OPTS += --without-gnutls
endif

ifeq ($(BR2_PACKAGE_NETTLE),y)
CHRONY_DEPENDENCIES += nettle
else
CHRONY_CONF_OPTS += --without-nettle
endif

define CHRONY_CONFIGURE_CMDS
	cd $(@D) && $(TARGET_CONFIGURE_OPTS) ./configure $(CHRONY_CONF_OPTS)
endef

define CHRONY_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define CHRONY_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR="$(TARGET_DIR)" install
	$(INSTALL) -D -m 644 $(@D)/examples/chrony.conf.example2 $(TARGET_DIR)/etc/chrony.conf
endef

define CHRONY_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 755 package/chrony/S49chronyd $(TARGET_DIR)/etc/init.d/S49chronyd
endef

define CHRONY_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 package/chrony/chrony.service \
		$(TARGET_DIR)/usr/lib/systemd/system/chrony.service
	# advertise chrony.service to systemd-timedated
	$(INSTALL) -D -m 644 $(CHRONY_PKGDIR)/50-chrony.list \
		$(TARGET_DIR)/usr/lib/systemd/ntp-units.d/50-chrony.list
endef

$(eval $(generic-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
