ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += xcb-util-xrm
XCB-UTIL-XRM_VERSION := 1.3
DEB_XCB-UTIL-XRM_V   ?= $(XCB-UTIL-XRM_VERSION)

xcb-util-xrm-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://github.com/Airblader/xcb-util-xrm/releases/download/v1.3/xcb-util-xrm-1.3.tar.gz
	$(call EXTRACT_TAR,xcb-util-xrm-$(XCB-UTIL-XRM_VERSION).tar.gz,xcb-util-xrm-$(XCB-UTIL-XRM_VERSION),xcb-util-xrm)

ifneq ($(wildcard $(BUILD_WORK)/xcb-util-xrm/.build_complete),)
xcb-util-xrm:
	@echo "Using previously built xcb-util-xrm."
else
xcb-util-xrm: xcb-util-xrm-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xcb-util-xrm && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var 
	+$(MAKE) CFLAGS='-std=gnu99' -C $(BUILD_WORK)/xcb-util-xrm
	+$(MAKE) -C $(BUILD_WORK)/xcb-util-xrm install \
		DESTDIR=$(BUILD_STAGE)/xcb-util-xrm
	+$(MAKE) -C $(BUILD_WORK)/xcb-util-xrm install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xcb-util-xrm/.build_complete
endif

xcb-util-xrm-package: xcb-util-xrm-stage
# xcb-util-xrm.mk Package Structure
	rm -rf $(BUILD_DIST)/xcb-util-xrm
	
# xcb-util-xrm.mk Prep xcb-util-xrm
	cp -a $(BUILD_STAGE)/xcb-util-xrm $(BUILD_DIST)
	
# xcb-util-xrm.mk Sign
	$(call SIGN,xcb-util-xrm,general.xml)
	
# xcb-util-xrm.mk Make .debs
	$(call PACK,xcb-util-xrm,DEB_XCB-UTIL_V)
	
# xcb-util-xrm.mk Build cleanup
	rm -rf $(BUILD_DIST)/xcb-util-xrm

.PHONY: xcb-util-xrm xcb-util-xrm-package