ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += xcb-util-renderutil
XCB-UTIL-RENDERUTIL_VERSION := 0.3.9
DEB_XCB-UTIL-RENDERUTIL_V   ?= $(XCB-UTIL-RENDERUTIL_VERSION)

xcb-util-renderutil-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/xcb/xcb-util-renderutil-$(XCB-UTIL-RENDERUTIL_VERSION).tar.gz
	$(call EXTRACT_TAR,xcb-util-renderutil-$(XCB-UTIL-RENDERUTIL_VERSION).tar.gz,xcb-util-renderutil-$(XCB-UTIL-RENDERUTIL_VERSION),xcb-util-renderutil)

ifneq ($(wildcard $(BUILD_WORK)/xcb-util-renderutil/.build_complete),)
xcb-util-renderutil:
	@echo "Using previously built xcb-util-renderutil."
else
xcb-util-renderutil: xcb-util-renderutil-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xcb-util-renderutil && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var
	+$(MAKE) -C $(BUILD_WORK)/xcb-util-renderutil
	+$(MAKE) -C $(BUILD_WORK)/xcb-util-renderutil install \
		DESTDIR=$(BUILD_STAGE)/xcb-util-renderutil
	+$(MAKE) -C $(BUILD_WORK)/xcb-util-renderutil install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xcb-util-renderutil/.build_complete
endif

xcb-util-renderutil-package: xcb-util-renderutil-stage
# xcb-util-renderutil.mk Package Structure
	rm -rf $(BUILD_DIST)/xcb-util-renderutil
	
# xcb-util-renderutil.mk Prep xcb-util-renderutil
	cp -a $(BUILD_STAGE)/xcb-util-renderutil $(BUILD_DIST)
	
# xcb-util-renderutil.mk Sign
	$(call SIGN,xcb-util-renderutil,general.xml)
	
# xcb-util-renderutil.mk Make .debs
	$(call PACK,xcb-util-renderutil,DEB_XCB-UTIL_V)
	
# xcb-util-renderutil.mk Build cleanup
	rm -rf $(BUILD_DIST)/xcb-util-renderutil

.PHONY: xcb-util-renderutil xcb-util-renderutil-package