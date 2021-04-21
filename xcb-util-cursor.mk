ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

<<<<<<< HEAD
SUBPROJECTS    += xcb-util-cursor
=======
SUBPROJECTS             += xcb-util-cursor
>>>>>>> 07d9fb6e4182e2de4d01175e229348545cc588a4
XCB-UTIL-CURSOR_VERSION := 0.1.3
DEB_XCB-UTIL-CURSOR_V   ?= $(XCB-UTIL-CURSOR_VERSION)

xcb-util-cursor-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/xcb/xcb-util-cursor-$(XCB-UTIL-CURSOR_VERSION).tar.gz
	$(call EXTRACT_TAR,xcb-util-cursor-$(XCB-UTIL-CURSOR_VERSION).tar.gz,xcb-util-cursor-$(XCB-UTIL-CURSOR_VERSION),xcb-util-cursor)

ifneq ($(wildcard $(BUILD_WORK)/xcb-util-cursor/.build_complete),)
xcb-util-cursor:
	@echo "Using previously built xcb-util-cursor."
else
<<<<<<< HEAD
xcb-util-cursor: xcb-util-cursor-setup libxcb
	cd $(BUILD_WORK)/xcb-util-cursor && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var 
	+$(MAKE) CFLAGS='-std=gnu99' -C $(BUILD_WORK)/xcb-util-cursor
=======
xcb-util-cursor: xcb-util-cursor-setup libxcb xcb-util xcb-util-renderutil xcb-util-image
	cd $(BUILD_WORK)/xcb-util-cursor && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		CFLAGS="$(CFLAGS) -DHAVE_LIBKERN_OSBYTEORDER_H"
	+$(MAKE) -C $(BUILD_WORK)/xcb-util-cursor
>>>>>>> 07d9fb6e4182e2de4d01175e229348545cc588a4
	+$(MAKE) -C $(BUILD_WORK)/xcb-util-cursor install \
		DESTDIR=$(BUILD_STAGE)/xcb-util-cursor
	+$(MAKE) -C $(BUILD_WORK)/xcb-util-cursor install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xcb-util-cursor/.build_complete
endif

xcb-util-cursor-package: xcb-util-cursor-stage
<<<<<<< HEAD
	rm -rf $(BUILD_DIST)/libxcb-cursor{1,-dev}
	mkdir -p $(BUILD_DIST)/libxcb-cursor{1,-dev}/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# libxcb-curosr.mk Prep libutil-xrm1
	cp -a $(BUILD_STAGE)/libxcb-cursor/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/lib-xrm.1.dylib $(BUILD_DIST)/libxcb-cursor1/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# libxcb-cursor.mk Prep libxcb-cursor-dev
	cp -a $(BUILD_STAGE)/libxcb-cursor/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/!(libxcb-cursor.1.dylib) $(BUILD_DIST)/libxcb-cursor-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib
	cp -a $(BUILD_STAGE)/libxcb-cursor/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include $(BUILD_DIST)/libxcb-cursor-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)

	# libxcb-cursor.mk Sign
	$(call SIGN,libxcb-cursor1,general.xml)

	# libxcb-cursor.mk Make .debs
	$(call PACK,libxcb-cursor1,DEB_xcb-cursor_V)
	$(call PACK,libxcb-cursor-dev,DEB_xcb-cursor_V)

	# libxcb-cursor.mk Build cleanup
	rm -rf $(BUILD_DIST)/libxcb-cursor{1,-dev}

.PHONY: xcb-util-cursor xcb-util-cursor-package
=======
	rm -rf $(BUILD_DIST)/libxcb-cursor{0,-dev}
	mkdir -p $(BUILD_DIST)/libxcb-cursor{0,-dev}/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# xcb-util-cursor.mk Prep libxcb-cursor0
	cp -a $(BUILD_STAGE)/xcb-util-cursor/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libxcb-cursor.0.dylib $(BUILD_DIST)/libxcb-cursor0/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# xcb-util-cursor.mk Prep libxcb-cursor-dev
	cp -a $(BUILD_STAGE)/xcb-util-cursor/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/!(libxcb-cursor.0.dylib) $(BUILD_DIST)/libxcb-cursor-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib
	cp -a $(BUILD_STAGE)/xcb-util-cursor/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include $(BUILD_DIST)/libxcb-cursor-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)

	# xcb-util-cursor.mk Sign
	$(call SIGN,libxcb-cursor0,general.xml)

	# xcb-util-cursor.mk Make .debs
	$(call PACK,libxcb-cursor0,DEB_XCB-UTIL-CURSOR_V)
	$(call PACK,libxcb-cursor-dev,DEB_XCB-UTIL-CURSOR_V)

	# xcb-util-cursor.mk Build cleanup
	rm -rf $(BUILD_DIST)/libxcb-cursor{0,-dev}

.PHONY: xcb-util-cursor xcb-util-cursor-package
>>>>>>> 07d9fb6e4182e2de4d01175e229348545cc588a4
