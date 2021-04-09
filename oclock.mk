ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += oclock
OCLOCK_VERSION := 1.0.4
DEB_OCLOCK_V   ?= $(OCLOCK_VERSION)

oclock-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/app/oclock-$(OCLOCK_VERSION).tar.gz{,.sig}
	$(call PGP_VERIFY,oclock-$(OCLOCK_VERSION).tar.gz)
	$(call EXTRACT_TAR,oclock-$(OCLOCK_VERSION).tar.gz,oclock-$(OCLOCK_VERSION),oclock)

ifneq ($(wildcard $(BUILD_WORK)/oclock/.build_complete),)
oclock:
	@echo "Using previously built oclock."
else
oclock: oclock-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/oclock && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var
	+$(MAKE) -C $(BUILD_WORK)/oclock
	+$(MAKE) -C $(BUILD_WORK)/oclock install \
		DESTDIR=$(BUILD_STAGE)/oclock
	+$(MAKE) -C $(BUILD_WORK)/oclock install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/oclock/.build_complete
endif

oclock-package: oclock-stage
# oclock.mk Package Structure
	rm -rf $(BUILD_DIST)/oclock
	
# oclock.mk Prep oclock
	cp -a $(BUILD_STAGE)/oclock $(BUILD_DIST)
	
# oclock.mk Sign
	$(call SIGN,oclock,general.xml)
	
# oclock.mk Make .debs
	$(call PACK,oclock,DEB_OCLOCK_V)
	
# oclock.mk Build cleanup
	rm -rf $(BUILD_DIST)/oclock

.PHONY: oclock oclock-package