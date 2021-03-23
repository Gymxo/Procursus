ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += xtermwm
XTERMWM_VERSION := 0.3.0
DEB_XTERMWM_V   ?= $(XTERMWM_VERSION)

xtermwm-setup: setup
	wget -q -nc -P $(BUILD_SOURCE)  https://phoenixnap.dl.sourceforge.net/project/xtermwm/xtermwm/$(XTERMWM_VERSION)/xtermwm-$(XTERMWM_VERSION).tar.gz
	$(call EXTRACT_TAR,xtermwm-$(XTERMWM_VERSION).tar.gz,xtermwm-$(XTERMWM_VERSION),xtermwm)

ifneq ($(wildcard $(BUILD_WORK)/xtermwm/.build_complete),)
xtermwm:
	@echo "Using previously built xtermwm."
else
xtermwm: xtermwm-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xtermwm && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var
	+$(MAKE) -C $(BUILD_WORK)/xtermwm
	+$(MAKE) -C $(BUILD_WORK)/xtermwm install \
		DESTDIR=$(BUILD_STAGE)/xtermwm
	+$(MAKE) -C $(BUILD_WORK)/xtermwm install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xtermwm/.build_complete
endif

xtermwm-package: xtermwm-stage
# xtermwm.mk Package Structure
	rm -rf $(BUILD_DIST)/xtermwm
	
# xtermwm.mk Prep xtermwm
	cp -a $(BUILD_STAGE)/xtermwm $(BUILD_DIST)
	
# xtermwm.mk Sign
	$(call SIGN,xtermwm,general.xml)
	
# xtermwm.mk Make .debs
	$(call PACK,xtermwm,DEB_XTERMWM_V)
	
# xtermwm.mk Build cleanup
	rm -rf $(BUILD_DIST)/xtermwm

.PHONY: xtermwm xtermwm-package