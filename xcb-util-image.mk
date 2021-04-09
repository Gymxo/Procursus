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
xcb-util-image: xcb-util-image-setup libx11 libxau libxmu xorgproto xxhash
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
# xcb-util-image.mk Package Structure
	rm -rf $(BUILD_DIST)/xcb-util-image
	
# xcb-util-image.mk Prep xcb-util-image
	cp -a $(BUILD_STAGE)/xcb-util-image $(BUILD_DIST)
	
# xcb-util-image.mk Sign
	$(call SIGN,xcb-util-image,general.xml)
	
# xcb-util-image.mk Make .debs
	$(call PACK,xcb-util-image,DEB_XCB-UTIL_V)
	
# xcb-util-image.mk Build cleanup
	rm -rf $(BUILD_DIST)/xcb-util-image

.PHONY: xcb-util-image xcb-util-image-package