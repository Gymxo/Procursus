ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += xman
XMAN_VERSION := 1.1.5
DEB_XMAN_V   ?= $(XMAN_VERSION)

xman-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/app/xman-$(XMAN_VERSION).tar.gz{,.sig}
	$(call PGP_VERIFY,xman-$(XMAN_VERSION).tar.gz)
	$(call EXTRACT_TAR,xman-$(XMAN_VERSION).tar.gz,xman-$(XMAN_VERSION),xman)

ifneq ($(wildcard $(BUILD_WORK)/xman/.build_complete),)
xman:
	@echo "Using previously built xman."
else
xman: xman-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xman && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var
	+$(MAKE) -C $(BUILD_WORK)/xman
	+$(MAKE) -C $(BUILD_WORK)/xman install \
		DESTDIR=$(BUILD_STAGE)/xman
	+$(MAKE) -C $(BUILD_WORK)/xman install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xman/.build_complete
endif

xman-package: xman-stage
# xman.mk Package Structure
	rm -rf $(BUILD_DIST)/xman
	
# xman.mk Prep xman
	cp -a $(BUILD_STAGE)/xman $(BUILD_DIST)
	
# xman.mk Sign
	$(call SIGN,xman,general.xml)
	
# xman.mk Make .debs
	$(call PACK,xman,DEB_XMAN_V)
	
# xman.mk Build cleanup
	rm -rf $(BUILD_DIST)/xman

.PHONY: xman xman-package