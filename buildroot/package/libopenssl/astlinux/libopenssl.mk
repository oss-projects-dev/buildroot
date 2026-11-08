#############################################################
#
# openssl
#
#############################################################

LIBOPENSSL_VERSION = 1.1.1w
LIBOPENSSL_SITE = https://www.openssl.org/source
LIBOPENSSL_CUSTOM_PATCH_DIR = astlinux
LIBOPENSSL_INSTALL_STAGING = YES
LIBOPENSSL_DEPENDENCIES = zlib
LIBOPENSSL_TARGET_ARCH = linux-generic32
LIBOPENSSL_CFLAGS = $(TARGET_CFLAGS)

ifeq ($(BR2_TOOLCHAIN_HAS_THREADS),y)
LIBOPENSSL_CFLAGS += -DLIBOPENSSL_THREADS
endif

ifeq ($(BR2_PACKAGE_LIBOPENSSL_OCF),y)
LIBOPENSSL_DEPENDENCIES += ocf-linux
endif

ifeq ($(BR2_STATIC_LIBS),y)
# Use "gcc" minimalistic target to disable DSO
	LIBOPENSSL_TARGET_ARCH = gcc
else
# Some architectures are optimized in OpenSSL
ifeq ($(ARCH),arm)
	LIBOPENSSL_TARGET_ARCH = linux-armv4
endif
ifeq ($(ARCH),powerpc)
# 4xx cores seem to have trouble with openssl's ASM optimizations
ifeq ($(BR2_powerpc_401)$(BR2_powerpc_403)$(BR2_powerpc_405)$(BR2_powerpc_405fp)$(BR2_powerpc_440)$(BR2_powerpc_440fp),)
	LIBOPENSSL_TARGET_ARCH = linux-ppc
endif
endif
ifeq ($(ARCH),x86_64)
	LIBOPENSSL_TARGET_ARCH = linux-x86_64
endif
ifeq ($(ARCH),i686)
	LIBOPENSSL_TARGET_ARCH = linux-elf
endif
ifeq ($(ARCH),i586)
	LIBOPENSSL_TARGET_ARCH = linux-elf
endif
endif

define LIBOPENSSL_CONFIGURE_CMDS
	(cd $(@D); \
		$(TARGET_CONFIGURE_ARGS) \
		$(TARGET_CONFIGURE_OPTS) \
		./Configure \
			$(LIBOPENSSL_TARGET_ARCH) \
			--prefix=/usr \
			--openssldir=/usr/lib/ssl \
			$(if $(BR2_TOOLCHAIN_HAS_THREADS),-lpthread threads, no-threads) \
			$(if $(BR2_STATIC_LIBS),no-shared,shared) \
			$(if $(BR2_PACKAGE_LIBOPENSSL_OCF),enable-devcryptoeng) \
			no-rc5 \
			enable-camellia \
			enable-mdc2 \
			no-tests \
			no-fuzz-libfuzzer \
			no-fuzz-afl \
			no-afalgeng \
			$(if $(BR2_STATIC_LIBS),zlib,zlib-dynamic) \
	)
	$(SED) "s:-march=[-a-z0-9] ::" -e "s:-mcpu=[-a-z0-9] ::g" $(@D)/Makefile
	$(SED) "s:-O[0-9s]:$(LIBOPENSSL_CFLAGS):" $(@D)/Makefile
	$(SED) "s: build_tests::" $(@D)/Makefile
endef

define LIBOPENSSL_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D)
endef

define LIBOPENSSL_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D) DESTDIR=$(STAGING_DIR) install
endef

define LIBOPENSSL_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D) DESTDIR=$(TARGET_DIR) install
	# Keep target /usr/lib/ssl
	rm -f $(TARGET_DIR)/usr/bin/c_rehash
endef

ifeq ($(BR2_PACKAGE_PERL),)
define LIBOPENSSL_REMOVE_PERL_SCRIPTS
	rm -f $(TARGET_DIR)/etc/ssl/misc/{CA.pl,tsget}
endef
LIBOPENSSL_POST_INSTALL_TARGET_HOOKS += LIBOPENSSL_REMOVE_PERL_SCRIPTS
endif

ifeq ($(BR2_PACKAGE_LIBOPENSSL_BIN),)
define LIBOPENSSL_REMOVE_BIN
	rm -f $(TARGET_DIR)/usr/bin/openssl
	rm -f $(TARGET_DIR)/usr/lib/ssl/misc/{CA.*,c_*}
endef
LIBOPENSSL_POST_INSTALL_TARGET_HOOKS += LIBOPENSSL_REMOVE_BIN
endif

ifneq ($(BR2_PACKAGE_LIBOPENSSL_ENGINES),y)
define LIBOPENSSL_REMOVE_LIBOPENSSL_ENGINES
	rm -rf $(TARGET_DIR)/usr/lib/engines-1.1
endef
LIBOPENSSL_POST_INSTALL_TARGET_HOOKS += LIBOPENSSL_REMOVE_LIBOPENSSL_ENGINES
endif

$(eval $(generic-package))
