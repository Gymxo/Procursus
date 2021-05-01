ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += wayland
WAYLAND_VERSION := 1.19.0
DEB_WAYLAND_V   ?= $(WAYLAND_VERSION)

wayland-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://wayland.freedesktop.org/releases/wayland-$(WAYLAND_VERSION).tar.xz
	$(call EXTRACT_TAR,wayland-$(WAYLAND_VERSION).tar.xz,wayland-$(WAYLAND_VERSION),wayland)

ifneq ($(wildcard $(BUILD_WORK)/wayland/.build_complete),)
wayland:
	@echo "Using previously built wayland."
else
wayland: wayland-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/wayland && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-host-scanner \
		--disable-libraries \
		--disable-documentation
	+$(MAKE) -i -C $(BUILD_WORK)/wayland
	+$(MAKE) -i -C $(BUILD_WORK)/wayland install \
		DESTDIR=$(BUILD_STAGE)/wwayland
	+$(MAKE) -i -C $(BUILD_WORK)/wayland install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/wayland/.build_complete
endif

wayland-package: wayland-stage
	# wayland.mk Package Structure
	rm -rf $(BUILD_DIST)/wayland

	# wayland.mk Prep wayland
	cp -a $(BUILD_STAGE)/wayland $(BUILD_DIST)

	# wayland.mk Sign
	$(call SIGN,wayland,general.xml)

	# wayland.mk Make .debs
	$(call PACK,wayland,DEB_WAYLAND_V)

	# wayland.mk Build cleanup
	rm -rf $(BUILD_DIST)/wayland

.PHONY: wayland wayland-package
