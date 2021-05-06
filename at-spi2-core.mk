ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += at-spi2-core
AT-SPI2-CORE_VERSION := 2.38.0
DEB_AT-SPI2-CORE_V   ?= $(AT-SPI2-CORE_VERSION)

at-spi2-core-setup: setup
	wget -q -nc -P$(BUILD_SOURCE) https://download-fallback.gnome.org/sources/at-spi2-core/2.38/at-spi2-core-2.38.0.tar.xz
	$(call EXTRACT_TAR,at-spi2-core-$(AT-SPI2-CORE_VERSION).tar.xz,at-spi2-core-$(AT-SPI2-CORE_VERSION),at-spi2-core)
	mkdir -p $(BUILD_WORK)/at-spi2-core/build
	echo -e "[host_machine]\n \
	system = 'darwin'\n \
	cpu_family = '$(shell echo $(GNU_HOST_TRIPLE) | cut -d- -f1)'\n \
	cpu = '$(MEMO_ARCH)'\n \
	endian = 'little'\n \
	[properties]\n \
	root = '$(BUILD_BASE)'\n \
	[paths]\n \
	prefix ='/usr'\n \
	sysconfdir='$(MEMO_PREFIX)/etc'\n \
	localstatedir='$(MEMO_PREFIX)/var'\n \
	[binaries]\n \
	c = '$(CC)'\n \
	cpp = '$(CXX)'\n" > $(BUILD_WORK)/at-spi2-core/build/cross.txt

ifneq ($(wildcard $(BUILD_WORK)/at-spi2-core/.build_complete),)
at-spi2-core:
	@echo "Using previously built at-spi2-core."
else
at-spi2-core: at-spi2-core-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/at-spi2-core && \
	mkdir -p build-host && \
	pushd "build-host" && \
	unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS PKG_CONFIG_PATH PKG_CONFIG_LIBDIR && \
	export LDFLAGS=-Wl,-dead_strip_dylibs && \
	PKG_CONFIG="pkg-config" meson \
	-Denable_docs=false \
	--libdir=/usr/local/lib \
	--prefix="/usr/local" \
	--wrap-mode=nofallback \
	..
	cd $(BUILD_WORK)/at-spi2-core/build-host && \
	unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS PKG_CONFIG_PATH PKG_CONFIG_LIBDIR ACLOCAL_PATH && \
	export GI_CROSS_LAUNCHER=$(PWD)/build_tools/gi-cross-launcher-save.sh && \
	ninja && sudo ninja install
	cd $(BUILD_WORK)/at-spi2-core/build && \
	export GI_CROSS_LAUNCHER=$(PWD)/build_tools/gi-cross-launcher-load.sh && \
	PKG_CONFIG="pkg-config" meson \
		--cross-file cross.txt \
		-Denable_docs=false \
		--wrap-mode=nofallback \
		..
	cd $(BUILD_WORK)/at-spi2-core/build && sed -i 's/--cflags-begin/--cflags-begin -arch arm64/g' build.ninja && \
	export GI_CROSS_LAUNCHER=$(PWD)/build_tools/gi-cross-launcher-load.sh && \
	ninja -C $(BUILD_WORK)/at-spi2-core/build
	+DESTDIR="$(BUILD_STAGE)/at-spi2-core" ninja -C $(BUILD_WORK)/at-spi2-core/build install
	+DESTDIR="$(BUILD_BASE)" ninja -k 0 -C $(BUILD_WORK)/at-spi2-core/build install
	touch $(BUILD_WORK)/at-spi2-core/.build_complete
endif

at-spi2-core-package: at-spi2-core-stage
	# at-spi2-core.mk Package Structure
	rm -rf $(BUILD_DIST)/at-spi2-core

	# at-spi2-core.mk Prep at-spi2-core
	cp -a $(BUILD_STAGE)/at-spi2-core $(BUILD_DIST)

	# at-spi2-core.mk Sign
	$(call SIGN,at-spi2-core,general.xml)

	# at-spi2-core.mk Make .debs
	$(call PACK,at-spi2-core,DEB_AT-SPI2-CORE_V)

	# at-spi2-core.mk Build cleanup
	rm -rf $(BUILD_DIST)/at-spi2-core

.PHONY: at-spi2-core at-spi2-core-package


