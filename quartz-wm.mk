ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += quartz-wm
QUARTZ-WM_VERSION := 1.3.2
DEB_QUARTZ-WM_V   ?= $(QUARTZ-WM_VERSION)

quartz-wm-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://github.com/XQuartz/quartz-wm/releases/download/quartz-wm-$(QUARTZ-WM_VERSION)/quartz-wm-$(QUARTZ-WM_VERSION).tar.xz{,.sig}
	$(call PGP_VERIFY,quartz-wm-$(QUARTZ-WM_VERSION).tar.xz)
	$(call EXTRACT_TAR,quartz-wm-$(QUARTZ-WM_VERSION).tar.xz,quartz-wm-$(QUARTZ-WM_VERSION),quartz-wm)

ifneq ($(wildcard $(BUILD_WORK)/quartz-wm/.build_complete),)
quartz-wm:
	@echo "Using previously built quartz-wm."
else
quartz-wm: quartz-wm-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/quartz-wm && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var 
	+$(MAKE) -C $(BUILD_WORK)/quartz-wm
	+$(MAKE) -C $(BUILD_WORK)/quartz-wm install \
		DESTDIR=$(BUILD_STAGE)/quartz-wm
	+$(MAKE) -C $(BUILD_WORK)/quartz-wm install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/quartz-wm/.build_complete
endif

quartz-wm-package: quartz-wm-stage
# quartz-wm.mk Package Structure
	rm -rf $(BUILD_DIST)/quartz-wm
	
# quartz-wm.mk Prep quartz-wm
	cp -a $(BUILD_STAGE)/quartz-wm $(BUILD_DIST)
	
# quartz-wm.mk Sign
	$(call SIGN,quartz-wm,general.xml)
	
# quartz-wm.mk Make .debs
	$(call PACK,quartz-wm,DEB_QUARTZ-WM_V)
	
# quartz-wm.mk Build cleanup
	rm -rf $(BUILD_DIST)/quartz-wm

.PHONY: quartz-wm quartz-wm-package