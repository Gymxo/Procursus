ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   		+= libxfce4ui
LIBXFCE4UI_VERSION := 4.16.0
DEB_LIBXFCE4UI_V   ?= $(LIBXFCE4UI_VERSION)

libxfce4ui-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://archive.xfce.org/src/xfce/libxfce4ui/4.16/libxfce4ui-$(LIBXFCE4UI_VERSION).tar.bz2
	$(call EXTRACT_TAR,libxfce4ui-$(LIBXFCE4UI_VERSION).tar.bz2,libxfce4ui-$(LIBXFCE4UI_VERSION),libxfce4ui)

ifneq ($(wildcard $(BUILD_WORK)/libxfce4ui/.build_complete),)
libxfce4ui:
	find $(BUILD_STAGE)/libxfce4ui -type f -exec codesign --remove {} \; &> /dev/null; \
	find $(BUILD_STAGE)/libxfce4ui -type f -exec codesign --sign $(CODESIGN_IDENTITY) --force --preserve-metadata=entitlements,requirements,flags,runtime {} \; &> /dev/null
	@echo "Using previously built libxfce4ui."
else
libxfce4ui: libxfce4ui-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/libxfce4ui && autoreconf -fiv && mkdir -p build && cd build && ../configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-x \
		--x-libraries=$(BUILD_BASE)/usr/lib \
		--x-includes=$(BUILD_BASE)/usr/include \
		--disable-visibility \
		--enable-introspection=no \
		--disable-gtk-doc-html \
		--with-vendor-info=Procursus \
		--with-sysroot=$(BUILD_BASE)
	+$(MAKE) -C $(BUILD_WORK)/libxfce4ui/build
	+$(MAKE) -i -C $(BUILD_WORK)/libxfce4ui/build install \
		DESTDIR=$(BUILD_STAGE)/libxfce4ui
	+$(MAKE) -i -C $(BUILD_WORK)/libxfce4ui/build install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/libxfce4ui/.build_complete
endif

libxfce4ui-package: libxfce4ui-stage
	# libxfce4ui.mk Package Structure
	rm -rf $(BUILD_DIST)/libxfce4ui

	# libxfce4ui.mk Prep libxfce4ui
	cp -a $(BUILD_STAGE)/libxfce4ui $(BUILD_DIST)

	# libxfce4ui.mk Sign
	$(call SIGN,libxfce4ui,general.xml)

	# libxfce4ui.mk Make .debs
	$(call PACK,libxfce4ui,DEB_LIBXFCE4UI_V)

	# libxfce4ui.mk Build cleanup
	rm -rf $(BUILD_DIST)/libxfce4ui

.PHONY: libxfce4ui libxfce4ui-package
