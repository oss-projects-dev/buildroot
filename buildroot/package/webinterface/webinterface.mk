#############################################################
#
# webinterface
#
#############################################################
WEBINTERFACE_SITE = package/webinterface/astlinux/www
WEBINTERFACE_SITE_METHOD = local
WEBINTERFACE_TARGET_DIR=stat/var/www

ifeq ($(strip $(BR2_PACKAGE_WEBINTERFACE_v1)),y)
ifeq ($(strip $(BR2_PACKAGE_WEBINTERFACE_v2)),y)
$(error Web interface versions are mutually exlusive; pick only one)
endif
endif

define WEBINTERFACE_CONFIGURE_CMDS
        @echo "No configure"
endef

define WEBINTERFACE_BUILD_CMDS
        @echo "No build"
endef

ifeq ($(strip $(BR2_PACKAGE_ASTERISK)),y)
WEBINTERFACE_DEPENDENCIES += asterisk
#else
#webinterface-install: 
endif

define WEBINTERFACE_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/$(WEBINTERFACE_TARGET_DIR)
endef

ifeq ($(strip $(BR2_PACKAGE_WEBINTERFACE_v1)),y)
define WEBINTERFACE_INSTALL_TARGET_CMDS_WEBINTERFACE
	rsync -a --exclude=".svn" package/webinterface/astlinux/www $(TARGET_DIR)/stat/var/www/
endef
WEBINTERFACE_POST_INSTALL_TARGET_HOOKS += WEBINTERFACE_INSTALL_TARGET_CMDS_WEBINTERFACE
endif

ifeq ($(strip $(BR2_PACKAGE_WEBINTERFACE_v2)),y)
define WEBINTERFACE_INSTALL_TARGET_CMDS_WEBINTERFACE
	rsync -a --exclude=".svn" package/webinterface/astlinux/altweb/ $(TARGET_DIR)/stat/var/www/
	$(INSTALL) -D -m 644 package/webinterface/astlinux/www/admin/.htpasswd $(TARGET_DIR)/stat/var/www/admin/.htpasswd
endef
WEBINTERFACE_POST_INSTALL_TARGET_HOOKS += WEBINTERFACE_INSTALL_TARGET_CMDS_WEBINTERFACE
endif

ifeq ($(strip $(BR2_PACKAGE_WEBINTERFACE_v2))$(strip $(BR2_PACKAGE_ASTERISK)),yy)
define WEBINTERFACE_INSTALL_TARGET_CMDS_WEBINTERFACE_ASTERISK
	$(INSTALL) -D -m 700 package/webinterface/astlinux/ast-vmpass $(TARGET_DIR)/usr/sbin/ast-vmpass
	NL=$$'\\\n' ; \
	$(SED) '/^\[general\]$$/,/^$$/{s/^enabled = no$$/enabled = yes/}' \
	   -e  '/^\[webinterface\]$$/,/^$$/d' \
	   -e  "/^;\[mark\]$$/i $${NL}[webinterface]$${NL}secret = webinterface$${NL}deny = 0.0.0.0/0.0.0.0$${NL}permit = 127.0.0.1/255.255.255.255$${NL}read = command$${NL}write = command$${NL}" \
		$(TARGET_DIR)/stat/etc/asterisk/manager.conf
	$(SED) '/^\[general\]$$/,/^\[/{s:^;externpass=/usr/bin/myapp$$:externpass=/usr/sbin/ast-vmpass:}' \
		$(TARGET_DIR)/stat/etc/asterisk/voicemail.conf
endef
WEBINTERFACE_POST_INSTALL_TARGET_HOOKS += WEBINTERFACE_INSTALL_TARGET_CMDS_WEBINTERFACE_ASTERISK
endif


#
# make x-clean should undo all changes done by 'x'.  No exceptions.
#

#webinterface-clean:
#	rm -rf $(TARGET_DIR)/stat/var/www
#	rm -f $(TARGET_DIR)/usr/sbin/ast-vmpass
#ifeq ($(strip $(BR2_PACKAGE_ASTERISK)),y)
#	$(SED) '/^\[general\]$$/,/^$$/{s/^enabled = yes$$/enabled = no/}' \
#	   -e  '/^\[webinterface\]$$/,/^$$/d' \
#		$(TARGET_DIR)/stat/etc/asterisk/manager.conf
#	$(SED) '/^\[general\]$$/,/^\[/{s:^externpass=/usr/sbin/ast-vmpass$$:;externpass=/usr/bin/myapp:}' \
#		$(TARGET_DIR)/stat/etc/asterisk/voicemail.conf
#endif

#webinterface-dirclean:

#ifeq ($(strip $(BR2_PACKAGE_WEBINTERFACE_v1)),y)
#	rm -rf $(TARGET_DIR)/stat/var/www
#endif
#ifeq ($(strip $(BR2_PACKAGE_WEBINTERFACE_v2)),y)
#	rm -rf $(TARGET_DIR)/stat/var/www
#endif

# We want to always be applied *after* asterisk and asterisk-gui
# (assuming the later is configured as well).

#webinterface: webinterface-install
 
#############################################################
#
# Toplevel Makefile options
#
#############################################################
#ifeq ($(strip $(BR2_PACKAGE_WEBINTERFACE)),y)
#TARGETS+=webinterface
#endif

$(eval $(generic-package))
