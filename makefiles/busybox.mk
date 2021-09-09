ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += busybox
BUSYBOX_VERSION := 1.33.0
DEB_BUSYBOX_V   ?= $(BUSYBOX_VERSION)

busybox-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.busybox.net/downloads/busybox-$(BUSYBOX_VERSION).tar.bz2{,.sig}
	$(call PGP_VERIFY,busybox-$(BUSYBOX_VERSION).tar.bz2)
	$(call EXTRACT_TAR,busybox-$(BUSYBOX_VERSION).tar.bz2,busybox-$(BUSYBOX_VERSION),busybox)

ifneq ($(wildcard $(BUILD_WORK)/busybox/.build_complete),)
busybox:
	@echo "Using previously built busybox."
else
busybox: busybox-setup libx11 libxau libxmu xorgproto ncurses
	+$(MAKE) -i -C $(BUILD_WORK)/busybox defconfig
	+$(MAKE) -C $(BUILD_WORK)/busybox
	+$(MAKE) -C $(BUILD_WORK)/busybox install \
		DESTDIR=$(BUILD_STAGE)/busybox
	+$(MAKE) ARCH=arm64 -C $(BUILD_WORK)/busybox install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/busybox/.build_complete
endif

busybox-package: busybox-stage
# busybox.mk Package Structure
	rm -rf $(BUILD_DIST)/busybox
	
# busybox.mk Prep busybox
	cp -a $(BUILD_STAGE)/busybox $(BUILD_DIST)
	
# busybox.mk Sign
	$(call SIGN,busybox,general.xml)
	
# busybox.mk Make .debs
	$(call PACK,busybox,DEB_BUSYBOX_V)
	
# busybox.mk Build cleanup
	rm -rf $(BUILD_DIST)/busybox

.PHONY: busybox busybox-package