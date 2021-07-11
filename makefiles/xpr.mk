ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += xpr
XPR_VERSION := 1.0.5
DEB_XPR_V   ?= $(XPR_VERSION)

xpr-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive//individual/app/xpr-$(XPR_VERSION).tar.gz{,.sig}
	$(call PGP_VERIFY,xpr-$(XPR_VERSION).tar.gz)
	$(call EXTRACT_TAR,xpr-$(XPR_VERSION).tar.gz,xpr-$(XPR_VERSION),xpr)

ifneq ($(wildcard $(BUILD_WORK)/xpr/.build_complete),)
xpr:
	@echo "Using previously built xpr."
else
xpr: xpr-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xpr && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var
	+$(MAKE) -C $(BUILD_WORK)/xpr
	+$(MAKE) -C $(BUILD_WORK)/xpr install \
		DESTDIR=$(BUILD_STAGE)/xpr
	+$(MAKE) -C $(BUILD_WORK)/xpr install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xpr/.build_complete
endif

xpr-package: xpr-stage
# xpr.mk Package Structure
	rm -rf $(BUILD_DIST)/xpr
	
# xpr.mk Prep xpr
	cp -a $(BUILD_STAGE)/xpr $(BUILD_DIST)
	
# xpr.mk Sign
	$(call SIGN,xpr,general.xml)
	
# xpr.mk Make .debs
	$(call PACK,xpr,DEB_xpr_V)
	
# xpr.mk Build cleanup
	rm -rf $(BUILD_DIST)/xpr

.PHONY: xpr xpr-package