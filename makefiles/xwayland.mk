ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += xwayland
XWAYLAND_VERSION := 21.1.1
DEB_XWAYLAND_V   ?= $(XWAYLAND_VERSION)

xwayland-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/xserver/xwayland-$(XWAYLAND_VERSION).tar.xz{,.sig}
	$(call PGP_VERIFY,xwayland-$(XWAYLAND_VERSION).tar.xz)
	$(call EXTRACT_TAR,xwayland-$(XWAYLAND_VERSION).tar.xz,xwayland-$(XWAYLAND_VERSION),xwayland)

ifneq ($(wildcard $(BUILD_WORK)/xwayland/.build_complete),)
xwayland:
	@echo "Using previously built xwayland."
else
xwayland: xwayland-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xwayland && ./configure -h -C \
		$(DEFAULT_CONFIGURE_FLAGS)
	+$(MAKE) -C $(BUILD_WORK)/xwayland
	+$(MAKE) -C $(BUILD_WORK)/xwayland install \
		DESTDIR=$(BUILD_STAGE)/xwayland
	+$(MAKE) -C $(BUILD_WORK)/xwayland install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xwayland/.build_complete
endif

xwayland-package: xwayland-stage
	# xwayland.mk Package Structure
	rm -rf $(BUILD_DIST)/xwayland

	# xwayland.mk Prep xwayland
	cp -a $(BUILD_STAGE)/xwayland $(BUILD_DIST)

	# xwayland.mk Sign
	$(call SIGN,xwayland,general.xml)

	# xwayland.mk Make .debs
	$(call PACK,xwayland,DEB_XWAYLAND_V)

	# xwayland.mk Build cleanup
	rm -rf $(BUILD_DIST)/xwayland

.PHONY: xwayland xwayland-package
