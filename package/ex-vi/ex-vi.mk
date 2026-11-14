#############################################################
#
# ex-vi
#
############################################################

EX_VI_VERSION = 050325
EX_VI_SOURCE = ex-$(EX_VI_VERSION).tar.bz2
EX_VI_SITE = http://downloads.sourceforge.net/project/ex-vi/ex-vi/$(EX_VI_VERSION)
EX_VI_CUSTOM_PATCH_DIR = astlinux

EX_VI_MAKE = $(MAKE1)

EX_VI_DEPENDENCIES = host-pkgconf host-ncurses ncurses

ifeq ($(BR2_PACKAGE_BUSYBOX),y)
EX_VI_DEPENDENCIES += busybox
endif

define EX_VI_BUILD_CMDS
        $(TARGET_MAKE_ENV) $(MAKE) CC="$(TARGET_CC)" \
		TERMLIB="ncurses" \
		FEATURES="-DCHDIR -DFASTTAG -DUCVISUAL -DMB -DBIT8 -DTIOCGWINSZ" \
		-C $(@D)
endef

define EX_VI_CONFIGURE_CMDS
        @echo "No configure"
endef

define EX_VI_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/ex $(TARGET_DIR)/usr/bin/vi
	# In case Busybox made a /bin/vi link, remove it
	rm -f $(TARGET_DIR)/bin/vi
endef

define EX_VI_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/vi
endef

$(eval $(generic-package))
