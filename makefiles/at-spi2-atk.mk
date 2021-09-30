ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += at-spi2-atk
AT-SPI2-ATK_VERSION := 2.38.0
DEB_AT-SPI2-ATK_V   ?= $(AT-SPI2-ATK_VERSION)

at-spi2-atk-setup: setup
	wget -q -nc -P$(BUILD_SOURCE) https://download.gnome.org/sources/at-spi2-atk/2.38.0/at-spi2-atk-2.38.0.tar.xz
	$(call EXTRACT_TAR,at-spi2-atk-$(AT-SPI2-ATK_VERSION).tar.xz,at-spi2-atk-$(AT-SPI2-ATK_VERSION),at-spi2-atk)
	mkdir -p $(BUILD_WORK)/at-spi2-atk/build
	echo -e "[host_machine]\n \
	cpu_family = '$(shell echo $(GNU_HOST_TRIPLE) | cut -d- -f1)'\n \
	cpu = '$(MEMO_ARCH)'\n \
	endian = 'little'\n \
	system = 'darwin'\n \
	[properties]\n \
	root = '$(BUILD_BASE)'\n \
	needs_exe_wrapper = true\n \
	[paths]\n \
	prefix ='$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)'\n \
	[binaries]\n \
	c = '$(CC)'\n \
	objc = '$(CC)'\n \
	cpp = '$(CXX)'\n \
	pkgconfig = '$(BUILD_TOOLS)/cross-pkg-config'\n" > $(BUILD_WORK)/at-spi2-atk/build/cross.txt

ifneq ($(wildcard $(BUILD_WORK)/at-spi2-atk/.build_complete),)
at-spi2-atk:
	@echo "Using previously built at-spi2-atk."
else
at-spi2-atk: at-spi2-atk-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/at-spi2-atk/build && meson \
	--cross-file cross.txt \
	-Dintrospection=false \
	..
	ninja -C $(BUILD_WORK)/at-spi2-atk/build
	+DESTDIR="$(BUILD_STAGE)/at-spi2-atk" ninja -C $(BUILD_WORK)/at-spi2-atk/build install
	touch $(BUILD_WORK)/at-spi2-atk/.build_complete
endif

at-spi2-atk-package: at-spi2-atk-stage
	# at-spi2-atk.mk Package Structure
	rm -rf $(BUILD_DIST)/at-spi2-core $(BUILD_DIST)/libatspi2.0-{0,dev}
	mkdir -p $(BUILD_DIST)/at-spi2-core/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib \
		$(BUILD_DIST)/libatspi2.0-0/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/{lib/pkgconfig,include} \
		$(BUILD_DIST)/libatspi2.0-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin

	# at-spi2-atk.mk at-spi2-core
	cp -a $(BUILD_STAGE)/at-spi2-atk/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/!(pkgconfig|libgdk_pixbuf-2.0.dylib) \
		$(BUILD_DIST)/libgdk-pixbuf-2.0-0/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# at-spi2-atk.mk Prep libatspi2.0-0
	cp -a $(BUILD_STAGE)/at-spi2-atk/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/!(libgdk_pixbuf-2.0.0.dylib|at-spi2-atk-2.0) \
		$(BUILD_DIST)/libgdk-pixbuf-2.0-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib
	cp -a $(BUILD_STAGE)/at-spi2-atk/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include/at-spi2-atk-2.0 \
		$(BUILD_DIST)/libgdk-pixbuf-2.0-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include

	# at-spi2-atk.mk Prep libatspi2.0-dev
	cp -a $(BUILD_STAGE)/at-spi2-atk/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin \
		$(BUILD_DIST)/libgdk-pixbuf2.0-bin/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/


	# at-spi2-atk.mk Sign
	$(call SIGN,libgdk-pixbuf-2.0-0,general.xml)
	$(call SIGN,libgdk-pixbuf2.0-bin,general.xml)

	# at-spi2-atk.mk Make .debs
	$(call PACK,libgdk-pixbuf-2.0-0,DEB_GDK-PIXBUF_V)
	$(call PACK,libgdk-pixbuf-2.0-dev,DEB_GDK-PIXBUF_V)
	$(call PACK,libgdk-pixbuf2.0-bin,DEB_GDK-PIXBUF_V)

	# at-spi2-atk.mk Build cleanup
	rm -rf $(BUILD_DIST)/at-spi2-core $(BUILD_DIST)/libatspi2.0-{0,dev}

.PHONY: at-spi2-atk at-spi2-atk-package


