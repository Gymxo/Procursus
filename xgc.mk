ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += xgc
XGC_VERSION := 1.0.5
DEB_XGC_V   ?= $(XGC_VERSION)

xgc-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/app/xgc-$(XGC_VERSION).tar.gz{,.sig}
	$(call PGP_VERIFY,xgc-$(XGC_VERSION).tar.gz)
	$(call EXTRACT_TAR,xgc-$(XGC_VERSION).tar.gz,xgc-$(XGC_VERSION),xgc)

ifneq ($(wildcard $(BUILD_WORK)/xgc/.build_complete),)
xgc:
	@echo "Using previously built xgc."
else
xgc: xgc-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xgc && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var
	+$(MAKE) -C $(BUILD_WORK)/xgc
	+$(MAKE) -C $(BUILD_WORK)/xgc install \
		DESTDIR=$(BUILD_STAGE)/xgc
	+$(MAKE) -C $(BUILD_WORK)/xgc install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xgc/.build_complete
endif

xgc-package: xgc-stage
# xgc.mk Package Structure
	rm -rf $(BUILD_DIST)/xgc
	
# xgc.mk Prep xgc
	cp -a $(BUILD_STAGE)/xgc $(BUILD_DIST)
	
# xgc.mk Sign
	$(call SIGN,xgc,general.xml)
	
# xgc.mk Make .debs
	$(call PACK,xgc,DEB_XGC_V)
	
# xgc.mk Build cleanup
	rm -rf $(BUILD_DIST)/xgc

.PHONY: xgc xgc-package