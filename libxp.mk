ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += libxp
LIBXP_VERSION := 1.0.3
DEB_LIBXP_V   ?= $(LIBXP_VERSION)

libxp-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/lib/libXp-$(LIBXP_VERSION).tar.gz{,.sig}
	$(call PGP_VERIFY,libXp-$(LIBXP_VERSION).tar.gz)
	$(call EXTRACT_TAR,libXp-$(LIBXP_VERSION).tar.gz,libXp-$(LIBXP_VERSION),libxp)

ifneq ($(wildcard $(BUILD_WORK)/libxp/.build_complete),)
libxp:
	@echo "Using previously built libxp."
else
libxp: libxp-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/libxp && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS)
	+$(MAKE) -C $(BUILD_WORK)/libxp
	+$(MAKE) -C $(BUILD_WORK)/libxp install \
		DESTDIR=$(BUILD_STAGE)/libxp
	+$(MAKE) -C $(BUILD_WORK)/libxp install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/libxp/.build_complete
endif

libxp-package: libxp-stage
	# libxp.mk Package Structure
	rm -rf $(BUILD_DIST)/libxp

	# libxp.mk Prep libxp
	cp -a $(BUILD_STAGE)/libxp $(BUILD_DIST)

	# libxp.mk Sign
	$(call SIGN,libxp,general.xml)

	# libxp.mk Make .debs
	$(call PACK,libxp,DEB_LIBXP_V)

	# libxp.mk Build cleanup
	rm -rf $(BUILD_DIST)/libxp

.PHONY: libxp libxp-package
