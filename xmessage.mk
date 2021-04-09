ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += xmessage
XMESSAGE_VERSION := 1.0.5
DEB_XMESSAGE_V   ?= $(XMESSAGE_VERSION)

xmessage-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/app/xmessage-$(XMESSAGE_VERSION).tar.gz{,.sig}
	$(call PGP_VERIFY,xmessage-$(XMESSAGE_VERSION).tar.gz)
	$(call EXTRACT_TAR,xmessage-$(XMESSAGE_VERSION).tar.gz,xmessage-$(XMESSAGE_VERSION),xmessage)

ifneq ($(wildcard $(BUILD_WORK)/xmessage/.build_complete),)
xmessage:
	@echo "Using previously built xmessage."
else
xmessage: xmessage-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xmessage && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var
	+$(MAKE) -C $(BUILD_WORK)/xmessage
	+$(MAKE) -C $(BUILD_WORK)/xmessage install \
		DESTDIR=$(BUILD_STAGE)/xmessage
	+$(MAKE) -C $(BUILD_WORK)/xmessage install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xmessage/.build_complete
endif

xmessage-package: xmessage-stage
# xmessage.mk Package Structure
	rm -rf $(BUILD_DIST)/xmessage
	
# xmessage.mk Prep xmessage
	cp -a $(BUILD_STAGE)/xmessage $(BUILD_DIST)
	
# xmessage.mk Sign
	$(call SIGN,xmessage,general.xml)
	
# xmessage.mk Make .debs
	$(call PACK,xmessage,DEB_XMESSAGE_V)
	
# xmessage.mk Build cleanup
	rm -rf $(BUILD_DIST)/xmessage

.PHONY: xmessage xmessage-package