#############################################################
#
# bfdetect
#
##############################################################
BFDETECT_SOURCE:=bfdetect_src.tar.gz
BFDETECT_SITE:=https://astlinux-project.org/files
BFDETECT_CUSTOM_PATCH_DIR = astlinux
#BFDETECT_SITE:=http://www.beronet.com/wp-content/uploads/downloads/berofix/tools
BFDETECT_CUSTOM_PATCH_DIR = astlinux
BFDETECT_DIR := $(@D)
#BFDETECT_CAT:=zcat
BFDETECT_BINARY := bfdetect
BFDETECT_TARGET_BINARY = usr/bin/$(BFDETECT_BINARY)
BFDETECT_STRIP_COMPONENTS = 0

#$(DL_DIR)/$(BFDETECT_SOURCE):
#	$(WGET) -P $(DL_DIR) $(BFDETECT_SITE)/$(BFDETECT_SOURCE)

#$(BFDETECT_DIR)/.unpacked: $(DL_DIR)/$(BFDETECT_SOURCE)
#	mkdir -p $(BFDETECT_DIR)
#	$(BFDETECT_CAT) $(DL_DIR)/$(BFDETECT_SOURCE) | tar -C $(BFDETECT_DIR) $(TAR_OPTIONS) -
#	touch $(BFDETECT_DIR)/.unpacked

#$(BFDETECT_DIR)/.configured: $(BFDETECT_DIR)/.unpacked
#	touch $(BFDETECT_DIR)/.configured

define BFDETECT_CONFIGURE_CMDS
        @echo "No configure"
endef

define BFDETECT_BUILD_CMDS
	$(SED) 's/^[[:space:]]*strip /#strip /' $(BFDETECT_DIR)/Makefile
	$(TARGET_MAKE_ENV) $(MAKE) CC=$(TARGET_CC) CFLAGS='$(TARGET_CFLAGS)' -C $(BFDETECT_DIR) 
endef

define BFDETECT_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(BFDETECT_DIR)/$(BFDETECT_BINARY) $(TARGET_DIR)/$(BFDETECT_TARGET_BINARY)
endef
 

#bfdetect: $(TARGET_DIR)/$(BFDETECT_TARGET_BINARY)

#bfdetect-source: $(BFDETECT_DIR)/bfdetect.c

#bfdetect-dirclean:
#	rm -rf $(BFDETECT_DIR)

#bfdetect-clean:
#	rm -f $(TARGET_DIR)/$(BFDETECT_TARGET_BINARY)
#	-$(MAKE) -C $(BFDETECT_DIR) clean

#############################################################
#
# Toplevel Makefile options
#
#############################################################
#ifeq ($(strip $(BR2_PACKAGE_BFDETECT)),y)
#TARGETS+=bfdetect
#endif

$(eval $(generic-package))


