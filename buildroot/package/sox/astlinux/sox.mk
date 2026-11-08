#############################################################
#
# sox
#
#############################################################

SOX_VERSION = 14.4.2
SOX_SITE = https://downloads.sourceforge.net/project/sox/sox/$(SOX_VERSION)
SOX_CUSTOM_PATCH_DIR = astlinux
SOX_SOURCE = sox-$(SOX_VERSION).tar.bz2
SOX_INSTALL_STAGING = YES
# patching Makefile.am
SOX_AUTORECONF = YES

SOX_DEPENDENCIES = host-pkgconf

SOX_CONF_OPTS = \
	--with-distro="Buildroot" \
	--disable-openmp \
	--without-libltdl \
	--without-ladspa

SOX_CONF_OPTS += --without-alsa

ifeq ($(BR2_PACKAGE_FILE),y)
SOX_DEPENDENCIES += file
else
SOX_CONF_OPTS += --without-magic
endif

ifeq ($(BR2_PACKAGE_FLAC),y)
SOX_DEPENDENCIES += flac
else
SOX_CONF_OPTS += --without-flac
endif

ifeq ($(BR2_PACKAGE_LAME),y)
SOX_DEPENDENCIES += lame
else
SOX_CONF_OPTS += --without-lame
endif

ifeq ($(BR2_PACKAGE_LIBAO),y)
SOX_DEPENDENCIES += libao
else
SOX_CONF_OPTS += --without-ao
endif

ifeq ($(BR2_PACKAGE_LIBID3TAG),y)
SOX_DEPENDENCIES += libid3tag
else
SOX_CONF_OPTS += --without-id3tag
endif

ifeq ($(BR2_PACKAGE_LIBMAD),y)
SOX_DEPENDENCIES += libmad
else
SOX_CONF_OPTS += --without-mad
endif

ifeq ($(BR2_PACKAGE_LIBPNG),y)
SOX_DEPENDENCIES += libpng
else
SOX_CONF_OPTS += --without-png
endif

ifeq ($(BR2_PACKAGE_LIBSNDFILE),y)
SOX_DEPENDENCIES += libsndfile
else
SOX_CONF_OPTS += --without-sndfile
endif

ifeq ($(BR2_PACKAGE_LIBVORBIS),y)
SOX_DEPENDENCIES += libvorbis
else
SOX_CONF_OPTS += --without-oggvorbis
endif

SOX_CONF_OPTS += --without-amrwb --without-amrnb

SOX_CONF_OPTS += --without-opus

SOX_CONF_OPTS += --without-pulseaudio

SOX_CONF_OPTS += --without-twolame

ifeq ($(BR2_PACKAGE_WAVPACK),y)
SOX_DEPENDENCIES += wavpack
else
SOX_CONF_OPTS += --without-wavpack
endif

define SOX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(STAGING_DIR)/usr/bin/sox $(TARGET_DIR)/usr/bin/sox
	cp -a $(STAGING_DIR)/usr/bin/rec $(TARGET_DIR)/usr/bin/
	cp -a $(STAGING_DIR)/usr/bin/play $(TARGET_DIR)/usr/bin/
	cp -a $(STAGING_DIR)/usr/lib/libsox.so* $(TARGET_DIR)/usr/lib/
endef

define SOX_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/sox
	rm -f $(TARGET_DIR)/usr/bin/rec
	rm -f $(TARGET_DIR)/usr/bin/play
	rm -f $(TARGET_DIR)/usr/lib/libsox.so*
endef

$(eval $(autotools-package))
