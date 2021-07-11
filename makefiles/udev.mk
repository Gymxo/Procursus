ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += udev
UDEV_VERSION := 2.73.1
DEB_UDEV_V   ?= $(UDEV_VERSION)

udev-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://github.com/msekletar/udev/archive/refs/tags/udev-147-2.73.1.tar.gz
	$(call EXTRACT_TAR,udev-147-2.73.1.tar.gz,udev-udev-147-2.73.1,udev)

ifneq ($(wildcard $(BUILD_WORK)/udev/.build_complete),)
udev:
	@echo "Using previously built udev."
else
udev: udev-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/udev && autoreconf -fiv && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--disable-introspection \
		--disable-extras 
	+$(MAKE) -C $(BUILD_WORK)/udev
	+$(MAKE) -C $(BUILD_WORK)/udev install \
		DESTDIR=$(BUILD_STAGE)/udev
	+$(MAKE) -C $(BUILD_WORK)/udev install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/udev/.build_complete
endif

udev-package: udev-stage
	# udev.mk Package Structure
	rm -rf $(BUILD_DIST)/udev

	# udev.mk Prep udev
	cp -a $(BUILD_STAGE)/udev $(BUILD_DIST)

	# udev.mk Sign
	$(call SIGN,udev,general.xml)

	# udev.mk Make .debs
	$(call PACK,udev,DEB_UDEV_V)

	# udev.mk Build cleanup
	rm -rf $(BUILD_DIST)/udev

.PHONY: udev udev-package
