ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# dosfstools
#
#############################################################
DOSFSTOOLS_VERSION = 3.0.28
DOSFSTOOLS_SOURCE = dosfstools-$(DOSFSTOOLS_VERSION).tar.xz
DOSFSTOOLS_SITE = https://github.com/dosfstools/dosfstools/releases/download/v$(DOSFSTOOLS_VERSION)
DOSFSTOOLS_CUSTOM_PATCH_DIR = astlinux

ifneq ($(BR2_ENABLE_LOCALE),y)
DOSFSTOOLS_DEPENDENCIES += libiconv
DOSFSTOOLS_LDLIBS += -liconv
endif

FATLABEL_BINARY = fatlabel
FSCK_FAT_BINARY = fsck.fat
MKFS_FAT_BINARY = mkfs.fat

FATLABEL_DOSFSLABEL_LINK = dosfslabel
FSCK_FAT_DOSFSCK_LINK = dosfsck
MKFS_FAT_MKDOSFS_LINK = mkdosfs

define DOSFSTOOLS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) LDLIBS="$(DOSFSTOOLS_LDLIBS)" -C $(@D)
endef

DOSFSTOOLS_INSTALL_BIN_FILES_$(BR2_PACKAGE_DOSFSTOOLS_DOSFSLABEL)+=$(FATLABEL_BINARY)
DOSFSTOOLS_INSTALL_BIN_FILES_$(BR2_PACKAGE_DOSFSTOOLS_DOSFSCK)+=$(FSCK_FAT_BINARY)
DOSFSTOOLS_INSTALL_BIN_FILES_$(BR2_PACKAGE_DOSFSTOOLS_MKDOSFS)+=$(MKFS_FAT_BINARY)

define DOSFSTOOLS_INSTALL_TARGET_CMDS
	test -z "$(DOSFSTOOLS_INSTALL_BIN_FILES_y)" || \
	install -m 755 $(addprefix $(@D)/,$(DOSFSTOOLS_INSTALL_BIN_FILES_y)) $(TARGET_DIR)/sbin/
	ln -sf $(FATLABEL_BINARY) $(TARGET_DIR)/sbin/$(FATLABEL_DOSFSLABEL_LINK)
	ln -sf $(FSCK_FAT_BINARY) $(TARGET_DIR)/sbin/$(FSCK_FAT_DOSFSCK_LINK)
	ln -sf $(MKFS_FAT_BINARY) $(TARGET_DIR)/sbin/$(MKFS_FAT_MKDOSFS_LINK)
endef

define DOSFSTOOLS_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/sbin/$(FATLABEL_BINARY) $(TARGET_DIR)/sbin/$(FATLABEL_DOSFSLABEL_LINK)
	rm -f $(TARGET_DIR)/sbin/$(FSCK_FAT_BINARY) $(TARGET_DIR)/sbin/$(FSCK_FAT_DOSFSCK_LINK)
	rm -f $(TARGET_DIR)/sbin/$(MKFS_FAT_BINARY) $(TARGET_DIR)/sbin/$(MKFS_FAT_MKDOSFS_LINK)
endef

define DOSFSTOOLS_CLEAN_CMDS
	-$(MAKE) -C $(@D) clean
endef

$(eval $(generic-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# dosfstools
#
################################################################################

DOSFSTOOLS_VERSION = 4.2
DOSFSTOOLS_SITE = https://github.com/dosfstools/dosfstools/releases/download/v$(DOSFSTOOLS_VERSION)
DOSFSTOOLS_LICENSE = GPL-3.0+
DOSFSTOOLS_LICENSE_FILES = COPYING
DOSFSTOOLS_CPE_ID_VALID = YES
DOSFSTOOLS_SELINUX_MODULES = fstools
DOSFSTOOLS_CONF_OPTS = --enable-compat-symlinks --exec-prefix=/
HOST_DOSFSTOOLS_CONF_OPTS = --enable-compat-symlinks

ifeq ($(BR2_PACKAGE_HAS_UDEV),y)
DOSFSTOOLS_CONF_OPTS += --with-udev
DOSFSTOOLS_DEPENDENCIES += udev
else
DOSFSTOOLS_CONF_OPTS += --without-udev
endif

ifneq ($(BR2_ENABLE_LOCALE),y)
DOSFSTOOLS_CONF_OPTS += LIBS="-liconv"
DOSFSTOOLS_DEPENDENCIES += libiconv
endif

ifeq ($(BR2_PACKAGE_DOSFSTOOLS_FATLABEL),y)
define DOSFSTOOLS_INSTALL_FATLABEL
	$(INSTALL) -D -m 0755 $(@D)/src/fatlabel $(TARGET_DIR)/sbin/fatlabel
	ln -sf fatlabel $(TARGET_DIR)/sbin/dosfslabel
endef
endif

ifeq ($(BR2_PACKAGE_DOSFSTOOLS_FSCK_FAT),y)
define DOSFSTOOLS_INSTALL_FSCK_FAT
	$(INSTALL) -D -m 0755 $(@D)/src/fsck.fat $(TARGET_DIR)/sbin/fsck.fat
	ln -sf fsck.fat $(TARGET_DIR)/sbin/fsck.vfat
	ln -sf fsck.fat $(TARGET_DIR)/sbin/fsck.msdos
	ln -sf fsck.fat $(TARGET_DIR)/sbin/dosfsck
endef
endif

ifeq ($(BR2_PACKAGE_DOSFSTOOLS_MKFS_FAT),y)
define DOSFSTOOLS_INSTALL_MKFS_FAT
	$(INSTALL) -D -m 0755 $(@D)/src/mkfs.fat $(TARGET_DIR)/sbin/mkfs.fat
	ln -sf mkfs.fat $(TARGET_DIR)/sbin/mkdosfs
	ln -sf mkfs.fat $(TARGET_DIR)/sbin/mkfs.msdos
	ln -sf mkfs.fat $(TARGET_DIR)/sbin/mkfs.vfat
endef
endif

define DOSFSTOOLS_INSTALL_TARGET_CMDS
	$(call DOSFSTOOLS_INSTALL_FATLABEL)
	$(call DOSFSTOOLS_INSTALL_FSCK_FAT)
	$(call DOSFSTOOLS_INSTALL_MKFS_FAT)
endef

$(eval $(autotools-package))
$(eval $(host-autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
