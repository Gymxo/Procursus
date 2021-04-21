ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

<<<<<<< HEAD
SUBPROJECTS    += xcb-util-keysyms
=======
SUBPROJECTS              += xcb-util-keysyms
>>>>>>> 7dfd23f (uhh)
XCB-UTIL-KEYSYMS_VERSION := 0.4.0
DEB_XCB-UTIL-KEYSYMS_V   ?= $(XCB-UTIL-KEYSYMS_VERSION)

xcb-util-keysyms-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/xcb/xcb-util-keysyms-$(XCB-UTIL-KEYSYMS_VERSION).tar.gz
	$(call EXTRACT_TAR,xcb-util-keysyms-$(XCB-UTIL-KEYSYMS_VERSION).tar.gz,xcb-util-keysyms-$(XCB-UTIL-KEYSYMS_VERSION),xcb-util-keysyms)

ifneq ($(wildcard $(BUILD_WORK)/xcb-util-keysyms/.build_complete),)
xcb-util-keysyms:
	@echo "Using previously built xcb-util-keysyms."
else
<<<<<<< HEAD
xcb-util-keysyms: xcb-util-keysyms-setup libxcb
	cd $(BUILD_WORK)/xcb-util-keysyms && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var 
	+$(MAKE) CFLAGS='-std=gnu99' -C $(BUILD_WORK)/xcb-util-keysyms
=======
xcb-util-keysyms: xcb-util-keysyms-setup libxcb xcb-util
	cd $(BUILD_WORK)/xcb-util-keysyms && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS)
	+$(MAKE) -C $(BUILD_WORK)/xcb-util-keysyms
>>>>>>> 7dfd23f (uhh)
	+$(MAKE) -C $(BUILD_WORK)/xcb-util-keysyms install \
		DESTDIR=$(BUILD_STAGE)/xcb-util-keysyms
	+$(MAKE) -C $(BUILD_WORK)/xcb-util-keysyms install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xcb-util-keysyms/.build_complete
endif

xcb-util-keysyms-package: xcb-util-keysyms-stage
<<<<<<< HEAD
	rm -rf $(BUILD_DIST)/libxcb-keysyms{1,-dev}
	mkdir -p $(BUILD_DIST)/libxcb-keysyms{1,-dev}/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# util-xrm-xrm.mk Prep libutil-xrm1
	cp -a $(BUILD_STAGE)/libxcb-keysyms/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/lib-xrm.1.dylib $(BUILD_DIST)/libxcb-keysyms1/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# libxcb-keysyms.mk Prep libxcb-keysyms-dev
	cp -a $(BUILD_STAGE)/libxcb-keysyms/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/!(libxcb-keysyms.1.dylib) $(BUILD_DIST)/libxcb-keysyms-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib
	cp -a $(BUILD_STAGE)/libxcb-keysyms/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include $(BUILD_DIST)/libxcb-keysyms-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)

	# libxcb.mk Sign
	$(call SIGN,libxcb-keysyms1,general.xml)

	# libxcb-keysyms.mk Make .debs
	$(call PACK,libxcb-keysyms1,DEB_xcb-keysyms_V)
	$(call PACK,libxcb-keysyms-dev,DEB_xcb-keysyms_V)

	# libxcb-keysyms.mk Build cleanup
	rm -rf $(BUILD_DIST)/libxcb-keysyms{1,-dev}

.PHONY: xcb-util-keysyms xcb-util-keysyms-package
=======
	rm -rf $(BUILD_DIST)/libxcb-keysyms1{,-dev}
	mkdir -p $(BUILD_DIST)/libxcb-keysyms1{,-dev}/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# util-xrm-keysyms.mk Prep libxcb-keysyms
	cp -a $(BUILD_STAGE)/xcb-util-keysyms/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libxcb-keysyms.1.dylib $(BUILD_DIST)/libxcb-keysyms1/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# util-xrm-keysyms.mk Prep libxcb-keysyms-dev
	cp -a $(BUILD_STAGE)/xcb-util-keysyms/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/!(libxcb-keysyms.1.dylib) $(BUILD_DIST)/libxcb-keysyms1-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib
	cp -a $(BUILD_STAGE)/xcb-util-keysyms/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include $(BUILD_DIST)/libxcb-keysyms1-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)

	# util-xrm-keysyms.mk Sign
	$(call SIGN,libxcb-keysyms1,general.xml)

	# util-xrm-keysyms.mk Make .debs
	$(call PACK,libxcb-keysyms1,DEB_XCB-UTIL-KEYSYMS_V)
	$(call PACK,libxcb-keysyms1-dev,DEB_XCB-UTIL-KEYSYMS_V)

	# util-xrm-keysyms.mk Build cleanup
	rm -rf $(BUILD_DIST)/libxcb-keysyms1{,-dev}

.PHONY: xcb-util-keysyms xcb-util-keysyms-package
>>>>>>> 7dfd23f (uhh)
