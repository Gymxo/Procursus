ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += libgtop
LIBGTOP_VERSION := 2.40.0
DEB_LIBGTOP_V   ?= $(LIBGTOP_VERSION)

libgtop-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://download.gnome.org/sources/libgtop/2.40/libgtop-2.40.0.tar.xz
	$(call EXTRACT_TAR,libgtop-$(LIBGTOP_VERSION).tar.xz,libgtop-$(LIBGTOP_VERSION),libgtop)

ifneq ($(wildcard $(BUILD_WORK)/libgtop/.build_complete),)
libgtop:
	@echo "Using previously built libgtop."
else
libgtop: libgtop-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/libgtop && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-x \
		--enable-introspection=no \
		--x-libraries=$(BUILD_BASE)/usr/lib \
		--x-includes=$(BUILD_BASE)/usr/include
	+$(MAKE) -C $(BUILD_WORK)/libgtop
	+$(MAKE) -C $(BUILD_WORK)/libgtop install \
		DESTDIR=$(BUILD_STAGE)/libgtop
	+$(MAKE) -C $(BUILD_WORK)/libgtop install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/libgtop/.build_complete
endif

libgtop-package: libgtop-stage
	# libgtop.mk Package Structure
	rm -rf $(BUILD_DIST)/libgtop

	# libgtop.mk Prep libgtop
	cp -a $(BUILD_STAGE)/libgtop $(BUILD_DIST)

	# libgtop.mk Sign
	$(call SIGN,libgtop,general.xml)

	# libgtop.mk Make .debs
	$(call PACK,libgtop,DEB_LIBGTOP_V)

	# libgtop.mk Build cleanup
	rm -rf $(BUILD_DIST)/libgtop

.PHONY: libgtop libgtop-package
