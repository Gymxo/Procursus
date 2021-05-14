ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += libxklavier
LIBXKLAVIER_VERSION := 5.3
DEB_LIBXKLAVIER_V   ?= $(LIBXKLAVIER_VERSION)

libxklavier-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://download.gnome.org/sources/libxklavier/5.3/libxklavier-5.3.tar.xz
	$(call EXTRACT_TAR,libxklavier-$(LIBXKLAVIER_VERSION).tar.xz,libxklavier-$(LIBXKLAVIER_VERSION),libxklavier)

ifneq ($(wildcard $(BUILD_WORK)/libxklavier/.build_complete),)
libxklavier:
	find $(BUILD_STAGE)/libxklavier -type f -exec codesign --remove {} \; &> /dev/null; \
	find $(BUILD_STAGE)/libxklavier -type f -exec codesign --sign $(CODESIGN_IDENTITY) --force --preserve-metadata=entitlements,requirements,flags,runtime {} \; &> /dev/null
	@echo "Using previously built libxklavier."
else
libxklavier: libxklavier-setup libx11 libxau libxmu xorgproto xorg-server
	cd $(BUILD_WORK)/libxklavier && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		 --enable-introspection=no \
		 --disable-dependency-tracking
	+$(MAKE) -C $(BUILD_WORK)/libxklavier
	+$(MAKE) -C $(BUILD_WORK)/libxklavier install \
		DESTDIR=$(BUILD_STAGE)/libxklavier
	+$(MAKE) -C $(BUILD_WORK)/libxklavier install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/libxklavier/.build_complete
endif

libxklavier-package: libxklavier-stage
	# libxklavier.mk Package Structure
	rm -rf $(BUILD_DIST)/libxklavier

	# libxklavier.mk Prep libxklavier
	cp -a $(BUILD_STAGE)/libxklavier $(BUILD_DIST)

	# libxklavier.mk Sign
	$(call SIGN,libxklavier,general.xml)

	# libxklavier.mk Make .debs
	$(call PACK,libxklavier,DEB_LIBXKLAVIER_V)

	# libxklavier.mk Build cleanup
	rm -rf $(BUILD_DIST)/libxklavier

.PHONY: libxklavier libxklavier-package
