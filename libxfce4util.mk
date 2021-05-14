ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += libxfce4util
LIBXFCE4UTIL_VERSION := 4.16.0
DEB_LIBXFCE4UTIL_V   ?= $(LIBXFCE4UTIL_VERSION)

libxfce4util-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://archive.xfce.org/src/xfce/libxfce4util/4.16/libxfce4util-$(LIBXFCE4UTIL_VERSION).tar.bz2
	$(call EXTRACT_TAR,libxfce4util-$(LIBXFCE4UTIL_VERSION).tar.bz2,libxfce4util-$(LIBXFCE4UTIL_VERSION),libxfce4util)

ifneq ($(wildcard $(BUILD_WORK)/libxfce4util/.build_complete),)
libxfce4util:
	find $(BUILD_STAGE)/libxfce4util -type f -exec codesign --remove {} \; &> /dev/null; \
	find $(BUILD_STAGE)/libxfce4util -type f -exec codesign --sign $(CODESIGN_IDENTITY) --force --preserve-metadata=entitlements,requirements,flags,runtime {} \; &> /dev/null
	@echo "Using previously built libxfce4util."
else
libxfce4util: libxfce4util-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/libxfce4util && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-x \
		--x-libraries=$(BUILD_BASE)/usr/lib \
		--x-includes=$(BUILD_BASE)/usr/include \
		--disable-visibility \
		--enable-introspection=no
	+$(MAKE) -C $(BUILD_WORK)/libxfce4util
	+$(MAKE) -C $(BUILD_WORK)/libxfce4util install \
		DESTDIR=$(BUILD_STAGE)/libxfce4util
	+$(MAKE) -C $(BUILD_WORK)/libxfce4util install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/libxfce4util/.build_complete
endif

libxfce4util-package: libxfce4util-stage
	# libxfce4util.mk Package Structure
	rm -rf $(BUILD_DIST)/libxfce4util

	# libxfce4util.mk Prep libxfce4util
	cp -a $(BUILD_STAGE)/libxfce4util $(BUILD_DIST)

	# libxfce4util.mk Sign
	$(call SIGN,libxfce4util,general.xml)

	# libxfce4util.mk Make .debs
	$(call PACK,libxfce4util,DEB_LIBXFCE4UTIL_V)

	# libxfce4util.mk Build cleanup
	rm -rf $(BUILD_DIST)/libxfce4util

.PHONY: libxfce4util libxfce4util-package
