#############################################################
#
# libcurl
#
#############################################################

LIBCURL_VERSION = 8.17.0
LIBCURL_SOURCE = curl-$(LIBCURL_VERSION).tar.gz
LIBCURL_SITE = https://curl.haxx.se/download
LIBCURL_CUSTOM_PATCH_DIR = astlinux
LIBCURL_INSTALL_STAGING = YES

LIBCURL_DEPENDENCIES = host-pkgconf \
	$(if $(BR2_PACKAGE_ZLIB),zlib)

LIBCURL_CONF_OPTS = \
	--disable-verbose \
	--disable-manual \
	--disable-curldebug \
	--disable-websockets \
	--disable-mqtt \
	--disable-gopher \
	--disable-ldap \
	--disable-smb \
	--disable-dict \
	--disable-ipfs \
	--disable-rtsp \
	--disable-imap \
	--disable-pop3 \
	--disable-smtp \
	--disable-telnet \
	--disable-alt-svc \
	--disable-ares \
	--disable-ntlm \
	--disable-tls-srp \
	--disable-libcurl-option \
	--enable-symbol-hiding \
	--without-libidn2 \
	--without-libpsl \
	--without-librtmp \
	--enable-ipv6

ifeq ($(BR2_PACKAGE_OPENSSL),y)
LIBCURL_DEPENDENCIES += openssl
LIBCURL_CONF_OPTS += \
	--with-openssl=$(STAGING_DIR)/usr \
	--with-ca-bundle=/usr/lib/ssl/certs/ca-bundle.crt
else
LIBCURL_CONF_OPTS += --without-ssl
endif

LIBCURL_CONF_ENV += \
	CFLAGS="" \
	CPPFLAGS='$(TARGET_CFLAGS)'

define LIBCURL_TARGET_CLEANUP
	rm -rf $(TARGET_DIR)/usr/bin/curl-config \
	       $(if $(BR2_PACKAGE_CURL),,$(TARGET_DIR)/usr/bin/curl)
endef
LIBCURL_POST_INSTALL_TARGET_HOOKS += LIBCURL_TARGET_CLEANUP

define LIBCURL_STAGING_FIXUP_CURL_CONFIG
	$(SED) "s,^prefix=.*,prefix='$(STAGING_DIR)/usr',g" $(STAGING_DIR)/usr/bin/curl-config
	$(SED) "s,^exec_prefix=.*,exec_prefix='$(STAGING_DIR)/usr',g" $(STAGING_DIR)/usr/bin/curl-config
endef
LIBCURL_POST_INSTALL_STAGING_HOOKS += LIBCURL_STAGING_FIXUP_CURL_CONFIG

$(eval $(autotools-package))

curl: libcurl
curl-clean: libcurl-clean
curl-dirclean: libcurl-dirclean
curl-source: libcurl-source
