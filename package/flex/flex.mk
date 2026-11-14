ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# flex
#
#############################################################
FLEX_VERSION = 2.6.4
FLEX_SOURCE = flex-$(FLEX_VERSION).tar.gz
FLEX_SITE = https://github.com/westes/flex/files/981163
FLEX_CUSTOM_PATCH_DIR = astlinux/2.6.4
FLEX_INSTALL_STAGING=YES
FLEX_DEPENDENCIES = host-m4
HOST_FLEX_DEPENDENCIES = host-m4

FLEX_CONF_ENV = ac_cv_path_M4=$(HOST_DIR)/bin/m4
HOST_FLEX_CONF_ENV = ac_cv_path_M4=$(HOST_DIR)/bin/m4

define FLEX_DISABLE_PROGRAM
	$(SED) 's/^bin_PROGRAMS.*//' $(@D)/Makefile.in
endef
FLEX_POST_PATCH_HOOKS += FLEX_DISABLE_PROGRAM

# flex++ symlink is broken when flex binary is not installed
define FLEX_REMOVE_BROKEN_SYMLINK
	rm -f $(TARGET_DIR)/usr/bin/flex++ $(TARGET_DIR)/usr/bin/flex
endef
FLEX_POST_INSTALL_TARGET_HOOKS += FLEX_REMOVE_BROKEN_SYMLINK

$(eval $(autotools-package))
$(eval $(host-autotools-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# flex
#
################################################################################

FLEX_VERSION = 2.6.4
FLEX_SITE = https://github.com/westes/flex/files/981163
FLEX_INSTALL_STAGING = YES
FLEX_LICENSE = FLEX
FLEX_LICENSE_FILES = COPYING
FLEX_CPE_ID_VENDOR = westes
# bug does not cause stack overflows in the generated code and has been
# noted upstream as a bug in the code generator
FLEX_IGNORE_CVES = CVE-2019-6293
FLEX_DEPENDENCIES = $(TARGET_NLS_DEPENDENCIES) host-m4
HOST_FLEX_DEPENDENCIES = host-m4

# 0001-build-AC_USE_SYSTEM_EXTENSIONS-in-configure.ac.patch
# 0002-build-make-it-possible-to-disable-the-build-of-the-f.patch
# 0003-build-make-it-possible-to-disable-the-build-of-the-d.patch
FLEX_AUTORECONF = YES
FLEX_AUTOPOINT = YES
FLEX_CONF_ENV = ac_cv_path_M4=/usr/bin/m4 \
	ac_cv_func_reallocarray=no

# Don't enable programs, they are not needed on the target, and
# require MMU support.
# Don't enable the doc, it's not needed on the target and requires
# special tools (help2man) to build.
FLEX_CONF_OPTS += --disable-program --disable-doc
HOST_FLEX_CONF_OPTS = --disable-doc

$(eval $(autotools-package))
$(eval $(host-autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
