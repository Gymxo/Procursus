ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += atk
ATK_VERSION := 2.36.0
DEB_ATK_V   ?= $(ATK_VERSION)

atk-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://download.gnome.org/sources/atk/2.36/atk-2.36.0.tar.xz
	$(call EXTRACT_TAR,atk-$(ATK_VERSION).tar.xz,atk-$(ATK_VERSION),atk)
	mkdir -p $(BUILD_WORK)/atk/build
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
	cpp = '$(CXX)'\n" > $(BUILD_WORK)/atk/build/cross.txt

ifneq ($(wildcard $(BUILD_WORK)/atk/.build_complete),)
atk:
	@echo "Using previously built atk."
else
atk: atk-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/atk && \
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
	cd $(BUILD_WORK)/atk/build-host && \
	unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS PKG_CONFIG_PATH PKG_CONFIG_LIBDIR ACLOCAL_PATH && \
	export GI_CROSS_LAUNCHER=$(PWD)/build_tools/gi-cross-launcher-save.sh && \
	ninja && sudo ninja install
	cd $(BUILD_WORK)/atk/build && \
	export GI_CROSS_LAUNCHER=$(PWD)/build_tools/gi-cross-launcher-load.sh && \
	PKG_CONFIG="pkg-config" meson \
		--cross-file cross.txt \
		-Denable_docs=false \
		--wrap-mode=nofallback \
		..
	cd $(BUILD_WORK)/atk/build && sed -i 's/--cflags-begin/--cflags-begin -arch arm64/g' build.ninja && \
	export GI_CROSS_LAUNCHER=$(PWD)/build_tools/gi-cross-launcher-load.sh && \
	ninja -C $(BUILD_WORK)/atk/build
	+DESTDIR="$(BUILD_STAGE)/atk" ninja -C $(BUILD_WORK)/atk/build install
	+DESTDIR="$(BUILD_BASE)" ninja -k 0 -C $(BUILD_WORK)/atk/build install
	touch $(BUILD_WORK)/atk/.build_complete
endif

atk-package: atk-stage
	# atk.mk Package Structure
	rm -rf $(BUILD_DIST)/atk
	mkdir -p $(BUILD_DIST)/atk
	
	# atk.mk Prep atk
	cp -a $(BUILD_STAGE)/atk $(BUILD_DIST)
	
	# atk.mk Sign
	$(call SIGN,atk,general.xml)
	
	# atk.mk Make .debs
	$(call PACK,atk,DEB_ATK_V)
	
	# atk.mk Build cleanup
	rm -rf $(BUILD_DIST)/atk

.PHONY: atk atk-package
