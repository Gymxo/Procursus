ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += xlogo
XLOGO_VERSION := 1.0.5
DEB_XLOGO_V   ?= $(XLOGO_VERSION)

xlogo-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/app/xlogo-$(XLOGO_VERSION).tar.gz{,.sig}
	$(call PGP_VERIFY,xlogo-$(XLOGO_VERSION).tar.gz)
	$(call EXTRACT_TAR,xlogo-$(XLOGO_VERSION).tar.gz,xlogo-$(XLOGO_VERSION),xlogo)

ifneq ($(wildcard $(BUILD_WORK)/xlogo/.build_complete),)
xlogo:
	@echo "Using previously built xlogo."
else
xlogo: xlogo-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xlogo && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var
	+$(MAKE) -C $(BUILD_WORK)/xlogo
	+$(MAKE) -C $(BUILD_WORK)/xlogo install \
		DESTDIR=$(BUILD_STAGE)/xlogo
	+$(MAKE) -C $(BUILD_WORK)/xlogo install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xlogo/.build_complete
endif

xlogo-package: xlogo-stage
# xlogo.mk Package Structure
	rm -rf $(BUILD_DIST)/xlogo
	
# xlogo.mk Prep xlogo
	cp -a $(BUILD_STAGE)/xlogo $(BUILD_DIST)
	
# xlogo.mk Sign
	$(call SIGN,xlogo,general.xml)
	
# xlogo.mk Make .debs
	$(call PACK,xlogo,DEB_XLOGO_V)
	
# xlogo.mk Build cleanup
	rm -rf $(BUILD_DIST)/xlogo

.PHONY: xlogo xlogo-package