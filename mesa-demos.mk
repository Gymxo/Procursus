ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += mesa-demos
MESA-DEMOS_VERSION := 8.4.0
DEB_MESA-DEMOS_V   ?= $(MESA-DEMOS_VERSION)

mesa-demos-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://archive.mesa3d.org/demos/mesa-demos-$(MESA-DEMOS_VERSION).tar.gz{,.sig} 
	$(call PGP_VERIFY,mesa-demos-$(MESA-DEMOS_VERSION).tar.gz)
	$(call EXTRACT_TAR,mesa-demos-$(MESA-DEMOS_VERSION).tar.gz,mesa-demos-$(MESA-DEMOS_VERSION),mesa-demos)

ifneq ($(wildcard $(BUILD_WORK)/mesa-demos/.build_complete),)
mesa-demos:
	@echo "Using previously built mesa-demos."
else
mesa-demos: mesa-demos-setup libx11 libxau libxmu xorgproto mesa
	cd $(BUILD_WORK)/mesa-demos && ./autogen.sh \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var
	+$(MAKE) -C $(BUILD_WORK)/mesa-demos
	+$(MAKE) -C $(BUILD_WORK)/mesa-demos install \
		DESTDIR=$(BUILD_STAGE)/mesa-demos
	+$(MAKE) -C $(BUILD_WORK)/mesa-demos install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/mesa-demos/.build_complete
endif

mesa-demos-package: mesa-demos-stage
# mesa-demos.mk Package Structure
	rm -rf $(BUILD_DIST)/mesa-demos
	
# mesa-demos.mk Prep mesa-demos
	cp -a $(BUILD_STAGE)/mesa-demos $(BUILD_DIST)
	
# mesa-demos.mk Sign
	$(call SIGN,mesa-demos,general.xml)
	
# mesa-demos.mk Make .debs
	$(call PACK,mesa-demos,DEB_MESA-DEMOS_V)
	
# mesa-demos.mk Build cleanup
	rm -rf $(BUILD_DIST)/mesa-demos

.PHONY: mesa-demos mesa-demos-package