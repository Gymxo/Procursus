ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += libcanberra
LIBCANBERRA_VERSION := 0.30
DEB_LIBCANBERRA_V   ?= $(LIBCANBERRA_VERSION)

libcanberra-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) http://0pointer.de/lennart/projects/libcanberra/libcanberra-0.30.tar.xz
	$(call EXTRACT_TAR,libcanberra-$(LIBCANBERRA_VERSION).tar.xz,libcanberra-$(LIBCANBERRA_VERSION),libcanberra)

ifneq ($(wildcard $(BUILD_WORK)/libcanberra/.build_complete),)
libcanberra:
	find $(BUILD_STAGE)/libcanberra -type f -exec codesign --remove {} \; &> /dev/null; \
	find $(BUILD_STAGE)/libcanberra -type f -exec codesign --sign $(CODESIGN_IDENTITY) --force --preserve-metadata=entitlements,requirements,flags,runtime {} \; &> /dev/null
	@echo "Using previously built libcanberra."
else
libcanberra: libcanberra-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/libcanberra && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--disable-gstreamer \
		--disable-udev \
		--disable-pulse \
		--disable-alsa \
		--disable-oss \
		--enable-gtk \
		PKG_CONFIG_LIBDIR=$(BUILD_BASE)$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib
	find $(BUILD_WORK)/libcanberra -type f -exec sed -i 's/-Wl,--as-needed/-Wl/g' {} \;
	find $(BUILD_WORK)/libcanberra -type f -exec sed -i 's/-Wl,--gc-sections/-Wl/g' {} \;
	+$(MAKE) -i -C $(BUILD_WORK)/libcanberra
	+$(MAKE) -i -C $(BUILD_WORK)/libcanberra install \
		DESTDIR=$(BUILD_STAGE)/libcanberra
	+$(MAKE) -i -C $(BUILD_WORK)/libcanberra install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/libcanberra/.build_complete
endif

libcanberra-package: libcanberra-stage
	# libcanberra.mk Package Structure
	rm -rf $(BUILD_DIST)/libcanberra

	# libcanberra.mk Prep libcanberra
	cp -a $(BUILD_STAGE)/libcanberra $(BUILD_DIST)

	# libcanberra.mk Sign
	$(call SIGN,libcanberra,general.xml)

	# libcanberra.mk Make .debs
	$(call PACK,libcanberra,DEB_LIBCANBERRA_V)

	# libcanberra.mk Build cleanup
	rm -rf $(BUILD_DIST)/libcanberra

.PHONY: libcanberra libcanberra-package
