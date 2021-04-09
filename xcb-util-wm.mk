ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += xcb-util-wm
XCB-UTIL-WM_VERSION := 0.4.0
DEB_XCB-UTIL-WM_V   ?= $(XCB-UTIL-WM_VERSION)

xcb-util-wm-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/xcb/xcb-util-wm-$(XCB-UTIL-WM_VERSION).tar.gz
	$(call EXTRACT_TAR,xcb-util-wm-$(XCB-UTIL-WM_VERSION).tar.gz,xcb-util-wm-$(XCB-UTIL-WM_VERSION),xcb-util-wm)

ifneq ($(wildcard $(BUILD_WORK)/xcb-util-wm/.build_complete),)
xcb-util-wm:
	@echo "Using previously built xcb-util-wm."
else
xcb-util-wm: xcb-util-wm-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xcb-util-wm && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var
	+$(MAKE) -C $(BUILD_WORK)/xcb-util-wm
	+$(MAKE) -C $(BUILD_WORK)/xcb-util-wm install \
		DESTDIR=$(BUILD_STAGE)/xcb-util-wm
	+$(MAKE) -C $(BUILD_WORK)/xcb-util-wm install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xcb-util-wm/.build_complete
endif

xcb-util-wm-package: xcb-util-wm-stage
# xcb-util-wm.mk Package Structure
	rm -rf $(BUILD_DIST)/xcb-util-wm
	
# xcb-util-wm.mk Prep xcb-util-wm
	cp -a $(BUILD_STAGE)/xcb-util-wm $(BUILD_DIST)
	
# xcb-util-wm.mk Sign
	$(call SIGN,xcb-util-wm,general.xml)
	
# xcb-util-wm.mk Make .debs
	$(call PACK,xcb-util-wm,DEB_XCB-UTIL_V)
	
# xcb-util-wm.mk Build cleanup
	rm -rf $(BUILD_DIST)/xcb-util-wm

.PHONY: xcb-util-wm xcb-util-wm-package