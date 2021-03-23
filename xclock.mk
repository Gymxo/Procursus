ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += xclock
XCLOCK_VERSION := 1.0.8
DEB_XCLOCK_V   ?= $(XCLOCK_VERSION)

xclock-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive//individual/app/xclock-$(XCLOCK_VERSION).tar.gz{,.sig}
	$(call PGP_VERIFY,xclock-$(XCLOCK_VERSION).tar.gz)
	$(call EXTRACT_TAR,xclock-$(XCLOCK_VERSION).tar.gz,xclock-$(XCLOCK_VERSION),xclock)

ifneq ($(wildcard $(BUILD_WORK)/xclock/.build_complete),)
xclock:
	@echo "Using previously built xclock."
else
xclock: xclock-setup libx11 libxau libxmu xorgproto libXaw libxrender libXft
	cd $(BUILD_WORK)/xclock && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var
	+$(MAKE) -C $(BUILD_WORK)/xclock
	+$(MAKE) -C $(BUILD_WORK)/xclock install \
		DESTDIR=$(BUILD_STAGE)/xclock
	+$(MAKE) -C $(BUILD_WORK)/xclock install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xclock/.build_complete
endif

xclock-package: xclock-stage
# xclock.mk Package Structure
	rm -rf $(BUILD_DIST)/xclock
	
# xclock.mk Prep xclock
	cp -a $(BUILD_STAGE)/xclock $(BUILD_DIST)
	
# xclock.mk Sign
	$(call SIGN,xclock,general.xml)
	
# xclock.mk Make .debs
	$(call PACK,xclock,DEB_XCLOCK_V)
	
# xclock.mk Build cleanup
	rm -rf $(BUILD_DIST)/xclock

.PHONY: xclock xclock-package