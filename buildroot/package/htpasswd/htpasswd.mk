#############################################################
#
# htpasswd
#
#############################################################
HTPASSWD_SITE = package/htpasswd/astlinux/src
HTPASSWD_SITE_METHOD = local
HTPASSWD_DIR:=$(@D)
HTPASSWD_BINARY:=htpasswd
HTPASSWD_TARGET_BINARY:=usr/bin/htpasswd

#$(HTPASSWD_DIR)/.unpacked:
#	mkdir -p $(HTPASSWD_DIR)/
#	cp -a $(HTPASSWD_SOURCE)/* $(HTPASSWD_DIR)/
#	touch $@

#$(HTPASSWD_DIR)/.configured: $(HTPASSWD_DIR)/.unpacked
#	touch $@

define HTPASSWD_CONFIGURE_CMDS
        @echo "No configure"
endef

define HTPASSWD_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) \
	CFLAGS='$(TARGET_CFLAGS)' \
	LDFLAGS='$(TARGET_LDFLAGS)' \
	-C $(HTPASSWD_DIR)
endef

define HTPASSWD_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 -s $(HTPASSWD_DIR)/$(HTPASSWD_BINARY) $(TARGET_DIR)/$(HTPASSWD_TARGET_BINARY)
endef

#htpasswd: $(TARGET_DIR)/$(HTPASSWD_TARGET_BINARY)

#htpasswd-clean:
#	rm -f $(TARGET_DIR)/$(HTPASSWD_TARGET_BINARY)
#	-$(MAKE) -C $(HTPASSWD_DIR) clean

#htpasswd-dirclean:
#	rm -rf $(HTPASSWD_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
#ifeq ($(strip $(BR2_PACKAGE_HTPASSWD)),y)
#TARGETS+=htpasswd
#endif

$(eval $(generic-package))
