ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += libxcomposite
LIBXCOMPOSITE_VERSION := 0.4.5
DEB_LIBXCOMPOSITE_V   ?= $(LIBXCOMPOSITE_VERSION)

libxcomposite-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/lib/libXcomposite-$(LIBXCOMPOSITE_VERSION).tar.gz{,.sig}
	$(call PGP_VERIFY,libXcomposite-$(LIBXCOMPOSITE_VERSION).tar.gz)
	$(call EXTRACT_TAR,libXcomposite-$(LIBXCOMPOSITE_VERSION).tar.gz,libXcomposite-$(LIBXCOMPOSITE_VERSION),libxcomposite)

ifneq ($(wildcard $(BUILD_WORK)/libxcomposite/.build_complete),)
libxcomposite:
	@echo "Using previously built libxcomposite."
else
libxcomposite: libxcomposite-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/libxcomposite && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS)
	+$(MAKE) -C $(BUILD_WORK)/libxcomposite
	+$(MAKE) -C $(BUILD_WORK)/libxcomposite install \
		DESTDIR=$(BUILD_STAGE)/libxcomposite
	+$(MAKE) -C $(BUILD_WORK)/libxcomposite install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/libxcomposite/.build_complete
endif

libxcomposite-package: libxcomposite-stage
	# libxcomposite.mk Package Structure
	rm -rf $(BUILD_DIST)/libxcomposite

	# libxcomposite.mk Prep libxcomposite
	cp -a $(BUILD_STAGE)/libxcomposite $(BUILD_DIST)

	# libxcomposite.mk Sign
	$(call SIGN,libxcomposite,general.xml)

	# libxcomposite.mk Make .debs
	$(call PACK,libxcomposite,DEB_LIBXCOMPOSITE_V)

	# libxcomposite.mk Build cleanup
	rm -rf $(BUILD_DIST)/libxcomposite

.PHONY: libxcomposite libxcomposite-package
