ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += xfwm4
XFWM4_VERSION := 4.16.1
DEB_XFWM4_V   ?= $(XFWM4_VERSION)

xfwm4-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://archive.xfce.org/src/xfce/xfwm4/4.16/xfwm4-4.16.1.tar.bz2
	$(call EXTRACT_TAR,xfwm4-$(XFWM4_VERSION).tar.bz2,xfwm4-$(XFWM4_VERSION),xfwm4)

ifneq ($(wildcard $(BUILD_WORK)/xfwm4/.build_complete),)
xfwm4:
	find $(BUILD_STAGE)/xfwm4 -type f -exec codesign --remove {} \; &> /dev/null; \
	find $(BUILD_STAGE)/xfwm4 -type f -exec codesign --sign $(CODESIGN_IDENTITY) --force --preserve-metadata=entitlements,requirements,flags,runtime {} \; &> /dev/null
	@echo "Using previously built xfwm4."
else
xfwm4: xfwm4-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xfwm4 && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-x \
		--x-libraries=$(BUILD_BASE)/usr/lib \
		--x-includes=$(BUILD_BASE)/usr/include \
		--disable-startup-notification
	+$(MAKE) -C $(BUILD_WORK)/xfwm4
	+$(MAKE) -C $(BUILD_WORK)/xfwm4 install \
		DESTDIR=$(BUILD_STAGE)/xfwm4
	+$(MAKE) -C $(BUILD_WORK)/xfwm4 install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xfwm4/.build_complete
endif

xfwm4-package: xfwm4-stage
	# xfwm4.mk Package Structure
	rm -rf $(BUILD_DIST)/xfwm4

	# xfwm4.mk Prep xfwm4
	cp -a $(BUILD_STAGE)/xfwm4 $(BUILD_DIST)

	# xfwm4.mk Sign
	$(call SIGN,xfwm4,general.xml)

	# xfwm4.mk Make .debs
	$(call PACK,xfwm4,DEB_XFWM4_V)

	# xfwm4.mk Build cleanup
	rm -rf $(BUILD_DIST)/xfwm4

.PHONY: xfwm4 xfwm4-package
