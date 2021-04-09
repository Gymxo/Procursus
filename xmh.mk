ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += xmh
XMH_VERSION := 1.0.3
DEB_XMH_V   ?= $(XMH_VERSION)

xmh-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/app/xmh-$(XMH_VERSION).tar.gz{,.sig}
	$(call PGP_VERIFY,xmh-$(XMH_VERSION).tar.gz)
	$(call EXTRACT_TAR,xmh-$(XMH_VERSION).tar.gz,xmh-$(XMH_VERSION),xmh)

ifneq ($(wildcard $(BUILD_WORK)/xmh/.build_complete),)
xmh:
	@echo "Using previously built xmh."
else
xmh: xmh-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xmh && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var
	+$(MAKE) -C $(BUILD_WORK)/xmh
	+$(MAKE) -C $(BUILD_WORK)/xmh install \
		DESTDIR=$(BUILD_STAGE)/xmh
	+$(MAKE) -C $(BUILD_WORK)/xmh install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xmh/.build_complete
endif

xmh-package: xmh-stage
# xmh.mk Package Structure
	rm -rf $(BUILD_DIST)/xmh
	
# xmh.mk Prep xmh
	cp -a $(BUILD_STAGE)/xmh $(BUILD_DIST)
	
# xmh.mk Sign
	$(call SIGN,xmh,general.xml)
	
# xmh.mk Make .debs
	$(call PACK,xmh,DEB_XMH_V)
	
# xmh.mk Build cleanup
	rm -rf $(BUILD_DIST)/xmh

.PHONY: xmh xmh-package