ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += gtk+3
GTK+3_VERSION := 3.24.29
DEB_GTK+3_V   ?= $(GTK+3_VERSION)

gtk+3-setup: setup
	wget -q -nc -P$(BUILD_SOURCE) https://download.gnome.org/sources/gtk+/3.24/gtk+-3.24.29.tar.xz
	$(call EXTRACT_TAR,gtk+-$(GTK+3_VERSION).tar.xz,gtk+-$(GTK+3_VERSION),gtk+3)
	$(call DO_PATCH,gtk+,gtk+3,-p1)
	mkdir -p $(BUILD_WORK)/gtk+3/build
	echo -e "[host_machine]\n \
	system = 'darwin'\n \
	cpu_family = '$(shell echo $(GNU_HOST_TRIPLE) | cut -d- -f1)'\n \
	cpu = '$(MEMO_ARCH)'\n \
	endian = 'little'\n \
	[properties]\n \
	root = '$(BUILD_BASE)'\n \
	objcpp_args = ['-arch', 'arm64']\n \
	objcpp_link_args = ['-arch', 'arm64']\n \
	[paths]\n \
	prefix ='$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)'\n \
	[binaries]\n \
	c = '$(CC)'\n \
	cpp = '$(CXX)'\n" > $(BUILD_WORK)/gtk+3/build/cross.txt

ifneq ($(wildcard $(BUILD_WORK)/gtk+3/.build_complete),)
gtk+3:
	@echo "Using previously built gtk+3."
else
gtk+3: gtk+3-setup libx11 libxau libxmu xorgproto xxhash
#	cd $(BUILD_WORK)/gtk+3 && \
	mkdir -p build-host && \
	pushd "build-host" && \
	unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS PKG_CONFIG_PATH PKG_CONFIG_LIBDIR && \
	export LDFLAGS=-Wl,-dead_strip_dylibs && \
	PKG_CONFIG="pkg-config" meson \
	--prefix="/opt/procursus" \
	--backend=ninja \
	-Dlibdir="/opt/procursus/lib" \
    -Dgtk_doc=false \
    -Ddemos=false \
	-Dtests=false \
    -Dexamples=false \
    -Dinstalled_tests=false \
    -Dwayland_backend=false \
	..
#	cd $(BUILD_WORK)/gtk+3/build-host && \
	unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS PKG_CONFIG_PATH PKG_CONFIG_LIBDIR ACLOCAL_PATH && \
	export GI_CROSS_LAUNCHER=$(PWD)/build_tools/gi-cross-launcher-save.sh && \
	ninja -k 0
	cd $(BUILD_WORK)/gtk+3/build && PKG_CONFIG="pkg-config" meson \
	--cross-file cross.txt \
	-Dgtk_doc=false \
	-Dwayland_backend=false \
	-Dquartz_backend=false \
	-Dx11_backend=true \
	-Dprint_backends=file,lpr \
	--wrap-mode=nofallback \
	-Dintrospection=false \
	--buildtype=release \
	..
	cd $(BUILD_WORK)/gtk+3/build && sed -i 's/--cflags-begin/--cflags-begin -arch arm64/g' build.ninja && \
	ninja -C $(BUILD_WORK)/gtk+3/build
	+DESTDIR="$(BUILD_STAGE)/gtk+3" ninja -C $(BUILD_WORK)/gtk+3/build install
	+DESTDIR="$(BUILD_BASE)" ninja -C $(BUILD_WORK)/gtk+3/build install
	touch $(BUILD_WORK)/gtk+3/.build_complete
endif

gtk+3-package: gtk+3-stage
	# gtk+3.mk Package Structure
	rm -rf $(BUILD_DIST)/gtk+3

	# gtk+3.mk Prep gtk+3
	cp -a $(BUILD_STAGE)/gtk+3 $(BUILD_DIST)

	# gtk+3.mk Sign
	$(call SIGN,gtk+3,general.xml)

	# gtk+3.mk Make .debs
	$(call PACK,gtk+3,DEB_GTK+3_V)

	# gtk+3.mk Build cleanup
	rm -rf $(BUILD_DIST)/gtk+3

.PHONY: gtk+3 gtk+3-package

