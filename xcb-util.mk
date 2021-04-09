ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += xcb-util
XCB-UTIL_VERSION := 0.4.0
DEB_XCB-UTIL_V   ?= $(XCB-UTIL_VERSION)

xcb-util-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/xcb/xcb-util-$(XCB-UTIL_VERSION).tar.gz
	$(call EXTRACT_TAR,xcb-util-$(XCB-UTIL_VERSION).tar.gz,xcb-util-$(XCB-UTIL_VERSION),xcb-util)

ifneq ($(wildcard $(BUILD_WORK)/xcb-util/.build_complete),)
xcb-util:
	@echo "Using previously built xcb-util."
else
xcb-util: xcb-util-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xcb-util && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var
	+$(MAKE) -C $(BUILD_WORK)/xcb-util
	+$(MAKE) -C $(BUILD_WORK)/xcb-util install \
		DESTDIR=$(BUILD_STAGE)/xcb-util
	+$(MAKE) -C $(BUILD_WORK)/xcb-util install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xcb-util/.build_complete
endif

xcb-util-package: xcb-util-stage
# xcb-util.mk Package Structure
	rm -rf $(BUILD_DIST)/xcb-util
	
# xcb-util.mk Prep xcb-util
	cp -a $(BUILD_STAGE)/xcb-util $(BUILD_DIST)
	
# xcb-util.mk Sign
	$(call SIGN,xcb-util,general.xml)
	
# xcb-util.mk Make .debs
	$(call PACK,xcb-util,DEB_XCB-UTIL_V)
	
# xcb-util.mk Build cleanup
	rm -rf $(BUILD_DIST)/xcb-util

.PHONY: xcb-util xcb-util-package