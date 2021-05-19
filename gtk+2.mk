ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += gtk+2
GTK+2_VERSION := 2.24.33
DEB_GTK+2_V   ?= $(GTK+2_VERSION)

gtk+2-setup: setup
	wget -q -nc -P$(BUILD_SOURCE) https://download.gnome.org/sources/gtk+/2.24/gtk+-2.24.33.tar.xz
	$(call EXTRACT_TAR,gtk+-$(GTK+2_VERSION).tar.xz,gtk+-$(GTK+2_VERSION),gtk+2)

ifneq ($(wildcard $(BUILD_WORK)/gtk+2/.build_complete),)
gtk+2:
	@echo "Using previously built gtk+."
else
gtk+2: gtk+2-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/gtk+2 && autoreconf -vfi && mkdir -p "native-build" && \
	pushd "native-build" && \
	unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS PKG_CONFIG_PATH PKG_CONFIG_LIBDIR ACLOCAL_PATH && export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig && ../configure \
		--disable-dependency-tracking \
    	--disable-silent-rules \
    	--disable-glibtest \
    	--enable-introspection=yes \
    	--with-gdktarget=x11 \
    	--disable-visibility \
		--prefix=/usr/local
	export GI_CROSS_LAUNCHER=$(PWD)/build_tools/gi-cross-launcher-save.sh && \
	$(MAKE) -C $(BUILD_WORK)/gtk+2/native-build
	cd $(BUILD_WORK)/gtk+2 && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--disable-dependency-tracking \
    	--disable-silent-rules \
    	--disable-glibtest \
    	--enable-introspection=yes \
    	--with-gdktarget=x11 \
    	--disable-visibility \
		--disable-cups \
		--with-x \
		--disable-shm \
		--x-libraries=$(BUILD_BASE)/usr/lib \
		--x-includes=$(BUILD_BASE)/usr/include
	export GI_CROSS_LAUNCHER=$(PWD)/build_tools/gi-cross-launcher-load.sh && \
	+$(MAKE) -i -C $(BUILD_WORK)/gtk+2
	+$(MAKE) -i -C $(BUILD_WORK)/gtk+2 install \
		DESTDIR=$(BUILD_STAGE)/gtk+2
	+$(MAKE) -i -C $(BUILD_WORK)/gtk+2 install \
		DESTDIR=$(BUILD_BASE)
endif

gtk+2-package: gtk+2-stage
	# gtk+.mk Package Structure
	rm -rf $(BUILD_DIST)/gtk+2

	# gtk+.mk Prep gtk+2
	cp -a $(BUILD_STAGE)/gtk+2 $(BUILD_DIST)

	# gtk+.mk Sign
	$(call SIGN,gtk+2,general.xml)

	# gtk+.mk Make .debs
	$(call PACK,gtk+2,DEB_GTK+2_V)

	# gtk+.mk Build cleanup
	rm -rf $(BUILD_DIST)/gtk+2

.PHONY: gtk+ gtk+-package

