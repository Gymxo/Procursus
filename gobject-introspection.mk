ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += gobject-introspection
GOBJECT-INTROSPECTION_VERSION := 1.68.0
DEB_GOBJECT-INTROSPECTION_V   ?= $(GOBJECT-INTROSPECTION_VERSION)

gobject-introspection-setup: setup bison glib2.0
	wget -q -nc -P$(BUILD_SOURCE) https://download-fallback.gnome.org/sources/gobject-introspection/1.68/gobject-introspection-1.68.0.tar.xz
	$(call EXTRACT_TAR,gobject-introspection-$(GOBJECT-INTROSPECTION_VERSION).tar.xz,gobject-introspection-$(GOBJECT-INTROSPECTION_VERSION),gobject-introspection)
	$(call DO_PATCH,gobject-introspection,gobject-introspection,-p1)
	mkdir -p $(BUILD_WORK)/gobject-introspection/build

	echo -e "[host_machine]\n \
	cpu_family = '$(shell echo $(GNU_HOST_TRIPLE) | cut -d- -f1)'\n \
	cpu = '$(MEMO_ARCH)'\n \
	endian = 'little'\n \
	system = 'darwin'\n \
	[properties]\n \
	root = '$(BUILD_BASE)'\n \
	[paths]\n \
	prefix ='$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)'\n \
	[binaries]\n \
	c = '$(CC)'\n \
	objc = '$(CC)'\n \
	cpp = '$(CXX)'\n" > $(BUILD_WORK)/gobject-introspection/build/cross.txt


ifneq ($(wildcard $(BUILD_WORK)/gobject-introspection/.build_complete),)
gobject-introspection:
	@echo "Using previously built gobject-introspection."
else
gobject-introspection: gobject-introspection-setup libx11 mesa
ifeq ($(MEMO_TARGET),iphoneos-arm64)
	cd $(BUILD_WORK)/gobject-introspection && \
	mkdir -p build-host && \
	pushd "build-host" && \
	unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS PKG_CONFIG_PATH PKG_CONFIG_LIBDIR && \
	export LDFLAGS=-Wl,-dead_strip_dylibs && \
	PKG_CONFIG="pkg-config" meson \
	--buildtype=release \
	--prefix="/opt/procursus" \
	--backend=ninja \
	--libdir="/opt/procursus/lib" \
	-Dpython="/opt/procursus/bin/python3" \
	..
	cd $(BUILD_WORK)/gobject-introspection/build-host && \
	unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS PKG_CONFIG_PATH PKG_CONFIG_LIBDIR ACLOCAL_PATH && \
	export GI_CROSS_LAUNCHER=$(PWD)/build_tools/gi-cross-launcher-save.sh && \
	ninja -C $(BUILD_WORK)/gobject-introspection/build-host
	cd $(BUILD_WORK)/gobject-introspection/build && \
	PKG_CONFIG="pkg-config" meson \
		--cross-file cross.txt \
		-Dgi_cross_use_prebuilt_gi=True \
		-Dbuild_introspection_data=true \
		--buildtype=release \
		--backend=ninja \
		-Dpython="/opt/procursus/bin/python3" \
		-Dgi_cross_pkgconfig_sysroot_path=$(BUILD_BASE) \
		..
	cd $(BUILD_WORK)/gobject-introspection/build && sed -i 's/--cflags-begin/--cflags-begin -arch $(MEMO_ARCH)/g' build.ninja && \
	export GI_CROSS_LAUNCHER=$(PWD)/build_tools/gi-cross-launcher-load.sh && \
	ninja -v -C $(BUILD_WORK)/gobject-introspection/build
	+DESTDIR="$(BUILD_STAGE)/gobject-introspection" ninja -C $(BUILD_WORK)/gobject-introspection/build install
	+DESTDIR="$(BUILD_BASE)" ninja -k 0 -C $(BUILD_WORK)/gobject-introspection/build install
	touch $(BUILD_WORK)/gobject-introspection/.build_complete
else 
	cd $(BUILD_WORK)/gobject-introspection/build && \
	PKG_CONFIG="pkg-config" meson \
		--cross-file cross.txt \
		-Dbuild_introspection_data=true \
		-Dgi_cross_use_prebuilt_gi=false \
		--buildtype=release \
		--backend=ninja \
		-Dpython="/opt/procursus/bin/python3" \
		..
	ninja -C $(BUILD_WORK)/gobject-introspection/build
	+DESTDIR="$(BUILD_STAGE)/gobject-introspection" ninja -C $(BUILD_WORK)/gobject-introspection/build install
	+DESTDIR="$(BUILD_BASE)" ninja -k 0 -C $(BUILD_WORK)/gobject-introspection/build install
	touch $(BUILD_WORK)/gobject-introspection/.build_complete
endif
endif

gobject-introspection-package: gobject-introspection-stage
	# gobject-introspection.mk Package Structure
	rm -rf $(BUILD_DIST)/gobject-introspection
	mkdir -p $(BUILD_DIST)/gobject-introspection
	
	# gobject-introspection.mk Prep gobject-introspection
	cp -a $(BUILD_STAGE)/gobject-introspection $(BUILD_DIST)
	
	# gobject-introspection.mk Sign
	$(call SIGN,gobject-introspection,general.xml)
	
	# gobject-introspection.mk Make .debs
	$(call PACK,gobject-introspection,DEB_GOBJECT-INTROSPECTION_V)
	
	# gobject-introspection.mk Build cleanup
	rm -rf $(BUILD_DIST)/gobject-introspection

.PHONY: gobject-introspection gobject-introspection-package