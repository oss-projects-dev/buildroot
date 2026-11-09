ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# perl
#
#############################################################

PERL_VERSION_MAJOR = 24
PERL_VERSION = 5.$(PERL_VERSION_MAJOR).4
PERL_SITE = https://www.cpan.org/src/5.0
PERL_CUSTOM_PATCH_DIR = astlinux
PERL_SOURCE = perl-$(PERL_VERSION).tar.xz
PERL_INSTALL_STAGING = YES
# Depend on linux to define LINUX_VERSION_PROBED
PERL_DEPENDENCIES = linux

PERL_ARCHNAME = $(ARCH)-linux

PERL_MODULES = constant version base fields
PERL_MODULES += Carp Errno Fcntl PathTools POSIX Digest Socket IO XSLoader Exporter B File-Find JSON-PP
PERL_MODULES += Digest/MD5 Digest/SHA Getopt/Long Time/Local File/Glob Sys/Hostname

PERL_CROSS_VERSION = 1.3.5
PERL_CROSS_SITE = https://github.com/arsv/perl-cross/releases/download/$(PERL_CROSS_VERSION)
PERL_CUSTOM_PATCH_DIR = astlinux
PERL_CROSS_SOURCE = perl-cross-$(PERL_CROSS_VERSION).tar.gz
PERL_EXTRA_DOWNLOADS = $(PERL_CROSS_SITE)/$(PERL_CROSS_SOURCE)

# We use the perlcross hack to cross-compile perl. It should
# be extracted over the perl sources, so we don't define that
# as a separate package. Instead, it is downloaded and extracted
# together with perl

define PERL_CROSS_DOWNLOAD
	$(call DOWNLOAD,$(PERL_CROSS_SITE),$(PERL_CROSS_SOURCE))
endef
#PERL_POST_DOWNLOAD_HOOKS += PERL_CROSS_DOWNLOAD

define PERL_CROSS_EXTRACT
	$(INFLATE$(suffix $(PERL_CROSS_SOURCE))) $(DL_DIR)/$(PERL_CROSS_SOURCE) | \
	$(TAR) $(TAR_STRIP_COMPONENTS)=1 -C $(@D) $(TAR_OPTIONS) -
endef
PERL_POST_EXTRACT_HOOKS += PERL_CROSS_EXTRACT

ifeq ($(BR2_PACKAGE_BERKELEYDB),y)
PERL_DEPENDENCIES += berkeleydb
endif

# We have to override LD, because an external multilib toolchain ld is not
# wrapped to provide the required sysroot options.  We also can't use ccache
# because the configure script doesn't support it.
PERL_CONF_OPTS = \
	--target=$(GNU_TARGET_NAME) \
	--target-tools-prefix=$(TARGET_CROSS) \
	--prefix=/usr \
	-Dsitelib=/mnt/kd/perl \
	-Dld="$(TARGET_CC)" \
	-Dccflags="$(TARGET_CFLAGS) -DAPPLLIB_EXP=\\\"/mnt/kd/perl:/usr/local/share/perl\\\" " \
	-Dldflags="$(TARGET_LDFLAGS) -lm" \
	-Dmydomain="" \
	-Dmyhostname="$(BR2_TARGET_GENERIC_HOSTNAME)" \
	-Dmyuname="Buildroot $(BR2_VERSION_FULL)" \
	-Dosname=linux \
	-Dosvers=$(LINUX_VERSION_PROBED) \
	-Dperladmin=root

ifeq ($(shell expr $(PERL_VERSION_MAJOR) % 2), 1)
PERL_CONF_OPTS += -Dusedevel
endif

ifneq ($(BR2_LARGEFILE),y)
PERL_CONF_OPTS += -Uuselargefiles
endif

ifneq ($(PERL_MODULES),)
PERL_CONF_OPTS += --only-mod=$(subst $(space),$(comma),$(PERL_MODULES))
endif

define PERL_CONFIGURE_CMDS
	(cd $(@D); $(TARGET_MAKE_ENV) HOSTCC='$(HOSTCC_NOCACHE)' \
		./configure $(PERL_CONF_OPT))
	$(SED) 's/UNKNOWN-/Buildroot $(BR2_VERSION_FULL) /' $(@D)/patchlevel.h
endef

define PERL_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D) all
endef

define PERL_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D) DESTDIR="$(STAGING_DIR)" install.perl install.sym
endef

define PERL_INSTALL_TARGET_CMDS
	# Undefine utils.lst file so cpan, corelist, ... perlthanks are not installed, keep shasum
	echo "utils/shasum" > $(@D)/utils.lst
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D) DESTDIR="$(TARGET_DIR)" install.perl install.sym
	# Remove CORE dir
	rm -rf $(TARGET_DIR)/usr/lib/perl5/$(PERL_VERSION)/$(PERL_ARCHNAME)/CORE
	# Remove all .pod files
	find $(TARGET_DIR)/usr/lib/perl5/ -name '*.pod' -print0 | xargs -0 rm -f
	# Remove many unicore files
	rm -rf $(TARGET_DIR)/usr/lib/perl5/$(PERL_VERSION)/unicore/lib/
	rm -rf $(TARGET_DIR)/usr/lib/perl5/$(PERL_VERSION)/unicore/To/
	rm -f $(TARGET_DIR)/usr/lib/perl5/$(PERL_VERSION)/unicore/Name.pl
	# Remove misc files
	find $(TARGET_DIR)/usr/lib/perl5/ -name '.packlist' -print0 | xargs -0 rm -f
endef

define PERL_CLEAN_CMDS
	-$(MAKE1) -C $(@D) clean
	rm -rf $(TARGET_DIR)/usr/lib/perl5/
	rm -f $(TARGET_DIR)/usr/bin/perl
endef

$(eval $(generic-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# perl
#
################################################################################

# When updating the version here, also update utils/scancpan
PERL_VERSION_MAJOR = 40
PERL_VERSION = 5.$(PERL_VERSION_MAJOR).5
PERL_SITE = https://www.cpan.org/src/5.0
PERL_SOURCE = perl-$(PERL_VERSION).tar.xz
PERL_LICENSE = Artistic or GPL-1.0+
PERL_LICENSE_FILES = Artistic Copying README
PERL_CPE_ID_VENDOR = perl
PERL_DEPENDENCIES = $(TARGET_NLS_DEPENDENCIES)
PERL_INSTALL_STAGING = YES

PERL_CROSS_VERSION = 1.6.4
# DO NOT refactor with the github helper (the result is not the same)
PERL_CROSS_SITE = https://github.com/arsv/perl-cross/releases/download/$(PERL_CROSS_VERSION)
PERL_CROSS_SOURCE = perl-cross-$(PERL_CROSS_VERSION).tar.gz
PERL_EXTRA_DOWNLOADS = $(PERL_CROSS_SITE)/$(PERL_CROSS_SOURCE)

# We use the perlcross hack to cross-compile perl. It should
# be extracted over the perl sources, so we don't define that
# as a separate package. Instead, it is downloaded and extracted
# together with perl
define PERL_CROSS_EXTRACT
	$(call suitable-extractor,$(PERL_CROSS_SOURCE)) $(PERL_DL_DIR)/$(PERL_CROSS_SOURCE) | \
	$(TAR) --strip-components=1 -C $(@D) $(TAR_OPTIONS) -
	mv $(@D)/cnf/diffs/perl5-5.40.3 $(@D)/cnf/diffs/perl5-5.40.5
endef
PERL_POST_EXTRACT_HOOKS += PERL_CROSS_EXTRACT

# We need to patch perl-cross, but perl-cross is extracted over the
# target perl sources only (and not the host variant). So we apply the
# patch only for the target case using a post patch hook.
define PERL_CROSS_PATCH
	$(APPLY_PATCHES) $(@D) $(PERL_PKGDIR)/perl-cross \
		0001-configure-keep-_GNU_SOURCE-in-build-flags.patch
endef
PERL_POST_PATCH_HOOKS += PERL_CROSS_PATCH

# Even though perl is not an autotools-package, it uses config.sub and
# config.guess. Up-to-date versions of these files may be needed to build perl
# on newer host architectures, so we borrow the hook which updates them from the
# autotools infrastructure.
PERL_POST_PATCH_HOOKS += UPDATE_CONFIG_HOOK

ifeq ($(BR2_PACKAGE_BERKELEYDB),y)
PERL_DEPENDENCIES += berkeleydb
endif
ifeq ($(BR2_PACKAGE_GDBM),y)
PERL_DEPENDENCIES += gdbm
endif

# We have to override LD, because an external multilib toolchain ld is not
# wrapped to provide the required sysroot options.
PERL_CONF_OPTS = \
	--target=$(GNU_TARGET_NAME) \
	--target-tools-prefix=$(TARGET_CROSS) \
	--prefix=/usr \
	-Dld="$(TARGET_CC)" \
	-Dccflags="$(TARGET_CFLAGS)" \
	-Dldflags="$(TARGET_LDFLAGS) -lm $(TARGET_NLS_LIBS)" \
	-Dmydomain="" \
	-Dmyhostname="noname" \
	-Dmyuname="Buildroot $(BR2_VERSION_FULL)" \
	-Dosname=linux \
	-Dosvers=$(LINUX_VERSION) \
	-Dperladmin=root

ifeq ($(shell expr $(PERL_VERSION_MAJOR) % 2), 1)
PERL_CONF_OPTS += -Dusedevel
endif

ifeq ($(BR2_PACKAGE_PERL_THREADS),y)
PERL_CONF_OPTS += -Dusethreads
endif

ifeq ($(BR2_STATIC_LIBS),y)
PERL_CONF_OPTS += --all-static --no-dynaloader
endif

PERL_MODULES = $(call qstrip,$(BR2_PACKAGE_PERL_MODULES))
ifneq ($(PERL_MODULES),)
PERL_CONF_OPTS += --only-mod=$(subst $(space),$(comma),$(PERL_MODULES))
endif

define PERL_CONFIGURE_CMDS
	(cd $(@D); $(TARGET_MAKE_ENV) HOSTCC='$(HOSTCC_NOCCACHE)' \
		./configure $(PERL_CONF_OPTS))
	$(SED) 's/UNKNOWN-/Buildroot $(subst /,\/,$(BR2_VERSION_FULL)) /' $(@D)/patchlevel.h
endef

define PERL_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D) all
endef

define PERL_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D) DESTDIR="$(STAGING_DIR)" install.perl install.sym
endef

define PERL_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D) DESTDIR="$(TARGET_DIR)" install.perl install.sym
endef

HOST_PERL_CONF_OPTS = \
	-des \
	-Dprefix="$(HOST_DIR)" \
	-Dcc="$(HOSTCC)" \
	-Dccflags="$(HOST_CFLAGS)" \
	-Dldflags="$(HOST_LDFLAGS)"

define HOST_PERL_CONFIGURE_CMDS
	(cd $(@D); $(HOST_MAKE_ENV) HOSTCC='$(HOSTCC_NOCCACHE)' \
		./Configure $(HOST_PERL_CONF_OPTS))
endef

define HOST_PERL_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D)
endef

define HOST_PERL_INSTALL_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) INSTALL_DEPENDENCE='' install
endef

$(eval $(generic-package))
$(eval $(host-generic-package))

define PERL_FINALIZE_TARGET
	rm -rf $(TARGET_DIR)/usr/lib/perl5/$(PERL_VERSION)/pod
	rm -rf $(TARGET_DIR)/usr/lib/perl5/$(PERL_VERSION)/$(PERL_ARCHNAME)/CORE
	find $(TARGET_DIR)/usr/lib/perl5/ -name 'extralibs.ld' -print0 | xargs -0 rm -f
	find $(TARGET_DIR)/usr/lib/perl5/ -name '*.bs' -print0 | xargs -0 rm -f
	find $(TARGET_DIR)/usr/lib/perl5/ -name '.packlist' -print0 | xargs -0 rm -f
endef
PERL_TARGET_FINALIZE_HOOKS += PERL_FINALIZE_TARGET

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
