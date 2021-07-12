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
	+DESTDIR="$(BUILD_BASE)" ninja -k 0 -C $(BUILD_WORK)/at-spi2-atk/build install
	touch $(BUILD_WORK)/at-spi2-atk/.build_complete
endif

at-spi2-atk-package: at-spi2-atk-stage
	# at-spi2-atk.mk Package Structure
	rm -rf $(BUILD_DIST)/at-spi2-atk

	# at-spi2-atk.mk Prep at-spi2-atk
	cp -a $(BUILD_STAGE)/at-spi2-atk $(BUILD_DIST)

	# at-spi2-atk.mk Sign
	$(call SIGN,at-spi2-atk,general.xml)

	# at-spi2-atk.mk Make .debs
	$(call PACK,at-spi2-atk,DEB_AT-SPI2-ATK_V)

	# at-spi2-atk.mk Build cleanup
	rm -rf $(BUILD_DIST)/at-spi2-atk

.PHONY: at-spi2-atk at-spi2-atk-package


