ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

#############################################################
#
# newt
#
#############################################################
NEWT_SOURCE=newt-0.51.0.tar.bz2
#NEWT_CAT:=$(BZCAT)
NEWT_SITE=http://www.uclibc.org
NEWT_DIR=$(@D)
NEWT_VERSION=0.51.0
NEWT_CFLAGS=-Os -g -fPIC

#$(DL_DIR)/$(NEWT_SOURCE):
#	$(call DOWNLOAD,$(NEWT_SITE),$(NEWT_SOURCE))

#$(NEWT_DIR)/.source: $(DL_DIR)/$(NEWT_SOURCE)
#	$(NEWT_CAT) $(DL_DIR)/$(NEWT_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
#	touch $(NEWT_DIR)/.source

define NEWT_CONFIGURE_CMDS
	(cd $(NEWT_DIR); rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		$(TARGET_CONFIGURE_ARGS) \
		CFLAGS="$(TARGET_CFLAGS) $(NEWT_CFLAGS)" \
		./configure $(QUIET) \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--sbindir=/usr/sbin \
		--libdir=/lib \
		--libexecdir=/usr/lib \
		--sysconfdir=/etc \
		--datadir=/usr/share \
		--localstatedir=/var \
		--mandir=/usr/man \
		--infodir=/usr/info \
		$(DISABLE_NLS) \
	)
endef

define NEWT_BUILD_CMDS
	$(MAKE) CFLAGS="$(TARGET_CFLAGS) $(NEWT_CFLAGS)" CC="$(TARGET_CC)" -C $(NEWT_DIR)
endef

define NEWT_INSTALL_STAGING_CMDS
	cp -a $(NEWT_DIR)/libnewt.a $(STAGING_DIR)/usr/lib/
	cp -a $(NEWT_DIR)/newt.h $(STAGING_DIR)/usr/include/
	cp -a $(NEWT_DIR)/libnewt.so* $(STAGING_DIR)/usr/lib/
	(cd $(STAGING_DIR)/usr/lib; ln -fs libnewt.so.$(NEWT_VERSION) libnewt.so)
	(cd $(STAGING_DIR)/usr/lib; ln -fs libnewt.so.$(NEWT_VERSION) libnewt.so.0.51)
endef

define NEWT_INSTALL_TARGET_CMDS
	$(NEWT_INSTALL_STAGING_CMDS)
	cp -a $(STAGING_DIR)/usr/lib/libnewt.so* $(TARGET_DIR)/usr/lib/
	-$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/usr/lib/libnewt.so*
endef

NEWT_DEPENDENCIES += slang

#newt-source: $(DL_DIR)/$(NEWT_SOURCE)

#newt-clean:
#	rm -f $(TARGET_DIR)/usr/lib/libnewt.so*
#	-$(MAKE) -C $(NEWT_DIR) clean

#newt-dirclean: slang-dirclean
#	rm -rf $(NEWT_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
#ifeq ($(BR2_PACKAGE_NEWT),y)
#TARGETS+=newt
#endif

$(eval $(generic-package))

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

################################################################################
#
# newt
#
################################################################################

NEWT_VERSION = 0.52.23
NEWT_SITE = https://gitlab.com/newt-ui/newt/-/releases/$(NEWT_VERSION)/downloads
NEWT_INSTALL_STAGING = YES
NEWT_DEPENDENCIES = popt slang $(TARGET_NLS_DEPENDENCIES)
# Force to use libintl, otherwise it finds gettext functions in the C
# library, and does not link against libintl.
NEWT_CONF_ENV = LIBS=$(TARGET_NLS_LIBS)
NEWT_CONF_OPTS = --without-python --without-tcl
NEWT_LICENSE = GPL-2.0
NEWT_LICENSE_FILES = COPYING

$(eval $(autotools-package))

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
