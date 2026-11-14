ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

################################################################################
#
# lxc
#
################################################################################

LXC_VERSION = 3.2.1
LXC_SITE = https://linuxcontainers.org/downloads/lxc
LXC_CUSTOM_PATCH_DIR = astlinux
LXC_DEPENDENCIES = host-pkgconf
LXC_INSTALL_STAGING = YES

LXC_CONF_OPTS = \
	--localstatedir=/var \
	--with-runtime-path=/var/run \
	--with-distro=buildroot \
	--disable-commands \
	--disable-apparmor \
	--disable-seccomp \
	--disable-selinux \
	--disable-werror \
	--disable-doc \
	--disable-api-docs \
	--disable-examples \
	--disable-pam \
	$(if $(BR2_PACKAGE_BASH),,--disable-bash)

ifeq ($(BR2_PACKAGE_LIBCAP),y)
LXC_CONF_OPTS += --enable-capabilities
LXC_DEPENDENCIES += libcap
else
LXC_CONF_OPTS += --disable-capabilities
endif

ifeq ($(BR2_PACKAGE_OPENSSL),y)
LXC_CONF_OPTS += --enable-openssl
LXC_DEPENDENCIES += openssl
else
LXC_CONF_OPTS += --disable-openssl
endif

define LXC_REMOVE_TARGET_FILES
	rm -f $(TARGET_DIR)/usr/bin/lxc-checkpoint
	rm -f $(TARGET_DIR)/usr/bin/lxc-execute
	rm -f $(TARGET_DIR)/usr/share/lxc/templates/lxc-local
	rm -f $(TARGET_DIR)/usr/share/lxc/templates/lxc-oci
	rm -f $(TARGET_DIR)/usr/share/lxc/config/nesting.conf
	rm -f $(TARGET_DIR)/usr/share/lxc/config/oci.common.conf
	rm -f $(TARGET_DIR)/usr/share/lxc/lxc-patch.py
	rm -rf $(TARGET_DIR)/etc/default
	rm -rf $(TARGET_DIR)/usr/libexec/lxc
	rm -rf $(TARGET_DIR)/usr/share/lxc/selinux
endef
LXC_POST_INSTALL_TARGET_HOOKS = LXC_REMOVE_TARGET_FILES

define LXC_POST_INSTALL
	$(INSTALL) -m 0644 -D package/lxc/astlinux/default.conf $(TARGET_DIR)/etc/lxc/default.conf
	$(INSTALL) -m 0644 -D package/lxc/astlinux/config/*.conf $(TARGET_DIR)/usr/share/lxc/config/
	$(INSTALL) -m 0755 -D package/lxc/astlinux/scripts/cgroupfs-mount $(TARGET_DIR)/usr/bin/cgroupfs-mount
	$(INSTALL) -m 0755 -D package/lxc/astlinux/scripts/cgroupfs-umount $(TARGET_DIR)/usr/bin/cgroupfs-umount
	$(INSTALL) -m 0755 -D package/lxc/astlinux/lxc.init $(TARGET_DIR)/etc/init.d/lxc
	ln -sf ../../init.d/lxc $(TARGET_DIR)/etc/runlevels/default/S98lxc
	ln -sf ../../init.d/lxc $(TARGET_DIR)/etc/runlevels/default/K00lxc
endef
LXC_POST_INSTALL_TARGET_HOOKS += LXC_POST_INSTALL

define LXC_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/cgroupfs-mount
	rm -f $(TARGET_DIR)/usr/bin/cgroupfs-umount
	rm -f $(TARGET_DIR)/etc/init.d/lxc
	rm -f $(TARGET_DIR)/etc/runlevels/default/S98lxc
	rm -f $(TARGET_DIR)/etc/runlevels/default/K00lxc
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# lxc
#
################################################################################

LXC_VERSION = 5.0.3
LXC_SITE = https://linuxcontainers.org/downloads/lxc
LXC_LICENSE = GPL-2.0 (some tools), LGPL-2.1+
LXC_LICENSE_FILES = LICENSE.GPL2 LICENSE.LGPL2.1
LXC_CPE_ID_VENDOR = linuxcontainers
LXC_DEPENDENCIES = host-pkgconf
LXC_INSTALL_STAGING = YES

LXC_CONF_OPTS = \
	-Dexamples=false \
	-Dman=false

ifeq ($(BR2_PACKAGE_LIBAPPARMOR),y)
LXC_CONF_OPTS += -Dapparmor=true
LXC_DEPENDENCIES += libapparmor
else
LXC_CONF_OPTS += -Dapparmor=false
endif

ifeq ($(BR2_PACKAGE_BASH_COMPLETION),y)
LXC_DEPENDENCIES += bash-completion
endif

ifeq ($(BR2_PACKAGE_LIBCAP),y)
LXC_CONF_OPTS += -Dcapabilities=true
LXC_DEPENDENCIES += libcap
else
LXC_CONF_OPTS += -Dcapabilities=false
endif

ifeq ($(BR2_PACKAGE_LIBSECCOMP),y)
LXC_CONF_OPTS += -Dseccomp=true
LXC_DEPENDENCIES += libseccomp
else
LXC_CONF_OPTS += -Dseccomp=false
endif

ifeq ($(BR2_PACKAGE_LIBSELINUX),y)
LXC_CONF_OPTS += -Dselinux=true
LXC_DEPENDENCIES += libselinux
else
LXC_CONF_OPTS += -Dselinux=false
endif

ifeq ($(BR2_PACKAGE_LIBURING),y)
LXC_CONF_OPTS += -Dio-uring-event-loop=true
LXC_DEPENDENCIES += liburing
else
LXC_CONF_OPTS += -Dio-uring-event-loop=false
endif

ifeq ($(BR2_PACKAGE_LINUX_PAM),y)
LXC_CONF_OPTS += -Dpam-cgroup=true
LXC_DEPENDENCIES += linux-pam
else
LXC_CONF_OPTS += -Dpam-cgroup=false
endif

ifeq ($(BR2_PACKAGE_OPENSSL),y)
LXC_CONF_OPTS += -Dopenssl=true
LXC_DEPENDENCIES += openssl
else
LXC_CONF_OPTS += -Dopenssl=false
endif

ifeq ($(BR2_PACKAGE_SYSTEMD),y)
LXC_CONF_OPTS += -Dsd-bus=enabled
LXC_DEPENDENCIES += systemd
else
LXC_CONF_OPTS += -Dsd-bus=disabled
endif

ifeq ($(BR2_INIT_SYSTEMD),y)
LXC_CONF_OPTS += -Dinit-script=systemd
else ifeq ($(BR2_INIT_SYSV),y)
LXC_CONF_OPTS += -Dinit-script=sysvinit
else
LXC_CONF_OPTS += -Dinit-script=
endif

$(eval $(meson-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
