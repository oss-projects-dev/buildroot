ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# libglib2
#
#############################################################
LIBGLIB2_VERSION_MAJOR = 2.46
LIBGLIB2_VERSION = $(LIBGLIB2_VERSION_MAJOR).2
LIBGLIB2_SOURCE = glib-$(LIBGLIB2_VERSION).tar.xz
LIBGLIB2_SITE = http://ftp.gnome.org/pub/gnome/sources/glib/$(LIBGLIB2_VERSION_MAJOR)
LIBGLIB2_CUSTOM_PATCH_DIR = astlinux
# 0002-disable-tests.patch
LIBGLIB2_AUTORECONF = YES

LIBGLIB2_INSTALL_STAGING = YES
LIBGLIB2_INSTALL_STAGING_OPTS = DESTDIR=$(STAGING_DIR) LDFLAGS=-L$(STAGING_DIR)/usr/lib install

LIBGLIB2_CONF_ENV = \
	ac_cv_func_posix_getpwuid_r=yes \
	glib_cv_stack_grows=no \
	glib_cv_uscore=no \
	ac_cv_func_strtod=yes \
	ac_fsusage_space=yes \
	fu_cv_sys_stat_statfs2_bsize=yes \
	ac_cv_func_closedir_void=no \
	ac_cv_func_getloadavg=no \
	ac_cv_lib_util_getloadavg=no \
	ac_cv_lib_getloadavg_getloadavg=no \
	ac_cv_func_getgroups=yes \
	ac_cv_func_getgroups_works=yes \
	ac_cv_func_chown_works=yes \
	ac_cv_have_decl_euidaccess=no \
	ac_cv_func_euidaccess=no \
	ac_cv_have_decl_strnlen=yes \
	ac_cv_func_strnlen_working=yes \
	ac_cv_func_lstat_dereferences_slashed_symlink=yes \
	ac_cv_func_lstat_empty_string_bug=no \
	ac_cv_func_stat_empty_string_bug=no \
	vb_cv_func_rename_trailing_slash_bug=no \
	ac_cv_have_decl_nanosleep=yes \
	jm_cv_func_nanosleep_works=yes \
	gl_cv_func_working_utimes=yes \
	ac_cv_func_utime_null=yes \
	ac_cv_have_decl_strerror_r=yes \
	ac_cv_func_strerror_r_char_p=no \
	jm_cv_func_svid_putenv=yes \
	ac_cv_func_getcwd_null=yes \
	ac_cv_func_getdelim=yes \
	ac_cv_func_mkstemp=yes \
	utils_cv_func_mkstemp_limitations=no \
	utils_cv_func_mkdir_trailing_slash_bug=no \
	jm_cv_func_gettimeofday_clobber=no \
	gl_cv_func_working_readdir=yes \
	jm_ac_cv_func_link_follows_symlink=no \
	utils_cv_localtime_cache=no \
	ac_cv_struct_st_mtim_nsec=no \
	gl_cv_func_tzset_clobber=no \
	gl_cv_func_getcwd_null=yes \
	gl_cv_func_getcwd_path_max=yes \
	ac_cv_func_fnmatch_gnu=yes \
	am_getline_needs_run_time_check=no \
	am_cv_func_working_getline=yes \
	gl_cv_func_mkdir_trailing_slash_bug=no \
	gl_cv_func_mkstemp_limitations=no \
	ac_cv_func_working_mktime=yes \
	jm_cv_func_working_re_compile_pattern=yes \
	ac_use_included_regex=no \
	gl_cv_c_restrict=no \
	ac_cv_path_GLIB_GENMARSHAL=$(HOST_DIR)/bin/glib-genmarshal \
	ac_cv_prog_F77=no \
	ac_cv_func_posix_getgrgid_r=no \
	glib_cv_long_long_format=ll \
	ac_cv_func_printf_unix98=yes \
	ac_cv_func_vsnprintf_c99=yes \
	ac_cv_func_newlocale=no \
	ac_cv_func_uselocale=no \
	ac_cv_func_strtod_l=no \
	ac_cv_func_strtoll_l=no \
	ac_cv_func_strtoull_l=no \
	gt_cv_c_wchar_t=$(if $(BR2_USE_WCHAR),yes,no)

LIBGLIB2_CONF_OPTS = \
	--disable-compile-warnings

HOST_LIBGLIB2_CONF_OPTS = \
	--disable-compile-warnings \
	--disable-coverage \
	--disable-dtrace \
	--disable-fam \
	--disable-libelf \
	--disable-selinux \
	--disable-systemtap \
	--disable-xattr

LIBGLIB2_DEPENDENCIES = host-pkgconf host-libglib2 libffi zlib $(if $(BR2_NEEDS_GETTEXT_IF_LOCALE),gettext libintl)

HOST_LIBGLIB2_DEPENDENCIES = host-pkgconf host-libffi host-zlib

ifneq ($(BR2_ENABLE_LOCALE),y)
LIBGLIB2_DEPENDENCIES += libiconv
endif

LIBGLIB2_CONF_OPTS += --disable-libelf

ifeq ($(BR2_PACKAGE_LIBICONV),y)
LIBGLIB2_CONF_OPTS += --with-libiconv=gnu
LIBGLIB2_DEPENDENCIES += libiconv
endif

LIBGLIB2_CONF_OPTS += --with-pcre=internal

define LIBGLIB2_REMOVE_DEV_FILES
	rm -rf $(TARGET_DIR)/usr/lib/glib-2.0
	rm -rf $(TARGET_DIR)/usr/share/glib-2.0/gettext
	rmdir --ignore-fail-on-non-empty $(TARGET_DIR)/usr/share/glib-2.0
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,glib-genmarshal glib-gettextize glib-mkenums gobject-query gtester gtester-report)
endef

LIBGLIB2_POST_INSTALL_TARGET_HOOKS += LIBGLIB2_REMOVE_DEV_FILES

define LIBGLIB2_REMOVE_GDB_FILES
	rm -rf $(TARGET_DIR)/usr/share/glib-2.0/gdb
	rmdir --ignore-fail-on-non-empty $(TARGET_DIR)/usr/share/glib-2.0
endef

ifneq ($(BR2_PACKAGE_GDB),y)
LIBGLIB2_POST_INSTALL_TARGET_HOOKS += LIBGLIB2_REMOVE_GDB_FILES
endif

define LIBGLIB2_REMOVE_BASH_COMPLETION_SCRIPTS
	rm -f $(TARGET_DIR)/usr/share/bash-completion/completions/gapplication
	rm -f $(TARGET_DIR)/usr/share/bash-completion/completions/gdbus
	rm -f $(TARGET_DIR)/usr/share/bash-completion/completions/gsettings
	rm -f $(TARGET_DIR)/usr/share/bash-completion/completions/gresource
	rmdir --ignore-fail-on-non-empty $(TARGET_DIR)/usr/share/bash-completion/completions
	rmdir --ignore-fail-on-non-empty $(TARGET_DIR)/usr/share/bash-completion
endef

LIBGLIB2_POST_INSTALL_TARGET_HOOKS += LIBGLIB2_REMOVE_BASH_COMPLETION_SCRIPTS

$(eval $(autotools-package))
$(eval $(host-autotools-package))

LIBGLIB2_HOST_BINARY:=$(HOST_DIR)/bin/glib-genmarshal

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# libglib2
#
################################################################################

LIBGLIB2_VERSION_MAJOR = 2.82
LIBGLIB2_VERSION = $(LIBGLIB2_VERSION_MAJOR).5
LIBGLIB2_SOURCE = glib-$(LIBGLIB2_VERSION).tar.xz
LIBGLIB2_SITE = https://download.gnome.org/sources/glib/$(LIBGLIB2_VERSION_MAJOR)
LIBGLIB2_LICENSE = LGPL-2.1+
LIBGLIB2_LICENSE_FILES = COPYING
LIBGLIB2_CPE_ID_VENDOR = gnome
LIBGLIB2_CPE_ID_PRODUCT = glib
LIBGLIB2_INSTALL_STAGING = YES

LIBGLIB2_CFLAGS = $(TARGET_CFLAGS)
LIBGLIB2_LDFLAGS = $(TARGET_LDFLAGS) $(TARGET_NLS_LIBS)

# glib/valgrind.h contains inline asm not compatible with thumb1
ifeq ($(BR2_ARM_INSTRUCTIONS_THUMB),y)
LIBGLIB2_CFLAGS += -marm
endif

# 0001-gstring-Fix-overflow-check-when-expanding-the-string.patch
LIBGLIB2_IGNORE_CVES += CVE-2025-6052

# 0002-gfileutils-fix-computation-of-temporary-file-name.patch
LIBGLIB2_IGNORE_CVES += CVE-2025-7039

# 0003-gvariant-parser-Fix-potential-integer-overflow-parsi.patch
# 0004-gvariant-parser-Use-size_t-to-count-numbers-of-child.patch
# 0005-gvariant-parser-Convert-error-handling-code-to-use-s.patch
LIBGLIB2_IGNORE_CVES += CVE-2025-14087

HOST_LIBGLIB2_CONF_OPTS = \
	-Ddtrace=false \
	-Dglib_debug=disabled \
	-Dlibelf=disabled \
	-Dselinux=disabled \
	-Dsystemtap=false \
	-Dxattr=false \
	-Dtests=false \
	-Doss_fuzz=disabled \
	-Dsysprof=disabled

LIBGLIB2_DEPENDENCIES = \
	host-pkgconf host-libglib2 \
	libffi pcre2 zlib $(TARGET_NLS_DEPENDENCIES)

HOST_LIBGLIB2_DEPENDENCIES = \
	host-gettext \
	host-libffi \
	host-pcre2 \
	host-pkgconf \
	host-util-linux \
	host-zlib

ifeq ($(BR2_PACKAGE_HOST_GOBJECT_INTROSPECTION),y)
HOST_LIBGLIB2_CONF_OPTS += -Dintrospection=enabled
HOST_LIBGLIB2_DEPENDENCIES += host-gobject-introspection
else
HOST_LIBGLIB2_CONF_OPTS += -Dintrospection=disabled
endif

# We explicitly specify a giomodule-dir to avoid having a value
# containing ${libdir} in gio-2.0.pc. Indeed, a value depending on
# ${libdir} would be prefixed by the sysroot by pkg-config, causing a
# bogus installation path once combined with $(DESTDIR).
LIBGLIB2_CONF_OPTS = \
	-Dglib_debug=disabled \
	-Dlibelf=disabled \
	-Dgio_module_dir=/usr/lib/gio/modules \
	-Dtests=false \
	-Doss_fuzz=disabled

LIBGLIB2_MESON_EXTRA_PROPERTIES = \
	have_c99_vsnprintf=true \
	have_c99_snprintf=true \
	have_unix98_printf=true

ifeq ($(BR2_PACKAGE_GOBJECT_INTROSPECTION),y)
LIBGLIB2_CONF_OPTS += -Dintrospection=enabled
LIBGLIB2_DEPENDENCIES += gobject-introspection host-qemu
LIBGLIB2_MESON_EXTRA_BINARIES = exe_wrapper='$(@D)/libglib2-qemu-wrapper'
define LIBGLIB2_INSTALL_QEMUWARPPER
	$(INSTALL) -D -m 755 $(LIBGLIB2_PKGDIR)/libglib2-qemu-wrapper.in \
		$(@D)/libglib2-qemu-wrapper
	$(SED) 's%@QEMU_USER@%$(QEMU_USER)%g; \
		s%@TOOLCHAIN_HEADERS_VERSION@%$(BR2_TOOLCHAIN_HEADERS_AT_LEAST)%g; \
		s%@QEMU_USERMODE_ARGS@%$(call qstrip,$(BR2_PACKAGE_HOST_QEMU_USER_MODE_ARGS))%g; \
		' \
		$(@D)/libglib2-qemu-wrapper
endef
LIBGLIB2_PRE_CONFIGURE_HOOKS += LIBGLIB2_INSTALL_QEMUWARPPER
else
LIBGLIB2_CONF_OPTS += -Dintrospection=disabled
endif

ifeq ($(BR2_PACKAGE_ELFUTILS),y)
LIBGLIB2_DEPENDENCIES += elfutils
endif

ifeq ($(BR2_PACKAGE_LIBICONV),y)
LIBGLIB2_DEPENDENCIES += libiconv
endif

ifeq ($(BR2_PACKAGE_LIBSELINUX),y)
LIBGLIB2_CONF_OPTS += -Dselinux=enabled -Dxattr=true
LIBGLIB2_DEPENDENCIES += libselinux
else
LIBGLIB2_CONF_OPTS += -Dselinux=disabled -Dxattr=false
endif

# Purge gdb-related files
ifneq ($(BR2_PACKAGE_GDB),y)
define LIBGLIB2_REMOVE_GDB_FILES
	rm -rf $(TARGET_DIR)/usr/share/glib-2.0/gdb
endef
endif

ifeq ($(BR2_PACKAGE_UTIL_LINUX_LIBMOUNT),y)
LIBGLIB2_CONF_OPTS += -Dlibmount=enabled
ifeq ($(BR2_PACKAGE_UTIL_LINUX_LIBS),y)
LIBGLIB2_DEPENDENCIES += util-linux-libs
else
LIBGLIB2_DEPENDENCIES += util-linux
endif
else
LIBGLIB2_CONF_OPTS += -Dlibmount=disabled
endif

# Purge useless binaries from target
define LIBGLIB2_REMOVE_DEV_FILES
	rm -rf $(TARGET_DIR)/usr/lib/glib-2.0
	rm -rf $(addprefix $(TARGET_DIR)/usr/share/glib-2.0/,codegen gettext)
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,gdbus-codegen glib-compile-schemas glib-compile-resources glib-genmarshal glib-gettextize glib-mkenums gobject-query gtester gtester-report)
	$(LIBGLIB2_REMOVE_GDB_FILES)
endef

LIBGLIB2_POST_INSTALL_TARGET_HOOKS += LIBGLIB2_REMOVE_DEV_FILES

# Newer versions of libglib2 prefix glib-genmarshal, gobject-query,
# glib-mkenums, glib_compile_schemas, glib_compile_resources and gdbus-codegen
# with ${bindir}. Unfortunately, this will resolve to the host systems /bin/
# directory, which will cause compilation issues if the host does not have these
# programs. By removing the ${bindir}/ prefix, these programs are resolved in
# PATH instead.
define LIBGLIB2_REMOVE_BINDIR_PREFIX_FROM_PC_FILE
	$(SED) 's%$${bindir}/%%g' $(addprefix $(STAGING_DIR)/usr/lib/pkgconfig/, glib-2.0.pc gio-2.0.pc)
endef
LIBGLIB2_POST_INSTALL_TARGET_HOOKS += LIBGLIB2_REMOVE_BINDIR_PREFIX_FROM_PC_FILE

# Remove schema sources/DTDs, we use staging ones to compile them.
# Do so at target finalization since other packages install additional
# ones and we want to deal with it in a single place.
define LIBGLIB2_REMOVE_TARGET_SCHEMAS
	rm -f $(TARGET_DIR)/usr/share/glib-2.0/schemas/*.xml \
		$(TARGET_DIR)/usr/share/glib-2.0/schemas/*.dtd
endef

# Compile schemas at target finalization since other packages install
# them as well, and better do it in a central place.
# It's used at run time so it doesn't matter deferring it.
define LIBGLIB2_COMPILE_SCHEMAS
	$(HOST_DIR)/bin/glib-compile-schemas \
		$(STAGING_DIR)/usr/share/glib-2.0/schemas \
		--targetdir=$(TARGET_DIR)/usr/share/glib-2.0/schemas
endef

LIBGLIB2_TARGET_FINALIZE_HOOKS += LIBGLIB2_REMOVE_TARGET_SCHEMAS
LIBGLIB2_TARGET_FINALIZE_HOOKS += LIBGLIB2_COMPILE_SCHEMAS

$(eval $(meson-package))
$(eval $(host-meson-package))

LIBGLIB2_HOST_BINARY = $(HOST_DIR)/bin/glib-genmarshal

include package/libglib2/libglib2-bootstrap/libglib2-bootstrap.mk

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
