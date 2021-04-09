ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += xdm
XDM_VERSION := 1.1.12
DEB_XDM_V   ?= $(XDM_VERSION)

xdm-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/app/xdm-$(XDM_VERSION).tar.gz{,.sig}
	$(call PGP_VERIFY,xdm-$(XDM_VERSION).tar.gz)
	$(call EXTRACT_TAR,xdm-$(XDM_VERSION).tar.gz,xdm-$(XDM_VERSION),xdm)

ifneq ($(wildcard $(BUILD_WORK)/xdm/.build_complete),)
xdm:
	@echo "Using previously built xdm."
else
xdm: xdm-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xdm && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var
	+$(MAKE) -C $(BUILD_WORK)/xdm
	+$(MAKE) -C $(BUILD_WORK)/xdm install \
		DESTDIR=$(BUILD_STAGE)/xdm
	+$(MAKE) -C $(BUILD_WORK)/xdm install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xdm/.build_complete
endif

xdm-package: xdm-stage
# xdm.mk Package Structure
	rm -rf $(BUILD_DIST)/xdm
	
# xdm.mk Prep xdm
	cp -a $(BUILD_STAGE)/xdm $(BUILD_DIST)
	
# xdm.mk Sign
	$(call SIGN,xdm,general.xml)
	
# xdm.mk Make .debs
	$(call PACK,xdm,DEB_XDM_V)
	
# xdm.mk Build cleanup
	rm -rf $(BUILD_DIST)/xdm

.PHONY: xdm xdm-package