ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

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

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# libcurl
#
################################################################################

LIBCURL_VERSION = 8.22.0
LIBCURL_SOURCE = curl-$(LIBCURL_VERSION).tar.xz
LIBCURL_SITE = https://curl.se/download
LIBCURL_DEPENDENCIES = host-pkgconf \
	$(if $(BR2_PACKAGE_ZLIB),zlib) \
	$(if $(BR2_PACKAGE_RTMPDUMP),rtmpdump)
LIBCURL_LICENSE = curl
LIBCURL_LICENSE_FILES = COPYING
LIBCURL_CPE_ID_VENDOR = haxx
LIBCURL_INSTALL_STAGING = YES

# Likewise, there is no compiler on the target, so libcurl-option (to
# generate C code) isn't very useful
LIBCURL_CONF_OPTS = \
	--disable-manual \
	--disable-ntlm \
	--disable-curldebug \
	--disable-libcurl-option \
	--disable-ldap \
	--disable-ldaps

# threaded resolver cannot be used with c-ares
# https://github.com/curl/curl/commit/d364f1347f05c53eea5d25a15b4ad8a62ecc85b8
ifeq ($(BR2_TOOLCHAIN_HAS_THREADS)x$(BR2_PACKAGE_C_ARES),yx)
LIBCURL_CONF_OPTS += --enable-threaded-resolver
else
LIBCURL_CONF_OPTS += --disable-threaded-resolver
endif

ifeq ($(BR2_TOOLCHAIN_HAS_LIBATOMIC),y)
LIBCURL_CONF_OPTS += LIBS=-latomic
endif

ifeq ($(BR2_TOOLCHAIN_HAS_SYNC_1),)
# Even though stdatomic.h does exist, link fails for __atomic_exchange_1
# Work around this by pretending atomics aren't available.
LIBCURL_CONF_ENV += ac_cv_header_stdatomic_h=no
endif

ifeq ($(BR2_PACKAGE_LIBCURL_VERBOSE),y)
LIBCURL_CONF_OPTS += --enable-verbose
else
LIBCURL_CONF_OPTS += --disable-verbose
endif

LIBCURL_CONFIG_SCRIPTS = curl-config

ifeq ($(BR2_PACKAGE_LIBCURL_TLS_NONE),y)
LIBCURL_CONF_OPTS += --without-ssl
endif

ifeq ($(BR2_PACKAGE_LIBCURL_OPENSSL),y)
LIBCURL_DEPENDENCIES += openssl
LIBCURL_CONF_OPTS += --with-openssl=$(STAGING_DIR)/usr \
	--with-ca-path=/etc/ssl/certs \
	--with-ca-bundle=/etc/ssl/certs/ca-certificates.crt
else
LIBCURL_CONF_OPTS += --without-openssl
endif

ifeq ($(BR2_PACKAGE_LIBCURL_GNUTLS),y)
LIBCURL_CONF_OPTS += --with-gnutls=$(STAGING_DIR)/usr
LIBCURL_DEPENDENCIES += gnutls
else
LIBCURL_CONF_OPTS += --without-gnutls
endif

ifeq ($(BR2_PACKAGE_LIBCURL_MBEDTLS),y)
LIBCURL_CONF_OPTS += --with-mbedtls=$(STAGING_DIR)/usr
LIBCURL_DEPENDENCIES += mbedtls
else
LIBCURL_CONF_OPTS += --without-mbedtls
endif

ifeq ($(BR2_PACKAGE_LIBCURL_WOLFSSL),y)
LIBCURL_CONF_OPTS += --with-wolfssl=$(STAGING_DIR)/usr
LIBCURL_CONF_OPTS += --with-ca-bundle=/etc/ssl/certs/ca-certificates.crt
LIBCURL_DEPENDENCIES += wolfssl
else
LIBCURL_CONF_OPTS += --without-wolfssl
endif

ifeq ($(BR2_PACKAGE_C_ARES),y)
LIBCURL_DEPENDENCIES += c-ares
LIBCURL_CONF_OPTS += --enable-ares
else
LIBCURL_CONF_OPTS += --disable-ares
endif

ifeq ($(BR2_PACKAGE_LIBIDN2),y)
LIBCURL_DEPENDENCIES += libidn2
LIBCURL_CONF_OPTS += --with-libidn2
else
LIBCURL_CONF_OPTS += --without-libidn2
endif

ifeq ($(BR2_PACKAGE_LIBPSL),y)
LIBCURL_DEPENDENCIES += libpsl
LIBCURL_CONF_OPTS += --with-libpsl
else
LIBCURL_CONF_OPTS += --without-libpsl
endif

# Configure curl to support libssh2
ifeq ($(BR2_PACKAGE_LIBSSH2),y)
LIBCURL_DEPENDENCIES += libssh2
LIBCURL_CONF_OPTS += --with-libssh2
else
LIBCURL_CONF_OPTS += --without-libssh2
endif

ifeq ($(BR2_PACKAGE_BROTLI),y)
LIBCURL_DEPENDENCIES += brotli
LIBCURL_CONF_OPTS += --with-brotli
else
LIBCURL_CONF_OPTS += --without-brotli
endif

ifeq ($(BR2_PACKAGE_NGHTTP2),y)
LIBCURL_DEPENDENCIES += nghttp2
LIBCURL_CONF_OPTS += --with-nghttp2
else
LIBCURL_CONF_OPTS += --without-nghttp2
endif

ifeq ($(BR2_PACKAGE_LIBGSASL),y)
LIBCURL_DEPENDENCIES += libgsasl
LIBCURL_CONF_OPTS += --with-libgsasl
else
LIBCURL_CONF_OPTS += --without-libgsasl
endif

ifeq ($(BR2_PACKAGE_LIBCURL_COOKIES_SUPPORT),y)
LIBCURL_CONF_OPTS += --enable-cookies
else
LIBCURL_CONF_OPTS += --disable-cookies
endif

ifeq ($(BR2_PACKAGE_LIBCURL_PROXY_SUPPORT),y)
LIBCURL_CONF_OPTS += --enable-proxy
else
LIBCURL_CONF_OPTS += --disable-proxy
endif

ifeq ($(BR2_PACKAGE_LIBCURL_WEBSOCKETS_SUPPORT),y)
LIBCURL_CONF_OPTS += --enable-websockets
else
LIBCURL_CONF_OPTS += --disable-websockets
endif

ifeq ($(BR2_PACKAGE_LIBCURL_EXTRA_PROTOCOLS_FEATURES),y)
LIBCURL_CONF_OPTS += \
	--enable-dict \
	--enable-gopher \
	--enable-imap \
	--enable-pop3 \
	--enable-rtsp \
	--enable-smb \
	--enable-smtp \
	--enable-telnet \
	--enable-tftp
else
LIBCURL_CONF_OPTS += \
	--disable-dict \
	--disable-gopher \
	--disable-imap \
	--disable-pop3 \
	--disable-rtsp \
	--disable-smb \
	--disable-smtp \
	--disable-telnet \
	--disable-tftp
endif

ifeq ($(BR2_PACKAGE_LIBCURL_CURL),)
define LIBCURL_TARGET_CLEANUP
	rm -rf $(TARGET_DIR)/usr/bin/curl
endef
LIBCURL_POST_INSTALL_TARGET_HOOKS += LIBCURL_TARGET_CLEANUP
endif

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
