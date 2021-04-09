ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += xcb-util-cursor
XCB-UTIL-CURSOR_VERSION := 0.1.3
DEB_XCB-UTIL-CURSOR_V   ?= $(XCB-UTIL-CURSOR_VERSION)

xcb-util-cursor-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/xcb/xcb-util-cursor-$(XCB-UTIL-CURSOR_VERSION).tar.gz
	$(call EXTRACT_TAR,xcb-util-cursor-$(XCB-UTIL-CURSOR_VERSION).tar.gz,xcb-util-cursor-$(XCB-UTIL-CURSOR_VERSION),xcb-util-cursor)

ifneq ($(wildcard $(BUILD_WORK)/xcb-util-cursor/.build_complete),)
xcb-util-cursor:
	@echo "Using previously built xcb-util-cursor."
else
xcb-util-cursor: xcb-util-cursor-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xcb-util-cursor && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var 
	+$(MAKE) CFLAGS='-std=gnu99' -C $(BUILD_WORK)/xcb-util-cursor
	+$(MAKE) -C $(BUILD_WORK)/xcb-util-cursor install \
		DESTDIR=$(BUILD_STAGE)/xcb-util-cursor
	+$(MAKE) -C $(BUILD_WORK)/xcb-util-cursor install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xcb-util-cursor/.build_complete
endif

xcb-util-cursor-package: xcb-util-cursor-stage
# xcb-util-cursor.mk Package Structure
	rm -rf $(BUILD_DIST)/xcb-util-cursor
	
# xcb-util-cursor.mk Prep xcb-util-cursor
	cp -a $(BUILD_STAGE)/xcb-util-cursor $(BUILD_DIST)
	
# xcb-util-cursor.mk Sign
	$(call SIGN,xcb-util-cursor,general.xml)
	
# xcb-util-cursor.mk Make .debs
	$(call PACK,xcb-util-cursor,DEB_XCB-UTIL_V)
	
# xcb-util-cursor.mk Build cleanup
	rm -rf $(BUILD_DIST)/xcb-util-cursor

.PHONY: xcb-util-cursor xcb-util-cursor-package