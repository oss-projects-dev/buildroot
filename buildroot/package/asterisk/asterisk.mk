ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# asterisk
#
##############################################################

ifeq ($(BR2_PACKAGE_ASTERISK_v20),y)
ASTERISK_VERSION := 20.22.0
ASTERISK_LABEL :=
else
ASTERISK_VERSION := 18.26.4
ASTERISK_LABEL := se
endif
ASTERISK_SOURCE := asterisk-$(ASTERISK_VERSION).tar.gz
ASTERISK_SITE := https://downloads.asterisk.org/pub/telephony/asterisk/releases
ASTERISK_CUSTOM_PATCH_DIR = astlinux
ASTERISK_DIR := $(@D)
ASTERISK_BINARY := main/asterisk
ASTERISK_TARGET_BINARY := usr/sbin/asterisk
ASTERISK_EXTRAS :=
ASTERISK_CONFIGURE_ENV :=
ASTERISK_CONFIGURE_ARGS :=
ASTERISK_MODULE_DIR := usr/lib/asterisk/modules

# $(call ndots start,end,dotted-string)
dot:=.
empty:=
space:=$(empty) $(empty)
ndots = $(subst $(space),$(dot),$(wordlist $(1),$(2),$(subst $(dot),$(space),$3)))
##
ASTERISK_VERSION_SINGLE := $(call ndots,1,1,$(ASTERISK_VERSION))
ASTERISK_VERSION_TUPLE := $(call ndots,1,2,$(ASTERISK_VERSION))

ASTERISK_GLOBAL_MAKEOPTS :=

ASTERISK_CONFIGURE_ENV += \
			USE_GETIFADDRS=yes

ASTERISK_LIBS:=

ifeq ($(strip $(BR2_PACKAGE_OPENSSL)),y)
ASTERISK_LIBS += -lssl
endif

ifeq ($(strip $(BR2_PACKAGE_ZLIB)),y)
ASTERISK_LIBS += -lz
endif

ASTERISK_CONFIGURE_ARGS+= \
			--without-sdl

ASTERISK_CONFIGURE_ARGS+= \
			--without-cap

ifeq ($(strip $(BR2_PACKAGE_LIBEDIT)),y)
ASTERISK_EXTRAS+=libedit
ASTERISK_CONFIGURE_ARGS+= \
			--with-libedit="$(STAGING_DIR)/usr"
else
ASTERISK_CONFIGURE_ARGS+= \
			--without-libedit
endif

ifeq ($(strip $(BR2_PACKAGE_LIBXML2)),y)
ASTERISK_EXTRAS+=libxml2
ASTERISK_CONFIGURE_ARGS+= \
			--with-libxml2
ASTERISK_CONFIGURE_ENV+= \
			CONFIG_LIBXML2="$(STAGING_DIR)/usr/bin/xml2-config"
else
ASTERISK_CONFIGURE_ARGS+= \
			--disable-xmldoc
endif

ASTERISK_CONFIGURE_ARGS+= \
			--without-ldap \
			--without-lua

ifeq ($(strip $(BR2_PACKAGE_IKSEMEL)),y)
ASTERISK_EXTRAS+=iksemel
ASTERISK_CONFIGURE_ARGS+= \
			--with-iksemel="$(STAGING_DIR)/usr"
endif

ifeq ($(strip $(BR2_PACKAGE_LIBPRI)),y)
ASTERISK_EXTRAS+=libpri
ASTERISK_CONFIGURE_ARGS+= \
			--with-pri="$(STAGING_DIR)/usr"
endif

ifeq ($(strip $(BR2_PACKAGE_LIBSRTP)),y)
ASTERISK_EXTRAS+=libsrtp
ASTERISK_CONFIGURE_ARGS+= \
			--with-srtp="$(STAGING_DIR)/usr"
endif

ifeq ($(strip $(BR2_PACKAGE_UW_IMAP)),y)
ASTERISK_EXTRAS+=uw-imap
ASTERISK_CONFIGURE_ARGS+= \
			--with-imap="$(BUILD_DIR)/uw-imap-2007f"
endif

ifeq ($(strip $(BR2_PACKAGE_NETSNMP)),y)
ASTERISK_EXTRAS+=netsnmp
ASTERISK_CONFIGURE_ARGS+= \
			--with-netsnmp
ASTERISK_CONFIGURE_ENV+= \
			CONFIG_NETSNMP="$(STAGING_DIR)/usr/bin/net-snmp-config"
else
ASTERISK_CONFIGURE_ARGS+= \
			--without-netsnmp
endif

ifeq ($(strip $(BR2_PACKAGE_MYSQL_CLIENT)),y)
ASTERISK_EXTRAS+=mysql_client
ASTERISK_CONFIGURE_ARGS+= \
			--with-mysqlclient
ASTERISK_CONFIGURE_ENV+= \
			CONFIG_MYSQLCLIENT="$(STAGING_DIR)/usr/bin/mysql_config"
endif

ifeq ($(strip $(BR2_PACKAGE_UNIXODBC)),y)
ASTERISK_EXTRAS+=unixodbc
ASTERISK_CONFIGURE_ARGS+= \
			--with-unixodbc="$(STAGING_DIR)/usr"
endif

ifeq ($(strip $(BR2_PACKAGE_ALSA_LIB)),y)
ASTERISK_EXTRAS+=alsa-lib
ASTERISK_CONFIGURE_ARGS+= \
			--with-asound="$(STAGING_DIR)/usr"
endif

ifeq ($(strip $(BR2_PACKAGE_SPANDSP)),y)
ASTERISK_EXTRAS+=spandsp
endif

ifeq ($(strip $(BR2_PACKAGE_DAHDI_LINUX)),y)
ASTERISK_EXTRAS+=dahdi-tools
ASTERISK_CONFIGURE_ARGS+= \
			--with-dahdi="$(STAGING_DIR)/usr" \
			--with-tonezone="$(STAGING_DIR)/usr"
else
ASTERISK_CONFIGURE_ARGS+= \
			--without-dahdi \
			--without-tonezone
endif

ifeq ($(strip $(BR2_PACKAGE_SQLITE)),y)
ASTERISK_EXTRAS+=sqlite
ASTERISK_CONFIGURE_ARGS+= \
                        --with-sqlite3="$(STAGING_DIR)/usr"
endif

ifeq ($(strip $(BR2_PACKAGE_CURL)),y)
ASTERISK_EXTRAS+=libcurl
ASTERISK_CONFIGURE_ARGS+= \
			--with-libcurl="$(STAGING_DIR)"
ASTERISK_CONFIGURE_ENV+= \
			LIBCURL="-lcurl -lz -lssl" \
			_libcurl_config="$(STAGING_DIR)/usr/bin/curl-config"
endif

ifeq ($(strip $(BR2_PACKAGE_NEON)),y)
 ifeq ($(strip $(BR2_PACKAGE_LIBICAL)),y)
ASTERISK_EXTRAS+=neon libical
ASTERISK_CONFIGURE_ARGS+= \
			--with-neon \
			--with-neon29 \
			--with-ical
ASTERISK_CONFIGURE_ENV+= \
			CONFIG_NEON="$(STAGING_DIR)/usr/bin/neon-config" \
			CONFIG_NEON29="$(STAGING_DIR)/usr/bin/neon-config"
 endif
endif

ifeq ($(strip $(BR2_PACKAGE_UNBOUND)),y)
ASTERISK_EXTRAS+=unbound
ASTERISK_CONFIGURE_ARGS+= \
                        --with-unbound="$(STAGING_DIR)/usr"
endif

ifeq ($(strip $(BR2_PACKAGE_PJSIP)),y)
ASTERISK_EXTRAS+=pjsip
ASTERISK_CONFIGURE_ARGS+= \
                        --without-pjproject-bundled \
                        --with-pjproject="$(STAGING_DIR)/usr"
else
 ifeq ($(strip $(BR2_PACKAGE_PJSIP_AST20)),y)
ASTERISK_EXTRAS+=pjsip-ast20
ASTERISK_CONFIGURE_ARGS+= \
                        --without-pjproject-bundled \
                        --with-pjproject="$(STAGING_DIR)/usr"
 else
ASTERISK_CONFIGURE_ARGS+= \
                        --without-pjproject-bundled \
                        --without-pjproject
 endif
endif

ifeq ($(strip $(BR2_PACKAGE_JANSSON)),y)
ASTERISK_EXTRAS+=jansson
ASTERISK_CONFIGURE_ARGS+= \
                        --with-jansson="$(STAGING_DIR)/usr"
endif

ifeq ($(strip $(BR2_PACKAGE_LIBURIPARSER)),y)
ASTERISK_EXTRAS+=liburiparser
ASTERISK_CONFIGURE_ARGS+= \
                        --with-uriparser="$(STAGING_DIR)/usr"
endif

ifeq ($(strip $(BR2_PACKAGE_LIBXSLT)),y)
ASTERISK_EXTRAS+=libxslt
ASTERISK_CONFIGURE_ARGS+= \
                        --with-libxslt="$(STAGING_DIR)/usr"
else
ASTERISK_CONFIGURE_ARGS+= \
                        --without-libxslt
endif

#$(DL_DIR)/$(ASTERISK_SOURCE):
#	$(WGET) -P $(DL_DIR) $(ASTERISK_SITE)/$(ASTERISK_SOURCE)

#$(ASTERISK_DIR)/.source: $(DL_DIR)/$(ASTERISK_SOURCE)
#	zcat $(DL_DIR)/$(ASTERISK_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
#	touch $@

define ASTERISK_APPLY_CUSTOM_PATCHES
	$(APPLY_PATCHES) $(ASTERISK_DIR) package/asterisk/astlinux/patches/ asterisk-$(ASTERISK_VERSION_SINGLE)$(ASTERISK_LABEL)-\*.patch
	$(APPLY_PATCHES) $(ASTERISK_DIR) package/asterisk/astlinux/patches/ asterisk-$(ASTERISK_VERSION_TUPLE)-\*.patch
	touch $(@D)
endef

ASTERISK_POST_PATCH_HOOKS += ASTERISK_APPLY_CUSTOM_PATCHES

ASTERISK_DEPENDENCIES += host-automake host-pkgconf host-ncurses host-bison host-flex host-libxml2 \
			ncurses zlib openssl libtool util-linux $(ASTERISK_EXTRAS)

define ASTERISK_CONFIGURE_CMDS
	(cd $(ASTERISK_DIR); rm -rf config.cache configure; \
		$(HOST_CONFIGURE_OPTS) \
		./bootstrap.sh; \
		$(TARGET_CONFIGURE_OPTS) \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
		--exec-prefix=/usr \
		--datadir=/usr/share \
		--sysconfdir=/etc \
		$(ASTERISK_CONFIGURE_ARGS) \
		$(ASTERISK_CONFIGURE_ENV) \
		CFLAGS='$(TARGET_CFLAGS)' \
		CPPFLAGS='$(TARGET_CFLAGS)' \
		LIBS='$(ASTERISK_LIBS)' \
	)
	(cd $(ASTERISK_DIR)/menuselect; \
		$(HOST_CONFIGURE_OPTS) \
		./configure \
	)
	$(HOST_MAKE_ENV) LD_RUN_PATH="$(HOST_DIR)/lib" \
	$(MAKE) -C $(ASTERISK_DIR)/menuselect menuselect
endef

ifeq ($(BR2_PACKAGE_ASTERISK_MENUSELECT),y)

define ASTERISK_CONFIGURE_CMDS_MENUSELECT
	$(HOST_MAKE_ENV) LD_RUN_PATH="$(HOST_DIR)/lib" \
	$(MAKE) -C $(ASTERISK_DIR) \
		GLOBAL_MAKEOPTS=$(ASTERISK_GLOBAL_MAKEOPTS) \
		USER_MAKEOPTS= \
		menuselect
endef
ASTERISK_POST_CONFIGURE_HOOKS += ASTERISK_CONFIGURE_CMDS_MENUSELECT

else #main else

define ASTERISK_CONFIGURE_CMDS_MENUSELECT
	$(HOST_MAKE_ENV) LD_RUN_PATH="$(HOST_DIR)/lib" \
	$(MAKE) -C $(ASTERISK_DIR) \
		GLOBAL_MAKEOPTS=$(ASTERISK_GLOBAL_MAKEOPTS) \
		USER_MAKEOPTS= \
		menuselect.makeopts
endef
ASTERISK_POST_CONFIGURE_HOOKS += ASTERISK_CONFIGURE_CMDS_MENUSELECT

ifeq ($(BR2_PACKAGE_MYSQL_CLIENT),y)
define ASTERISK_CONFIGURE_CMDS_MYSQL_CLIENT
	(cd $(ASTERISK_DIR); \
		menuselect/menuselect --enable app_mysql --enable cdr_mysql --enable res_config_mysql menuselect.makeopts; \
	)
endef
ASTERISK_POST_CONFIGURE_HOOKS += ASTERISK_CONFIGURE_CMDS_MYSQL_CLIENT
endif

 ifeq ($(BR2_PACKAGE_UW_IMAP),y)
define ASTERISK_CONFIGURE_CMDS_UW_IMAP
	(cd $(ASTERISK_DIR); \
		menuselect/menuselect --enable IMAP_STORAGE menuselect.makeopts; \
	)
endef
ASTERISK_POST_CONFIGURE_HOOKS += ASTERISK_CONFIGURE_CMDS_UW_IMAP
endif

ifeq ($(ASTERISK_VERSION_SINGLE),20)
define ASTERISK_CONFIGURE_CMDS_ASTERISK_SINGLE
	## Asterisk 20.x version
	(cd $(ASTERISK_DIR); \
		menuselect/menuselect --enable chan_sip menuselect.makeopts; \
	)
endef
ASTERISK_POST_CONFIGURE_HOOKS += ASTERISK_CONFIGURE_CMDS_ASTERISK_SINGLE
else
define ASTERISK_CONFIGURE_CMDS_ASTERISK_SINGLE
	## Asterisk 18.x version
	(cd $(ASTERISK_DIR); \
		menuselect/menuselect --enable res_pktccops --disable app_dahdiras menuselect.makeopts; \
	)
endef
ASTERISK_POST_CONFIGURE_HOOKS += ASTERISK_CONFIGURE_CMDS_ASTERISK_SINGLE
endif

define ASTERISK_CONFIGURE_CMDS_ASTERISK_ALL_VERSIONS
	## All Asterisk versions
	(cd $(ASTERISK_DIR); \
		menuselect/menuselect --enable ENABLE_SRTP_AES_192 --enable ENABLE_SRTP_AES_256 --enable ENABLE_SRTP_AES_GCM menuselect.makeopts; \
		menuselect/menuselect --enable app_meetme --enable app_page --enable app_macro menuselect.makeopts; \
		menuselect/menuselect --disable res_stir_shaken menuselect.makeopts; \
		menuselect/menuselect --disable CORE-SOUNDS-EN-GSM --disable MOH-OPSOUND-WAV menuselect.makeopts; \
		menuselect/menuselect --disable BUILD_NATIVE menuselect.makeopts; \
	)
endef
ASTERISK_POST_CONFIGURE_HOOKS += ASTERISK_CONFIGURE_CMDS_ASTERISK_ALL_VERSIONS

ifneq ($(BR2_PACKAGE_DAHDI_LINUX),y)
define ASTERISK_CONFIGURE_CMDS_DAHDI_LINUX
	## Disable DAHDI related modules
	(cd $(ASTERISK_DIR); \
		menuselect/menuselect --disable chan_dahdi --disable codec_dahdi --disable app_meetme menuselect.makeopts; \
		menuselect/menuselect --disable res_timing_dahdi --disable app_flash menuselect.makeopts; \
	)
endef
ASTERISK_POST_CONFIGURE_HOOKS += ASTERISK_CONFIGURE_CMDS_DAHDI_LINUX
endif

endif # main endif

define ASTERISK_CONFIGURE_CMDS_CLEAN
	# Don't force a "clean", create .lastclean
	cp -f $(ASTERISK_DIR)/.cleancount $(ASTERISK_DIR)/.lastclean
	touch $@
endef
ASTERISK_POST_CONFIGURE_HOOKS += ASTERISK_CONFIGURE_CMDS_CLEAN

define ASTERISK_BUILD_CMDS
	$(TARGET_MAKE_ENV) \
	$(MAKE) -C $(ASTERISK_DIR) \
		GLOBAL_MAKEOPTS=$(ASTERISK_GLOBAL_MAKEOPTS) \
		USER_MAKEOPTS= \
		ASTVARRUNDIR=/var/run/asterisk
endef

define ASTERISK_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) \
	$(MAKE1) -C $(ASTERISK_DIR) \
		GLOBAL_MAKEOPTS=$(ASTERISK_GLOBAL_MAKEOPTS) \
		USER_MAKEOPTS=menuselect.makeopts \
		ASTVARRUNDIR=/var/run/asterisk \
		SOUNDS_CACHE_DIR=$(DL_DIR) \
		DESTDIR=$(TARGET_DIR) install samples install-headers

	mv $(TARGET_DIR)/usr/include/asterisk.h \
	   $(TARGET_DIR)/usr/include/asterisk \
	   $(STAGING_DIR)/usr/include/
	rm -Rf $(TARGET_DIR)/usr/share/man
	$(INSTALL) -D -m 0755 package/asterisk/astlinux/asterisk.init $(TARGET_DIR)/etc/init.d/asterisk
	$(INSTALL) -D -m 0644 package/asterisk/astlinux/asterisk.logrotate $(TARGET_DIR)/etc/logrotate.d/asterisk
	$(INSTALL) -D -m 0755 package/asterisk/astlinux/upgrade-asterisk-sounds $(TARGET_DIR)/usr/sbin/upgrade-asterisk-sounds
	$(INSTALL) -D -m 0755 package/asterisk/astlinux/safe_asterisk $(TARGET_DIR)/usr/sbin/safe_asterisk
	$(INSTALL) -D -m 0755 package/asterisk/astlinux/asterisk-sip-monitor $(TARGET_DIR)/usr/sbin/asterisk-sip-monitor
	$(INSTALL) -D -m 0755 package/asterisk/astlinux/asterisk-sip-monitor-ctrl $(TARGET_DIR)/usr/sbin/asterisk-sip-monitor-ctrl
	$(INSTALL) -D -m 0755 $(ASTERISK_DIR)/contrib/scripts/ast_tls_cert $(TARGET_DIR)/usr/sbin/ast_tls_cert
	mkdir -p $(TARGET_DIR)/stat/var/lib/asterisk/licenses
	mv $(TARGET_DIR)/var/lib/asterisk/* $(TARGET_DIR)/stat/var/lib/asterisk/
	rmdir $(TARGET_DIR)/var/lib/asterisk
	rm -f $(TARGET_DIR)/stat/var/lib/asterisk/astdb
	ln -sf /var/db/astdb $(TARGET_DIR)/stat/var/lib/asterisk/astdb
	rm -f $(TARGET_DIR)/stat/var/lib/asterisk/astdb.sqlite3
	ln -sf /var/db/astdb.sqlite3 $(TARGET_DIR)/stat/var/lib/asterisk/astdb.sqlite3
	mkdir -p $(TARGET_DIR)/stat/var/spool
	mv $(TARGET_DIR)/var/spool/asterisk $(TARGET_DIR)/stat/var/spool/
	touch -c $(TARGET_DIR)/$(ASTERISK_TARGET_BINARY)
	rm -f $(TARGET_DIR)/etc/asterisk/*.old
	rm -f $(TARGET_DIR)/stat/var/lib/asterisk/mohmp3/*
	rm -f $(TARGET_DIR)/usr/sbin/astversion
# Remove unwanted MOH sound files to save space
	rm -f $(TARGET_DIR)/stat/var/lib/asterisk/moh/macroform-robot_dity.*
	rm -f $(TARGET_DIR)/stat/var/lib/asterisk/moh/macroform-cold_day.*
	mv $(TARGET_DIR)/etc/asterisk $(TARGET_DIR)/stat/etc/
	$(INSTALL) -D -m 0644 package/asterisk/astlinux/logger.conf $(TARGET_DIR)/stat/etc/asterisk/logger.conf

	ln -sf /tmp/etc/asterisk $(TARGET_DIR)/etc/asterisk
	ln -sf /var/tmp/asterisk/sounds/custom-sounds $(TARGET_DIR)/stat/var/lib/asterisk/sounds/custom-sounds
	ln -sf /var/tmp/asterisk/agi-bin/custom-agi $(TARGET_DIR)/stat/var/lib/asterisk/agi-bin/custom-agi

	if [ -d $(TARGET_DIR)/usr/share/snmp/mibs ]; then \
	  $(INSTALL) -D -m 0644 package/asterisk/astlinux/mibs/ASTERISK-MIB.txt $(TARGET_DIR)/usr/share/snmp/mibs/ ; \
	  $(INSTALL) -D -m 0644 package/asterisk/astlinux/mibs/DIGIUM-MIB.txt $(TARGET_DIR)/usr/share/snmp/mibs/ ; \
	fi
endef

#asterisk: $(TARGET_DIR)/$(ASTERISK_TARGET_BINARY)

#asterisk-patch: $(ASTERISK_DIR)/.patched

#asterisk-clean:
#	rm -Rf $(STAGING_DIR)/usr/include/asterisk
#	rm -Rf $(TARGET_DIR)/stat/etc/asterisk
#	rm -Rf $(TARGET_DIR)/etc/asterisk
#	rm -Rf $(TARGET_DIR)/usr/lib/asterisk
#	rm -Rf $(TARGET_DIR)/stat/var/lib/asterisk
#	rm -Rf $(TARGET_DIR)/stat/var/spool/asterisk
#	rm -Rf $(TARGET_DIR)/var/lib/asterisk
#	rm -Rf $(TARGET_DIR)/var/spool/asterisk
#	rm -f $(TARGET_DIR)/etc/init.d/asterisk
#	rm -f $(TARGET_DIR)/usr/sbin/upgrade-asterisk-sounds
#	rm -f $(TARGET_DIR)/usr/sbin/safe_asterisk
#	rm -f $(TARGET_DIR)/usr/sbin/asterisk-sip-monitor
#	rm -f $(TARGET_DIR)/usr/sbin/asterisk-sip-monitor-ctrl
#	rm -f $(TARGET_DIR)/usr/sbin/ast_tls_cert
#	rm -f $(TARGET_DIR)/usr/sbin/stereorize
#	rm -f $(TARGET_DIR)/usr/sbin/streamplayer
#	rm -rf $(STAGING_DIR)/usr/include/asterisk
#	rm -Rf $(TARGET_DIR)/stat/var/lib/asterisk
#	rm -Rf $(TARGET_DIR)/stat/var/spool/asterisk
#	rm -Rf $(TARGET_DIR)/stat/etc/asterisk
#	rm -f $(TARGET_DIR)/usr/share/snmp/mibs/ASTERISK-MIB.txt
#	rm -f $(TARGET_DIR)/usr/share/snmp/mibs/DIGIUM-MIB.txt
#	-$(MAKE) -C $(ASTERISK_DIR) clean
#	rm -rf $(BUILD_DIR)/asterisk-$(ASTERISK_VERSION)

#asterisk-sounds-clean:
#	rm -rf $(TARGET_DIR)/stat/var/lib/asterisk/sounds

#asterisk-moh-clean:
#	rm -rf $(TARGET_DIR)/stat/var/lib/asterisk/mohmp3
#	rm -rf $(TARGET_DIR)/stat/etc/asterisk/musiconhold.conf

#asterisk-dirclean:
#	rm -rf $(ASTERISK_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
#ifeq ($(strip $(BR2_PACKAGE_ASTERISK)),y)
#TARGETS+=asterisk
#endif

$(eval $(generic-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# asterisk
#
################################################################################

# When bumping asterisk's version, verify that the versions of pjsip,
# libjwt and sounds below are still matching.
ASTERISK_VERSION = 22.10.1
# Use the github mirror: it's an official mirror maintained by Digium, and
# provides tarballs, which the main Asterisk git tree (behind Gerrit) does not.
ASTERISK_SITE = $(call github,asterisk,asterisk,$(ASTERISK_VERSION))

# compilation with the external pjsip produces a non-working asterisk, which
# segfaults. The reason behind this is unclear.
# https://github.com/asterisk/asterisk/issues/671
ASTERISK_PJSIP_URL = https://raw.githubusercontent.com/asterisk/third-party/master/pjproject/2.17/
ASTERISK_LIBJWT_URL = https://raw.githubusercontent.com/asterisk/third-party/master/libjwt/1.15.3/
ASTERISK_SOUNDS_BASE_URL = http://downloads.asterisk.org/pub/telephony/sounds/releases
ASTERISK_EXTRA_DOWNLOADS = \
	$(ASTERISK_SOUNDS_BASE_URL)/asterisk-core-sounds-en-gsm-1.6.1.tar.gz \
	$(ASTERISK_SOUNDS_BASE_URL)/asterisk-moh-opsound-wav-2.03.tar.gz \
	$(ASTERISK_PJSIP_URL)/pjproject-2.17.tar.bz2 \
	$(ASTERISK_LIBJWT_URL)/libjwt-1.15.3.tar.gz

ASTERISK_LICENSE = GPL-2.0, BSD-3-Clause (SHA1, resample), BSD-4-Clause (db1-ast)
ASTERISK_LICENSE_FILES = \
	COPYING \
	main/sha1.c \
	codecs/speex/speex_resampler.h \
	utils/db1-ast/include/db.h

ASTERISK_CPE_ID_VENDOR = sangoma
ASTERISK_SELINUX_MODULES = asterisk

# For patches 0002 and 0003
ASTERISK_AUTORECONF = YES
ASTERISK_AUTORECONF_OPTS = -Iautoconf -Ithird-party -Ithird-party/pjproject -Ithird-party/jansson -Ithird-party/libjwt

ASTERISK_DEPENDENCIES = \
	host-asterisk \
	host-pkgconf \
	jansson \
	libcurl \
	libedit \
	libpjsip \
	libxml2 \
	sqlite \
	util-linux

# Asterisk wants to run its menuselect tool (a highly tweaked derivative of
# kconfig), but builds it using the target tools. So we build it in the host
# variant (see below), and copy the full build tree of menuselect.
define ASTERISK_COPY_MENUSELECT
	rm -rf $(@D)/menuselect
	cp -a $(HOST_ASTERISK_DIR)/menuselect $(@D)/menuselect
endef
ASTERISK_PRE_CONFIGURE_HOOKS += ASTERISK_COPY_MENUSELECT

ASTERISK_CONF_OPTS = \
	--disable-xmldoc \
	--disable-internal-poll \
	--disable-asteriskssl \
	--disable-rpath \
	--without-bfd \
	--without-cap \
	--without-cpg \
	--without-gtk2 \
	--without-gmime \
	--without-hoard \
	--without-iconv \
	--without-iksemel \
	--without-imap \
	--without-inotify \
	--without-iodbc \
	--without-jack \
	--without-uriparser \
	--without-kqueue \
	--without-libedit \
	--without-libxslt \
	--without-lua \
	--without-mysqlclient \
	--without-neon29 \
	--without-newt \
	--without-openr2 \
	--without-postgres \
	--without-popt \
	--without-resample \
	--without-sdl \
	--without-SDL_image \
	--without-tds \
	--without-timerfd \
	--without-unbound \
	--without-unixodbc \
	--without-x11 \
	--with-crypt \
	--with-jansson \
	--with-libcurl \
	--with-ilbc \
	--with-libjwt-bundled \
	--with-libxml2 \
	--with-libedit="$(STAGING_DIR)/usr" \
	--with-pjproject-bundled \
	--with-sqlite3="$(STAGING_DIR)/usr" \
	--with-download-cache=$(ASTERISK_DL_DIR)

# avcodec are from ffmpeg. There is virtually zero chance this could
# even work; asterisk is looking for ffmpeg/avcodec.h which has not
# been installed in this location since early 2007 (~10 years ago at
# the time of this writing).
ASTERISK_CONF_OPTS += --without-avcodec

# asterisk is not compatible with freeswitch spandsp
ASTERISK_CONF_OPTS += --without-spandsp

ASTERISK_CONF_ENV = \
	ac_cv_file_bridges_bridge_softmix_include_hrirs_h=true

# Uses __atomic_fetch_add_4
ifeq ($(BR2_TOOLCHAIN_HAS_LIBATOMIC),y)
ASTERISK_LIBS += -latomic
endif

ifeq ($(BR2_PACKAGE_LIBYUV)$(BR2_PACKAGE_JPEG),yy)
ASTERISK_LIBS += -ljpeg
endif

ASTERISK_CONF_ENV += LIBS="$(ASTERISK_LIBS)"

ifeq ($(BR2_TOOLCHAIN_USES_GLIBC),y)
ASTERISK_CONF_OPTS += --with-execinfo
else
ASTERISK_CONF_OPTS += --without-execinfo
endif

ifeq ($(BR2_PACKAGE_LIBGSM),y)
ASTERISK_DEPENDENCIES += libgsm
ASTERISK_CONF_OPTS += --with-gsm
else
ASTERISK_CONF_OPTS += --without-gsm
endif

ifeq ($(BR2_PACKAGE_BLUEZ5_UTILS),y)
ASTERISK_DEPENDENCIES += bluez5_utils
ASTERISK_CONF_OPTS += --with-bluetooth
else
ASTERISK_CONF_OPTS += --without-bluetooth
endif

ifeq ($(BR2_PACKAGE_LIBICAL),y)
ASTERISK_DEPENDENCIES += libical
ASTERISK_CONF_OPTS += --with-ical
else
ASTERISK_CONF_OPTS += --without-ical
endif

ifeq ($(BR2_PACKAGE_OPENLDAP),y)
ASTERISK_DEPENDENCIES += openldap
ASTERISK_CONF_OPTS += --with-ldap
else
ASTERISK_CONF_OPTS += --without-ldap
endif

ifeq ($(BR2_PACKAGE_NEON),y)
ASTERISK_DEPENDENCIES += neon
ASTERISK_CONF_OPTS += --with-neon
ASTERISK_CONF_ENV += \
	ac_cv_path_CONFIG_NEON=$(STAGING_DIR)/usr/bin/neon-config
else
ASTERISK_CONF_OPTS += --without-neon
endif

ifeq ($(BR2_PACKAGE_NETSNMP),y)
ASTERISK_DEPENDENCIES += netsnmp
ASTERISK_CONF_OPTS += --with-netsnmp=$(STAGING_DIR)/usr
else
ASTERISK_CONF_OPTS += --without-netsnmp
endif

ifeq ($(BR2_PACKAGE_LIBOGG),y)
ASTERISK_DEPENDENCIES += libogg
ASTERISK_CONF_OPTS += --with-ogg
else
ASTERISK_CONF_OPTS += --without-ogg
endif

ifeq ($(BR2_PACKAGE_OPUS),y)
ASTERISK_DEPENDENCIES += opus
ASTERISK_CONF_OPTS += --with-opus
else
ASTERISK_CONF_OPTS += --without-opus
endif

ifeq ($(BR2_PACKAGE_PORTAUDIO),y)
ASTERISK_DEPENDENCIES += portaudio
ASTERISK_CONF_OPTS += --with-portaudio
else
ASTERISK_CONF_OPTS += --without-portaudio
endif

ifeq ($(BR2_PACKAGE_FREERADIUS_CLIENT),y)
ASTERISK_DEPENDENCIES += freeradius-client
ASTERISK_CONF_OPTS += --with-radius
else
ASTERISK_CONF_OPTS += --without-radius
endif

ifeq ($(BR2_PACKAGE_DAHDI_LINUX)$(BR2_PACKAGE_DAHDI_TOOLS),yy)
ASTERISK_DEPENDENCIES += dahdi-linux dahdi-tools
ASTERISK_CONF_OPTS += --with-dahdi --with-tonezone

ifeq ($(BR2_PACKAGE_LIBPRI),y)
ASTERISK_DEPENDENCIES += libpri
ASTERISK_CONF_OPTS += --with-pri
else
ASTERISK_CONF_OPTS += --without-pri
endif # PRI

ifeq ($(BR2_PACKAGE_LIBSS7),y)
ASTERISK_DEPENDENCIES += libss7
ASTERISK_CONF_OPTS += --with-ss7
else
ASTERISK_CONF_OPTS += --without-ss7
endif # SS7

else
ASTERISK_CONF_OPTS += \
	--without-dahdi --without-tonezone \
	--without-pri --without-ss7
endif # DAHDI

ifeq ($(BR2_PACKAGE_OPENSSL),y)
ASTERISK_DEPENDENCIES += openssl
ASTERISK_CONF_OPTS += --with-ssl
else
ASTERISK_CONF_OPTS += --without-ssl
endif

ifeq ($(BR2_PACKAGE_LIBXCRYPT),y)
# --with-crypt is unconditional, relies on the C library if present
ASTERISK_DEPENDENCIES += libxcrypt
endif

ifeq ($(BR2_PACKAGE_SPEEX)$(BR2_PACKAGE_SPEEXDSP),yy)
ASTERISK_DEPENDENCIES += speex
ASTERISK_CONF_OPTS += --with-speex --with-speexdsp
else
ASTERISK_CONF_OPTS += --without-speex --without-speexdsp
endif

# asterisk needs an openssl-enabled libsrtp
ifeq ($(BR2_PACKAGE_LIBSRTP)$(BR2_PACKAGE_OPENSSL),yy)
ASTERISK_DEPENDENCIES += libsrtp
ASTERISK_CONF_OPTS += --with-srtp
else
ASTERISK_CONF_OPTS += --without-srtp
endif

ifeq ($(BR2_PACKAGE_LIBVORBIS),y)
ASTERISK_DEPENDENCIES += libvorbis
ASTERISK_CONF_OPTS += --with-vorbis
else
ASTERISK_CONF_OPTS += --without-vorbis
endif

ifeq ($(BR2_PACKAGE_ZLIB),y)
ASTERISK_DEPENDENCIES += zlib
ASTERISK_CONF_OPTS += --with-z
else
ASTERISK_CONF_OPTS += --without-z
endif

ASTERISK_DIRS = \
	ASTVARLIBDIR="/usr/lib/asterisk" \
	ASTDATADIR="/usr/lib/asterisk" \
	ASTKEYDIR="/usr/lib/asterisk" \
	ASTDBDIR="/usr/lib/asterisk"

ASTERISK_MAKE_OPTS = $(ASTERISK_DIRS)

# Uses __atomic_fetch_add_4
ifeq ($(BR2_TOOLCHAIN_HAS_LIBATOMIC),y)
ASTERISK_MAKE_OPTS += ASTLDFLAGS="-latomic"
endif

# Remove default -O3 optimization flag
ASTERISK_MAKE_OPTS += OPTIMIZE=""

ASTERISK_CFLAGS = $(TARGET_CFLAGS)

ASTERISK_CONF_OPTS += CFLAGS="$(ASTERISK_CFLAGS)"

# We want to install sample configuration files, too.
ASTERISK_INSTALL_TARGET_OPTS = \
	$(ASTERISK_DIRS) \
	DESTDIR=$(TARGET_DIR) \
	LDCONFIG=true \
	install samples

define ASTERISK_USERS
	asterisk -1 asterisk -1 * /usr/lib/asterisk - - asterisk user
endef

define ASTERISK_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 package/asterisk/asterisk.service \
		$(TARGET_DIR)/usr/lib/systemd/system/asterisk.service
endef

$(eval $(autotools-package))

#-------------------------------------------------------------------------------
# This part deals with building the menuselect tool as a host package

HOST_ASTERISK_DEPENDENCIES = host-pkgconf host-libxml2 host-ncurses
HOST_ASTERISK_SUBDIR = menuselect

HOST_ASTERISK_LICENSE = GPL-2.0
HOST_ASTERISK_LICENSE_FILES = COPYING

# No need to autoreconf for the host variant,
# so do not inherit the target setup.
HOST_ASTERISK_AUTORECONF = NO

HOST_ASTERISK_CONF_OPTS = \
	--without-newt \
	--without-curses \
	--with-ncurses=$(HOST_DIR)

# Not an automake package, so does not inherit LDFLAGS et al. from
# the configure run.
HOST_ASTERISK_MAKE_ENV = $(HOST_CONFIGURE_OPTS)

# Even though menuselect is an autotools package, it is not an automake
# package and does not have an 'install' rule, as asterisk does expect
# it to be in a sub-directory of its source tree. We do so by copying
# the full menuselect build tree as a pre-configure hook in the target
# variant.
# However, the sanity checks on host packages are not run on menuselect.
# But we still want to catch that menuselect has the proper rpath set,
# for example, as it uses host libraries that we do build, like
# host-libxml2.
# So we do manually install the menuselect tool.
define HOST_ASTERISK_INSTALL_CMDS
	$(INSTALL) -D -m 0755 $(@D)/menuselect/menuselect \
		$(HOST_DIR)/bin/asterisk-menuselect
endef

$(eval $(host-autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
