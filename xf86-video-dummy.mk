ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += xf86-video-dummy
DUMMY_VERSION := 0.3.8
DEB_DUMMY_V   ?= $(DUMMY_VERSION)

xf86-video-dummy-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://gitlab.freedesktop.org/xorg/driver/xf86-video-dummy/-/archive/xf86-video-dummy-0.3.8/xf86-video-dummy-xf86-video-dummy-0.3.8.tar.gz
	$(call EXTRACT_TAR,xf86-video-dummy-xf86-video-dummy-$(DUMMY_VERSION).tar.gz,xf86-video-dummy-xf86-video-dummy-$(DUMMY_VERSION),xf86-video-dummy)

ifneq ($(wildcard $(BUILD_WORK)/xf86-video-dummy/.build_complete),)
xf86-video-dummy:
	@echo "Using previously built xf86-video-dummy."
else
xf86-video-dummy: xf86-video-dummy-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xf86-video-dummy && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var
	+$(MAKE) -C $(BUILD_WORK)/xf86-video-dummy
	+$(MAKE) -C $(BUILD_WORK)/xf86-video-dummy install \
		DESTDIR=$(BUILD_STAGE)/xf86-video-dummy
	+$(MAKE) -C $(BUILD_WORK)/xf86-video-dummy install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xf86-video-dummy/.build_complete
endif

xf86-video-dummy-package: xf86-video-dummy-stage
# xf86-video-dummy.mk Package Structure
	rm -rf $(BUILD_DIST)/xf86-video-dummy
	
# xf86-video-dummy.mk Prep xf86-video-dummy
	cp -a $(BUILD_STAGE)/xf86-video-dummy $(BUILD_DIST)
	
# xf86-video-dummy.mk Sign
	$(call SIGN,xf86-video-dummy,general.xml)
	
# xf86-video-dummy.mk Make .debs
	$(call PACK,xf86-video-dummy,DEB_DUMMY_V)
	
# xf86-video-dummy.mk Build cleanup
	rm -rf $(BUILD_DIST)/xf86-video-dummy

.PHONY: xf86-video-dummy xf86-video-dummy-package