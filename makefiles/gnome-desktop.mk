ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += gnome-desktop
GNOME-DESKTOP_VERSION := 40.0
DEB_GNOME-DESKTOP_V   ?= $(GNOME-DESKTOP_VERSION)

gnome-desktop-setup: setup
	wget -q -nc -P$(BUILD_SOURCE) https://download-fallback.gnome.org/sources/gnome-desktop/40/gnome-desktop-40.0.tar.xz
	$(call EXTRACT_TAR,gnome-desktop-$(GNOME-DESKTOP_VERSION).tar.xz,gnome-desktop-$(GNOME-DESKTOP_VERSION),gnome-desktop)
	mkdir -p $(BUILD_WORK)/gnome-desktop/build
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
	sysconfdir='$(MEMO_PREFIX)/etc'\n \
	localstatedir='$(MEMO_PREFIX)/var'\n \
	[binaries]\n \
	c = '$(CC)'\n \
	cpp = '$(CXX)'\n" > $(BUILD_WORK)/gnome-desktop/build/cross.txt

ifneq ($(wildcard $(BUILD_WORK)/gnome-desktop/.build_complete),)
gnome-desktop:
	@echo "Using previously built gnome-desktop."
else
gnome-desktop: gnome-desktop-setup
	cd $(BUILD_WORK)/gnome-desktop && \
	mkdir -p build-host && \
	pushd "build-host" && \
	unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS PKG_CONFIG_PATH PKG_CONFIG_LIBDIR && \
	PKG_CONFIG="pkg-config" meson \
	--libdir=/usr/local/lib \
	--prefix="/usr/local" \
	..
	cd $(BUILD_WORK)/gnome-desktop/build-host && \
	unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS PKG_CONFIG_PATH PKG_CONFIG_LIBDIR ACLOCAL_PATH && \
	export GI_CROSS_LAUNCHER=$(PWD)/build_tools/gi-cross-launcher-save.sh && \
	ninja
	cd $(BUILD_WORK)/gnome-desktop/build && PKG_CONFIG="pkg-config" meson \
		--cross-file cross.txt \
		..
	cd $(BUILD_WORK)/gnome-desktop/build && sed -i 's/--cflags-begin/--cflags-begin -arch arm64/g' build.ninja && \
	export GI_CROSS_LAUNCHER=$(PWD)/build_tools/gi-cross-launcher-load.sh && \
	ninja -C $(BUILD_WORK)/gnome-desktop/build
	+DESTDIR="$(BUILD_STAGE)/gnome-desktop" ninja -C $(BUILD_WORK)/gnome-desktop/build install
	+DESTDIR="$(BUILD_BASE)" ninja -C $(BUILD_WORK)/gnome-desktop/build install
	touch $(BUILD_WORK)/gnome-desktop/.build_complete
endif

gnome-desktop-package: gnome-desktop-stage
	# gtk+.mk Package Structure
	rm -rf $(BUILD_DIST)/gnome-desktop

	# gtk+.mk Prep gnome-desktop
	cp -a $(BUILD_STAGE)/gnome-desktop $(BUILD_DIST)

	# gtk+.mk Sign
	$(call SIGN,gnome-desktop,general.xml)

	# gtk+.mk Make .debs
	$(call PACK,gnome-desktop,DEB_GNOME-DESKTOP_V)

	# gtk+.mk Build cleanup
	rm -rf $(BUILD_DIST)/gnome-desktop

.PHONY: gnome-desktop gnome-desktop-package
