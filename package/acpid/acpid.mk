ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# acpid
#
#############################################################

ACPID_VERSION = 2.0.34
ACPID_SOURCE = acpid-$(ACPID_VERSION).tar.xz
ACPID_SITE = https://downloads.sourceforge.net/project/acpid2
ACPID_CUSTOM_PATCH_DIR = astlinux

define ACPID_SET_EVENTS_FILES
	mkdir -p $(TARGET_DIR)/etc/acpi/events
	/bin/echo -e "event=button[ /]power\naction=/sbin/poweroff" > $(TARGET_DIR)/etc/acpi/events/powerbtn
	$(INSTALL) -D -m 755 package/acpid/astlinux/acpid.init $(TARGET_DIR)/etc/init.d/acpid
	ln -sf ../../init.d/acpid $(TARGET_DIR)/etc/runlevels/default/S24acpid
	ln -sf ../../init.d/acpid $(TARGET_DIR)/etc/runlevels/default/K01acpid
endef

ACPID_POST_INSTALL_TARGET_HOOKS += ACPID_SET_EVENTS_FILES

define ACPID_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/sbin/acpid
	rm -f $(TARGET_DIR)/usr/bin/acpi_listen
	rm -f $(TARGET_DIR)/etc/init.d/acpid
	rm -f $(TARGET_DIR)/etc/runlevels/default/S24acpid
	rm -f $(TARGET_DIR)/etc/runlevels/default/K01acpid
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# acpid
#
################################################################################

ACPID_VERSION = 2.0.34
ACPID_SOURCE = acpid-$(ACPID_VERSION).tar.xz
ACPID_SITE = http://downloads.sourceforge.net/project/acpid2
ACPID_LICENSE = GPL-2.0+
ACPID_LICENSE_FILES = COPYING
ACPID_CPE_ID_VENDOR = tedfelix
ACPID_CPE_ID_PRODUCT = acpid2
ACPID_SELINUX_MODULES = acpi

define ACPID_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 0644 package/acpid/acpid.service \
		$(TARGET_DIR)/usr/lib/systemd/system/acpid.service
endef

define ACPID_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 package/acpid/S02acpid \
		$(TARGET_DIR)/etc/init.d/S02acpid
endef

ifeq ($(BR2_INIT_SYSV)$(BR2_INIT_SYSTEMD),y)
ACPID_POWEROFF_CMD = /sbin/shutdown -hP now
else
ACPID_POWEROFF_CMD = /sbin/poweroff
endif

define ACPID_SET_EVENTS
	mkdir -p $(TARGET_DIR)/etc/acpi/events
	printf 'event=button[ /]power\naction=%s\n' '$(ACPID_POWEROFF_CMD)' \
		>$(TARGET_DIR)/etc/acpi/events/powerbtn
endef

ACPID_POST_INSTALL_TARGET_HOOKS += ACPID_SET_EVENTS

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
