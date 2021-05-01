ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += gtk+
GTK+_VERSION := 3.24.12
DEB_GTK+_V   ?= $(GTK+_VERSION)

gtk+-setup: setup
	wget -q -nc -P$(BUILD_SOURCE) https://download-fallback.gnome.org/sources/gtk+/3.24/gtk%2B-3.24.12.tar.xz
	$(call EXTRACT_TAR,gtk+-$(GTK+_VERSION).tar.xz,gtk+-$(GTK+_VERSION),gtk+)
	$(call DO_PATCH,gtk+,gtk+,-p1)
	mkdir -p $(BUILD_WORK)/gtk+/build
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
	exe_wrapper = 'runinqemu'\n \
	c = '$(CC)'\n \
	cpp = '$(CXX)'\n" > $(BUILD_WORK)/gtk+/build/cross.txt

ifneq ($(wildcard $(BUILD_WORK)/gtk+/.build_complete),)
gtk+:
	@echo "Using previously built gtk+."
else
gtk+: gtk+-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/gtk+/build && PKG_CONFIG="pkg-config" meson \
	--cross-file cross.txt \
	-Dgir=false \
	-Dcolord=no \
	-Dgtk_doc=false \
	-Dbroadway_backend=true \
	-Dwayland_backend=false \
	-D11_backend=true \
	-Dintrospection=false \
	-Dprint_backends=file,lpr,test \
	-Dtests=false \
	..
	cd $(BUILD_WORK)/gtk+/build; \
		DESTDIR="$(BUILD_STAGE)/gtk+" meson install; \
		DESTDIR="$(BUILD_BASE)" meson install
	touch $(BUILD_WORK)/gtk+/.build_complete
endif

gtk+-package: gtk+-stage
	# gtk+.mk Package Structure
	rm -rf $(BUILD_DIST)/gtk+

	# gtk+.mk Prep gtk+
	cp -a $(BUILD_STAGE)/gtk+ $(BUILD_DIST)

	# gtk+.mk Sign
	$(call SIGN,gtk+,general.xml)

	# gtk+.mk Make .debs
	$(call PACK,gtk+,DEB_GTK+_V)

	# gtk+.mk Build cleanup
	rm -rf $(BUILD_DIST)/gtk+

.PHONY: gtk+ gtk+-package

