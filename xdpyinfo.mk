ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += xdpyinfo
XDPYINFO_VERSION := 1.3.2
DEB_XDPYINFO_V   ?= $(XDPYINFO_VERSION)

xdpyinfo-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/app/xdpyinfo-$(XDPYINFO_VERSION).tar.gz{,.sig}
	$(call PGP_VERIFY,xdpyinfo-$(XDPYINFO_VERSION).tar.gz)
	$(call EXTRACT_TAR,xdpyinfo-$(XDPYINFO_VERSION).tar.gz,xdpyinfo-$(XDPYINFO_VERSION),xdpyinfo)

ifneq ($(wildcard $(BUILD_WORK)/xdpyinfo/.build_complete),)
xdpyinfo:
	@echo "Using previously built xdpyinfo."
else
xdpyinfo: xdpyinfo-setup libx11 libxau libxmu xorgproto
	cd $(BUILD_WORK)/xdpyinfo && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var
	+$(MAKE) -C $(BUILD_WORK)/xdpyinfo
	+$(MAKE) -C $(BUILD_WORK)/xdpyinfo install \
		DESTDIR=$(BUILD_STAGE)/xdpyinfo
	+$(MAKE) -C $(BUILD_WORK)/xdpyinfo install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xdpyinfo/.build_complete
endif

xdpyinfo-package: xdpyinfo-stage
# xdpyinfo.mk Package Structure
	rm -rf $(BUILD_DIST)/xdpyinfo
	
# xdpyinfo.mk Prep xdpyinfo
	cp -a $(BUILD_STAGE)/xdpyinfo $(BUILD_DIST)
	
# xdpyinfo.mk Sign
	$(call SIGN,xdpyinfo,general.xml)
	
# xdpyinfo.mk Make .debs
	$(call PACK,xdpyinfo,DEB_XDPYINFO_V)
	
# xdpyinfo.mk Build cleanup
	rm -rf $(BUILD_DIST)/xdpyinfo

.PHONY: xdpyinfo xdpyinfo-package