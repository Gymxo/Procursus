ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += gtk+
GTK+_VERSION := 3.24.28
DEB_GTK+_V   ?= $(GTK+_VERSION)

gtk+-setup: setup
	wget -q -nc -P$(BUILD_SOURCE) https://download.gnome.org/sources/gtk+/3.24/gtk+-3.24.28.tar.xz
	$(call EXTRACT_TAR,gtk+-$(GTK+_VERSION).tar.xz,gtk+-$(GTK+_VERSION),gtk+)

ifneq ($(wildcard $(BUILD_WORK)/gtk+/.build_complete),)
gtk+:
	@echo "Using previously built gtk+."
else
gtk+: gtk+-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/gtk+ && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-x \
		--disable-gtk-doc-html \
		--enable-introspection=no \
		--disable-cups \
		--disable-glibtest \
		--enable-x11-backend \
		--enable-xdamage \
		--disable-xcomposite \
		--enable-xfixes \
		--enable-xrandr \
		--enable-xinerama \
		--enable-xkb \
		--disable-wayland-backend
	+$(MAKE) -i -C $(BUILD_WORK)/gtk+
	+$(MAKE) -i -C $(BUILD_WORK)/gtk+ install \
		DESTDIR=$(BUILD_STAGE)/gtk+
	+$(MAKE) -i -C $(BUILD_WORK)/gtk+ install \
		DESTDIR=$(BUILD_BASE)
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

