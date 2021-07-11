ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += twm
TWM_VERSION := 1.0.11
DEB_TWM_V   ?= $(TWM_VERSION)

twm-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/app/twm-$(TWM_VERSION).tar.gz{,.sig}
	$(call PGP_VERIFY,twm-$(TWM_VERSION).tar.gz)
	$(call EXTRACT_TAR,twm-$(TWM_VERSION).tar.gz,twm-$(TWM_VERSION),twm)

ifneq ($(wildcard $(BUILD_WORK)/twm/.build_complete),)
twm:
	@echo "Using previously built twm."
else
twm: twm-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/twm && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var
	+$(MAKE) -C $(BUILD_WORK)/twm
	+$(MAKE) -C $(BUILD_WORK)/twm install \
		DESTDIR=$(BUILD_STAGE)/twm
	+$(MAKE) -C $(BUILD_WORK)/twm install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/twm/.build_complete
endif

twm-package: twm-stage
# twm.mk Package Structure
	rm -rf $(BUILD_DIST)/twm
	
# twm.mk Prep twm
	cp -a $(BUILD_STAGE)/twm $(BUILD_DIST)
	
# twm.mk Sign
	$(call SIGN,twm,general.xml)
	
# twm.mk Make .debs
	$(call PACK,twm,DEB_TWM_V)
	
# twm.mk Build cleanup
	rm -rf $(BUILD_DIST)/twm

.PHONY: twm twm-package