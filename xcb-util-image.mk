ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

<<<<<<< HEAD
SUBPROJECTS    += xcb-util-image
=======
SUBPROJECTS            += xcb-util-image
>>>>>>> 7dfd23f (uhh)
XCB-UTIL-IMAGE_VERSION := 0.4.0
DEB_XCB-UTIL-IMAGE_V   ?= $(XCB-UTIL-IMAGE_VERSION)

xcb-util-image-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/xcb/xcb-util-image-$(XCB-UTIL-IMAGE_VERSION).tar.gz
	$(call EXTRACT_TAR,xcb-util-image-$(XCB-UTIL-IMAGE_VERSION).tar.gz,xcb-util-image-$(XCB-UTIL-IMAGE_VERSION),xcb-util-image)

ifneq ($(wildcard $(BUILD_WORK)/xcb-util-image/.build_complete),)
xcb-util-image:
	@echo "Using previously built xcb-util-image."
else
<<<<<<< HEAD
xcb-util-image: xcb-util-image-setup libxcb
	cd $(BUILD_WORK)/xcb-util-image && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var 
=======
xcb-util-image: xcb-util-image-setup libxcb xcb-util
	cd $(BUILD_WORK)/xcb-util-image && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS)
>>>>>>> 7dfd23f (uhh)
	+$(MAKE) -C $(BUILD_WORK)/xcb-util-image
	+$(MAKE) -C $(BUILD_WORK)/xcb-util-image install \
		DESTDIR=$(BUILD_STAGE)/xcb-util-image
	+$(MAKE) -C $(BUILD_WORK)/xcb-util-image install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xcb-util-image/.build_complete
endif

xcb-util-image-package: xcb-util-image-stage
	rm -rf $(BUILD_DIST)/libxcb-image0{,-dev}
	mkdir -p $(BUILD_DIST)/libxcb-image0{,-dev}/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

<<<<<<< HEAD
	# xcb-util-image.mk Prep libxcb-image9
=======
	# xcb-util-image.mk Prep libxcb-image0
>>>>>>> 7dfd23f (uhh)
	cp -a $(BUILD_STAGE)/xcb-util-image/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libxcb-image.0.dylib $(BUILD_DIST)/libxcb-image0/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# xcb-util-image.mk Prep libxcb-image-dev
	cp -a $(BUILD_STAGE)/xcb-util-image/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/!(libxcb-image.0.dylib) $(BUILD_DIST)/libxcb-image0-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib
	cp -a $(BUILD_STAGE)/xcb-util-image/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include $(BUILD_DIST)/libxcb-image0-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)

	# xcb-util-image.mk Sign
	$(call SIGN,libxcb-image0,general.xml)

	# xcb-util-image.mk Make .debs
	$(call PACK,libxcb-image0,DEB_XCB-UTIL-IMAGE_V)
	$(call PACK,libxcb-image0-dev,DEB_XCB-UTIL-IMAGE_V)

	# xcb-util-image.mk Build cleanup
	rm -rf $(BUILD_DIST)/libxcb-image0{,-dev}

<<<<<<< HEAD
.PHONY: xcb-util-image xcb-util-image-package
=======
.PHONY: xcb-util-image xcb-util-image-package
>>>>>>> 7dfd23f (uhh)
