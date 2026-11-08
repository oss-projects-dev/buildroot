ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# bash
#
#############################################################

BASH_VERSION = 4.1
BASH_SITE = $(BR2_GNU_MIRROR)/bash
BASH_CUSTOM_PATCH_DIR = astlinux
BASH_DEPENDENCIES = ncurses host-bison
BASH_CONF_ENV += \
	bash_cv_job_control_missing=present \
	bash_cv_sys_named_pipes=present     \
	bash_cv_func_sigsetjmp=present      \
	bash_cv_printf_a_format=yes

# Make sure we build after busybox so that /bin/sh links to bash
ifeq ($(BR2_PACKAGE_BUSYBOX),y)
BASH_DEPENDENCIES += busybox
endif

define BASH_LOADABLE_BUILTINS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/examples/loadables sleep
endef
BASH_POST_BUILD_HOOKS = BASH_LOADABLE_BUILTINS

ifeq ($(BR2_PACKAGE_BASH_DEFAULT_SHELL),y)
define BASH_DEFAULT_SHELL
	if [ -e $(TARGET_DIR)/bin/sh ]; then \
		mv -f $(TARGET_DIR)/bin/sh $(TARGET_DIR)/bin/sh.prebash; \
	fi
	ln -sf bash $(TARGET_DIR)/bin/sh
endef
endif

define BASH_RESTRICTED_SHELL
	ln -sf bash $(TARGET_DIR)/bin/rbash
	# Define /usr/rbin with symlinks
	rm -rf $(TARGET_DIR)/usr/rbin
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/usr/rbin
	(for i in `cat package/bash/astlinux/rbash/cmd_symlinks.txt`; \
	do ln -s "../../$$i" $(TARGET_DIR)/usr/rbin/`basename "$$i"`; done)
	$(INSTALL) -D -m 0755 package/bash/astlinux/rbash/grep.sh $(TARGET_DIR)/usr/rbin/grep
endef

# Save the old sh file/link if there is one and symlink bash->sh
define BASH_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) \
		DESTDIR=$(TARGET_DIR) exec_prefix=/ install
	rm -f $(TARGET_DIR)/bin/bashbug
	$(INSTALL) -D -m 0755 $(@D)/examples/loadables/sleep $(TARGET_DIR)/usr/lib/bash/sleep
	$(BASH_DEFAULT_SHELL)
	$(BASH_RESTRICTED_SHELL)
endef

# Restore the old shell file/link if there was one
define BASH_UNINSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) DESTDIR=$(TARGET_DIR) \
		-C $(BASH_DIR) exec_prefix=/ uninstall
	if [ -e $(TARGET_DIR)/bin/sh.prebash ]; then \
		mv -f $(TARGET_DIR)/bin/sh.prebash $(TARGET_DIR)/bin/sh; \
	fi
	rm -rf $(TARGET_DIR)/usr/lib/bash
endef

$(eval $(autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# bash
#
################################################################################

BASH_VERSION = 5.2.37
BASH_SITE = $(BR2_GNU_MIRROR)/bash
BASH_DEPENDENCIES = ncurses readline host-bison
BASH_LICENSE = GPL-3.0+
BASH_LICENSE_FILES = COPYING
BASH_CPE_ID_VENDOR = gnu

# We want the bash binary in /bin
BASH_CONF_OPTS = \
	--bindir=/bin \
	--with-installed-readline \
	--without-bash-malloc

BASH_CONF_ENV = \
	ac_cv_rl_prefix="$(STAGING_DIR)" \
	ac_cv_rl_version="$(READLINE_VERSION)" \
	bash_cv_getcwd_malloc=yes \
	bash_cv_job_control_missing=present \
	bash_cv_sys_named_pipes=present \
	bash_cv_func_sigsetjmp=present \
	bash_cv_printf_a_format=yes

ifeq ($(BR2_HOST_GCC_AT_LEAST_15),y)
BASH_CONF_ENV += CFLAGS_FOR_BUILD="$(HOST_CFLAGS) -std=gnu17"
endif

# The static build needs some trickery
ifeq ($(BR2_STATIC_LIBS),y)
BASH_CONF_OPTS += --enable-static-link
# bash wants to redefine the getenv() function. To check whether this is
# possible, AC_TRY_RUN is used which is not possible in
# cross-compilation.
# On uClibc, redefining getenv is not possible; on glibc and musl it is.
# Related:
# http://lists.gnu.org/archive/html/bug-bash/2012-03/msg00052.html
ifeq ($(BR2_TOOLCHAIN_USES_UCLIBC),y)
BASH_CONF_ENV += bash_cv_getenv_redef=no
else
BASH_CONF_ENV += bash_cv_getenv_redef=yes
endif
endif

define BASH_REMOVE_UNUSED_FILES
	rm -f $(TARGET_DIR)/bin/bashbug
endef
BASH_POST_INSTALL_TARGET_HOOKS += BASH_REMOVE_UNUSED_FILES

ifeq ($(BR2_PACKAGE_BASH_LOADABLE_EXAMPLES),y)
define BASH_REMOVE_LOADABLE_UNUSED_FILES
	rm -f $(TARGET_DIR)/usr/lib/bash/Makefile.inc
	rm -f $(TARGET_DIR)/usr/lib/bash/loadables.h
endef
BASH_POST_INSTALL_TARGET_HOOKS += BASH_REMOVE_LOADABLE_UNUSED_FILES
else
define BASH_REMOVE_LOADABLE_EXAMPLES
	rm -rf $(TARGET_DIR)/usr/lib/bash
endef
BASH_POST_INSTALL_TARGET_HOOKS += BASH_REMOVE_LOADABLE_EXAMPLES
endif

# Add /bin/bash to /etc/shells otherwise some login tools like dropbear
# can reject the user connection. See man shells.
define BASH_ADD_BASH_TO_SHELLS
	grep -qsE '^/bin/bash$$' $(TARGET_DIR)/etc/shells \
		|| echo "/bin/bash" >> $(TARGET_DIR)/etc/shells
endef
BASH_TARGET_FINALIZE_HOOKS += BASH_ADD_BASH_TO_SHELLS

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
