ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

################################################################################
#
# ca-certificates
#
################################################################################

CA_CERTIFICATES_VERSION = 2026-10-20
CA_CERTIFICATES_SOURCE = cacert-$(CA_CERTIFICATES_VERSION).pem
CA_CERTIFICATES_SITE = https://curl.haxx.se/ca
CA_CERTIFICATES_CUSTOM_PATCH_DIR = astlinux

define CA_CERTIFICATES_EXTRACT_CMDS
	cp $(DL_DIR)/$(CA_CERTIFICATES_SOURCE) $(@D)/cacert.pem
endef

define CA_CERTIFICATES_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -d $(TARGET_DIR)/usr/lib/ssl/certs
	$(INSTALL) -m 0755 -d $(TARGET_DIR)/etc/ssl/certs
	$(INSTALL) -m 0444 -D $(@D)/cacert.pem $(TARGET_DIR)/usr/share/ca-certificates/ca-bundle.crt
	ln -sf /usr/share/ca-certificates/ca-bundle.crt $(TARGET_DIR)/usr/lib/ssl/certs/ca-bundle.crt
	ln -sf /usr/share/ca-certificates/ca-bundle.crt $(TARGET_DIR)/usr/lib/ssl/cert.pem
	ln -sf /usr/share/ca-certificates/ca-bundle.crt $(TARGET_DIR)/etc/ssl/certs/ca-certificates.crt
endef

define CA_CERTIFICATES_UNINSTALL_TARGET_CMDS
	rm -f  $(TARGET_DIR)/usr/lib/ssl/certs/ca-bundle.crt
	rm -f  $(TARGET_DIR)/usr/lib/ssl/cert.pem
	rm -f  $(TARGET_DIR)/etc/ssl/certs/ca-certificates.crt
	rm -rf $(TARGET_DIR)/usr/share/ca-certificates
endef

$(eval $(generic-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# ca-certificates
#
################################################################################

CA_CERTIFICATES_VERSION = 20260816+nmu1
CA_CERTIFICATES_SOURCE = ca-certificates_$(CA_CERTIFICATES_VERSION).tar.xz
CA_CERTIFICATES_SITE = https://snapshot.debian.org/archive/debian/20261020T202723Z/pool/main/c/ca-certificates
CA_CERTIFICATES_DEPENDENCIES = host-openssl host-python3
CA_CERTIFICATES_LICENSE = GPL-2.0+ (script), MPL-2.0 (data)
CA_CERTIFICATES_LICENSE_FILES = debian/copyright

define CA_CERTIFICATES_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) clean all
endef

define CA_CERTIFICATES_INSTALL_TARGET_CMDS
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/usr/share/ca-certificates
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/etc/ssl/certs
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) install DESTDIR=$(TARGET_DIR)
	rm -f $(TARGET_DIR)/usr/sbin/update-ca-certificates
endef

define CA_CERTIFICATES_GEN_BUNDLE
	# Remove any existing certificates under /etc/ssl/certs
	rm -f $(TARGET_DIR)/etc/ssl/certs/*

	# Create symlinks to certificates under /etc/ssl/certs
	# and generate the bundle
	cd $(TARGET_DIR) ;\
	for i in `find usr/share/ca-certificates -name "*.crt" | LC_COLLATE=C sort` ; do \
		ln -sf ../../../$$i etc/ssl/certs/`basename $${i} .crt`.pem ;\
		cat $$i ;\
	done >$(BUILD_DIR)/ca-certificates.crt

	# Create symlinks to the certificates by their hash values
	$(HOST_DIR)/bin/openssl rehash $(TARGET_DIR)/etc/ssl/certs

	# Install the certificates bundle
	$(INSTALL) -D -m 644 $(BUILD_DIR)/ca-certificates.crt \
		$(TARGET_DIR)/etc/ssl/certs/ca-certificates.crt
endef
CA_CERTIFICATES_TARGET_FINALIZE_HOOKS += CA_CERTIFICATES_GEN_BUNDLE

$(eval $(generic-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
