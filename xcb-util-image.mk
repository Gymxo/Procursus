ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += xcb-util-image
XCB-UTIL-IMAGE_VERSION := 0.4.0
DEB_XCB-UTIL-IMAGE_V   ?= $(XCB-UTIL-IMAGE_VERSION)

xcb-util-image-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/xcb/xcb-util-image-$(XCB-UTIL-IMAGE_VERSION).tar.gz
	$(call EXTRACT_TAR,xcb-util-image-$(XCB-UTIL-IMAGE_VERSION).tar.gz,xcb-util-image-$(XCB-UTIL-IMAGE_VERSION),xcb-util-image)

ifneq ($(wildcard $(BUILD_WORK)/xcb-util-image/.build_complete),)
xcb-util-image:
	@echo "Using previously built xcb-util-image."
else
xcb-util-image: xcb-util-image-setup libxcb
	cd $(BUILD_WORK)/xcb-util-image && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var 
	+$(MAKE) -C $(BUILD_WORK)/xcb-util-image
	+$(MAKE) -C $(BUILD_WORK)/xcb-util-image install \
		DESTDIR=$(BUILD_STAGE)/xcb-util-image
	+$(MAKE) -C $(BUILD_WORK)/xcb-util-image install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xcb-util-image/.build_complete
endif

xcb-util-image-package: xcb-util-image-stage
	rm -rf $(BUILD_DIST)/libxcb-image{0,-dev}
	mkdir -p $(BUILD_DIST)/libxcb-image{0,-dev}/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# xcb-util-image.mk Prep libutil-xrm1
	cp -a $(BUILD_STAGE)/libxcb-image/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/lib-xrm.0.dylib $(BUILD_DIST)/libxcb-image1/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# libxcb-image.mk Prep libxcb-image-dev
	cp -a $(BUILD_STAGE)/libxcb-image/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/!(libxcb-image.0.dylib) $(BUILD_DIST)/libxcb-image-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib
	cp -a $(BUILD_STAGE)/libxcb-image/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include $(BUILD_DIST)/libxcb-image-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)

	# libxcb-image.mk Sign
	$(call SIGN,libxcb-image1,general.xml)

	# libxcb-image.mk Make .debs
	$(call PACK,libxcb-image1,DEB_xcb-image_V)
	$(call PACK,libxcb-image-dev,DEB_xcb-image_V)

	# libxcb-image.mk Build cleanup
	rm -rf $(BUILD_DIST)/libxcb-image{1,-dev}

.PHONY: xcb-util-image xcb-util-image-package