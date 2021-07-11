ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += ico
ICO_VERSION := 1.0.5
DEB_ICO_V   ?= $(ICO_VERSION)

ico-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/app/ico-$(ICO_VERSION).tar.gz{,.sig}
	$(call PGP_VERIFY,ico-$(ICO_VERSION).tar.gz)
	$(call EXTRACT_TAR,ico-$(ICO_VERSION).tar.gz,ico-$(ICO_VERSION),ico)

ifneq ($(wildcard $(BUILD_WORK)/ico/.build_complete),)
ico:
	@echo "Using previously built ico."
else
ico: ico-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/ico && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var
	+$(MAKE) -C $(BUILD_WORK)/ico
	+$(MAKE) -C $(BUILD_WORK)/ico install \
		DESTDIR=$(BUILD_STAGE)/ico
	+$(MAKE) -C $(BUILD_WORK)/ico install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/ico/.build_complete
endif

ico-package: ico-stage
# ico.mk Package Structure
	rm -rf $(BUILD_DIST)/ico
	
# ico.mk Prep ico
	cp -a $(BUILD_STAGE)/ico $(BUILD_DIST)
	
# ico.mk Sign
	$(call SIGN,ico,general.xml)
	
# ico.mk Make .debs
	$(call PACK,ico,DEB_ICO_V)
	
# ico.mk Build cleanup
	rm -rf $(BUILD_DIST)/ico

.PHONY: ico ico-package