ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += xcb-util-keysyms
XCB-UTIL-KEYSYMS_VERSION := 0.4.0
DEB_XCB-UTIL-KEYSYMS_V   ?= $(XCB-UTIL-KEYSYMS_VERSION)

xcb-util-keysyms-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/xcb/xcb-util-keysyms-$(XCB-UTIL-KEYSYMS_VERSION).tar.gz
	$(call EXTRACT_TAR,xcb-util-keysyms-$(XCB-UTIL-KEYSYMS_VERSION).tar.gz,xcb-util-keysyms-$(XCB-UTIL-KEYSYMS_VERSION),xcb-util-keysyms)

ifneq ($(wildcard $(BUILD_WORK)/xcb-util-keysyms/.build_complete),)
xcb-util-keysyms:
	@echo "Using previously built xcb-util-keysyms."
else
xcb-util-keysyms: xcb-util-keysyms-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xcb-util-keysyms && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var 
	+$(MAKE) CFLAGS='-std=gnu99' -C $(BUILD_WORK)/xcb-util-keysyms
	+$(MAKE) -C $(BUILD_WORK)/xcb-util-keysyms install \
		DESTDIR=$(BUILD_STAGE)/xcb-util-keysyms
	+$(MAKE) -C $(BUILD_WORK)/xcb-util-keysyms install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xcb-util-keysyms/.build_complete
endif

xcb-util-keysyms-package: xcb-util-keysyms-stage
# xcb-util-keysyms.mk Package Structure
	rm -rf $(BUILD_DIST)/xcb-util-keysyms
	
# xcb-util-keysyms.mk Prep xcb-util-keysyms
	cp -a $(BUILD_STAGE)/xcb-util-keysyms $(BUILD_DIST)
	
# xcb-util-keysyms.mk Sign
	$(call SIGN,xcb-util-keysyms,general.xml)
	
# xcb-util-keysyms.mk Make .debs
	$(call PACK,xcb-util-keysyms,DEB_XCB-UTIL_V)
	
# xcb-util-keysyms.mk Build cleanup
	rm -rf $(BUILD_DIST)/xcb-util-keysyms

.PHONY: xcb-util-keysyms xcb-util-keysyms-package