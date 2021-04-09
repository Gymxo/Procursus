ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += xcalc
XCALC_VERSION := 1.1.0
DEB_XCALC_V   ?= $(XCALC_VERSION)

xcalc-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/app/xcalc-$(XCALC_VERSION).tar.gz{,.sig}
	$(call PGP_VERIFY,xcalc-$(XCALC_VERSION).tar.gz)
	$(call EXTRACT_TAR,xcalc-$(XCALC_VERSION).tar.gz,xcalc-$(XCALC_VERSION),xcalc)

ifneq ($(wildcard $(BUILD_WORK)/xcalc/.build_complete),)
xcalc:
	@echo "Using previously built xcalc."
else
xcalc: xcalc-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xcalc && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var
	+$(MAKE) -C $(BUILD_WORK)/xcalc
	+$(MAKE) -C $(BUILD_WORK)/xcalc install \
		DESTDIR=$(BUILD_STAGE)/xcalc
	+$(MAKE) -C $(BUILD_WORK)/xcalc install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xcalc/.build_complete
endif

xcalc-package: xcalc-stage
# xcalc.mk Package Structure
	rm -rf $(BUILD_DIST)/xcalc
	
# xcalc.mk Prep xcalc
	cp -a $(BUILD_STAGE)/xcalc $(BUILD_DIST)
	
# xcalc.mk Sign
	$(call SIGN,xcalc,general.xml)
	
# xcalc.mk Make .debs
	$(call PACK,xcalc,DEB_XCALC_V)
	
# xcalc.mk Build cleanup
	rm -rf $(BUILD_DIST)/xcalc

.PHONY: xcalc xcalc-package