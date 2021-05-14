ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += xfce4-appfinder
XFCE4-APPFINDER_VERSION := 4.16.1
DEB_XFCE4-APPFINDER_V   ?= $(XFCE4-APPFINDER_VERSION)

xfce4-appfinder-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://archive.xfce.org/src/xfce/xfce4-appfinder/4.16/xfce4-appfinder-4.16.1.tar.bz2
	$(call EXTRACT_TAR,xfce4-appfinder-$(XFCE4-APPFINDER_VERSION).tar.bz2,xfce4-appfinder-$(XFCE4-APPFINDER_VERSION),xfce4-appfinder)

ifneq ($(wildcard $(BUILD_WORK)/xfce4-appfinder/.build_complete),)
xfce4-appfinder:
	find $(BUILD_STAGE)/xfce4-appfinder -type f -exec codesign --remove {} \; &> /dev/null; \
	find $(BUILD_STAGE)/xfce4-appfinder -type f -exec codesign --sign $(CODESIGN_IDENTITY) --force --preserve-metadata=entitlements,requirements,flags,runtime {} \; &> /dev/null
	@echo "Using previously built xfce4-appfinder."
else
xfce4-appfinder: xfce4-appfinder-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xfce4-appfinder && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS)
	+$(MAKE) -C $(BUILD_WORK)/xfce4-appfinder
	+$(MAKE) -C $(BUILD_WORK)/xfce4-appfinder install \
		DESTDIR=$(BUILD_STAGE)/xfce4-appfinder
	+$(MAKE) -C $(BUILD_WORK)/xfce4-appfinder install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xfce4-appfinder/.build_complete
endif

xfce4-appfinder-package: xfce4-appfinder-stage
	# xfce4-appfinder.mk Package Structure
	rm -rf $(BUILD_DIST)/xfce4-appfinder

	# xfce4-appfinder.mk Prep xfce4-appfinder
	cp -a $(BUILD_STAGE)/xfce4-appfinder $(BUILD_DIST)

	# xfce4-appfinder.mk Sign
	$(call SIGN,xfce4-appfinder,general.xml)

	# xfce4-appfinder.mk Make .debs
	$(call PACK,xfce4-appfinder,DEB_XFCE4-APPFINDER_V)

	# xfce4-appfinder.mk Build cleanup
	rm -rf $(BUILD_DIST)/xfce4-appfinder

.PHONY: xfce4-appfinder xfce4-appfinder-package
