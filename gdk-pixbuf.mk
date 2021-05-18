ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += gdk-pixbuf
GDK-PIXBUF_VERSION := 2.42.6
DEB_GDK-PIXBUF_V   ?= $(GDK-PIXBUF_VERSION)

gdk-pixbuf-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://mirror.umd.edu/gnome/sources/gdk-pixbuf/2.42/gdk-pixbuf-2.42.6.tar.xz
	$(call EXTRACT_TAR,gdk-pixbuf-$(GDK-PIXBUF_VERSION).tar.xz,gdk-pixbuf-$(GDK-PIXBUF_VERSION),gdk-pixbuf)
	mkdir -p $(BUILD_WORK)/gdk-pixbuf/build

	echo -e "[host_machine]\n \
	cpu_family = '$(shell echo $(GNU_HOST_TRIPLE) | cut -d- -f1)'\n \
	cpu = '$(MEMO_ARCH)'\n \
	endian = 'little'\n \
	system = 'darwin'\n \
	[properties]\n \
	root = '$(BUILD_BASE)'\n \
	skip_sanity_check = true\n \
	sys_root = '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk'\n \
	objcpp_args = ['-arch', 'arm64']\n \
	objcpp_link_args = ['-arch', 'arm64']\n \
	[paths]\n \
	prefix ='/usr'\n \
	[binaries]\n \
	c = '$(CC)'\n \
	cpp = '$(CXX)'\n" > $(BUILD_WORK)/gdk-pixbuf/build/cross.txt

ifneq ($(wildcard $(BUILD_WORK)/gdk-pixbuf/.build_complete),)
gdk-pixbuf:
	@echo "Using previously built gdk-pixbuf."
else
gdk-pixbuf: gdk-pixbuf-setup libx11 libxau libxmu xorgproto libfribidi
	cd $(BUILD_WORK)/gdk-pixbuf && \
	mkdir -p build-host && \
	pushd "build-host" && \
	unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS PKG_CONFIG_PATH PKG_CONFIG_LIBDIR && \
	export LDFLAGS=-Wl,-dead_strip_dylibs && \
	PKG_CONFIG="pkg-config" meson \
	--libdir=/usr/local/lib \
	--prefix="/usr/local" \
	--wrap-mode=nofallback \
    -Ddocs=false \
    -Drelocatable=true \
    -Dintrospection=enabled \
	-Dbuiltin_loaders=all \
	..
	cd $(BUILD_WORK)/gdk-pixbuf/build-host && \
	unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS PKG_CONFIG_PATH PKG_CONFIG_LIBDIR ACLOCAL_PATH && \
	export GI_CROSS_LAUNCHER=$(PWD)/build_tools/gi-cross-launcher-save.sh && \
	ninja && sudo ninja install
	cd $(BUILD_WORK)/gdk-pixbuf/build && \
	export GI_CROSS_LAUNCHER=$(PWD)/build_tools/gi-cross-launcher-load.sh && \
	PKG_CONFIG="pkg-config" meson \
		--cross-file cross.txt \
		--wrap-mode=nofallback \
    	-Ddocs=false \
   		-Drelocatable=true \
    	-Dintrospection=enabled \
		-Dbuiltin_loaders=all \
		-Dnative_windows_loaders=true \
		..
	cd $(BUILD_WORK)/gdk-pixbuf/build && sed -i 's/--cflags-begin/--cflags-begin -arch arm64/g' build.ninja && \
	export GI_CROSS_LAUNCHER=$(PWD)/build_tools/gi-cross-launcher-load.sh && \
	ninja -C $(BUILD_WORK)/gdk-pixbuf/build
	+DESTDIR="$(BUILD_STAGE)/gdk-pixbuf" ninja -C $(BUILD_WORK)/gdk-pixbuf/build install
	+DESTDIR="$(BUILD_BASE)" ninja -k 0 -C $(BUILD_WORK)/gdk-pixbuf/build install
	touch $(BUILD_WORK)/gdk-pixbuf/.build_complete
endif

gdk-pixbuf-package: gdk-pixbuf-stage
# gdk-pixbuf.mk Package Structure
	rm -rf $(BUILD_DIST)/gdk-pixbuf
	
# gdk-pixbuf.mk Prep gdk-pixbuf
	cp -a $(BUILD_STAGE)/gdk-pixbuf $(BUILD_DIST)
	
# gdk-pixbuf.mk Sign
	$(call SIGN,gdk-pixbuf,general.xml)
	
# gdk-pixbuf.mk Make .debs
	$(call PACK,gdk-pixbuf,DEB_GDK-PIXBUF_V)
	
# gdk-pixbuf.mk Build cleanup
	rm -rf $(BUILD_DIST)/gdk-pixbuf

.PHONY: gdk-pixbuf gdk-pixbuf-package