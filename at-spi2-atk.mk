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
	cpp = '$(CXX)'\n" > $(BUILD_WORK)/at-spi2-atk/build/cross.txt

ifneq ($(wildcard $(BUILD_WORK)/at-spi2-atk/.build_complete),)
at-spi2-atk:
	@echo "Using previously built at-spi2-atk."
else
at-spi2-atk: at-spi2-atk-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/at-spi2-atk && \
	mkdir -p build-host && \
	pushd "build-host" && \
	unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS PKG_CONFIG_PATH PKG_CONFIG_LIBDIR && \
	export LDFLAGS=-Wl,-dead_strip_dylibs && \
	PKG_CONFIG="pkg-config" meson \
	-Denable_docs=false \
	--libdir=/usr/local/lib \
	--wrap-mode=nofallback \
	--prefix="/usr/local" \
	..
	cd $(BUILD_WORK)/at-spi2-atk/build-host && \
	unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS PKG_CONFIG_PATH PKG_CONFIG_LIBDIR ACLOCAL_PATH && \
	export GI_CROSS_LAUNCHER=$(PWD)/build_tools/gi-cross-launcher-save.sh && \
	ninja && sudo ninja install
	cd $(BUILD_WORK)/at-spi2-atk/build && \
	export GI_CROSS_LAUNCHER=$(PWD)/build_tools/gi-cross-launcher-load.sh && \
	PKG_CONFIG="pkg-config" meson \
		--cross-file cross.txt \
		-Denable_docs=false \
		--wrap-mode=nofallback \
		..
	cd $(BUILD_WORK)/at-spi2-atk/build && sed -i 's/--cflags-begin/--cflags-begin -arch arm64/g' build.ninja && \
	export GI_CROSS_LAUNCHER=$(PWD)/build_tools/gi-cross-launcher-load.sh && \
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


