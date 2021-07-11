ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += xeyes
XEYES_VERSION := 1.1.2
DEB_XEYES_V   ?= $(XEYES_VERSION)

xeyes-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/app/xeyes-$(XEYES_VERSION).tar.gz{,.sig}
	$(call PGP_VERIFY,xeyes-$(XEYES_VERSION).tar.gz)
	$(call EXTRACT_TAR,xeyes-$(XEYES_VERSION).tar.gz,xeyes-$(XEYES_VERSION),xeyes)

ifneq ($(wildcard $(BUILD_WORK)/xeyes/.build_complete),)
xeyes:
	@echo "Using previously built xeyes."
else
xeyes: xeyes-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xeyes && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var
	+$(MAKE) -C $(BUILD_WORK)/xeyes
	+$(MAKE) -C $(BUILD_WORK)/xeyes install \
		DESTDIR=$(BUILD_STAGE)/xeyes
	+$(MAKE) -C $(BUILD_WORK)/xeyes install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xeyes/.build_complete
endif

xeyes-package: xeyes-stage
# xeyes.mk Package Structure
	rm -rf $(BUILD_DIST)/xeyes
	
# xeyes.mk Prep xeyes
	cp -a $(BUILD_STAGE)/xeyes $(BUILD_DIST)
	
# xeyes.mk Sign
	$(call SIGN,xeyes,general.xml)
	
# xeyes.mk Make .debs
	$(call PACK,xeyes,DEB_XEYES_V)
	
# xeyes.mk Build cleanup
	rm -rf $(BUILD_DIST)/xeyes

.PHONY: xeyes xeyes-package