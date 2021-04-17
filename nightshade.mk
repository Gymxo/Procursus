ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += nightshade
NIGHTSHADE_VERSION := 11.12.1
DEB_NIGHTSHADE_V   ?= $(NIGHTSHADE_VERSION)

nightshade-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.nightshadesoftware.org/attachments/download/6/nightshade-11.12.1.tar.gz
	$(call EXTRACT_TAR,nightshade-$(NIGHTSHADE_VERSION).tar.gz,nightshade-$(NIGHTSHADE_VERSION),nightshade)

ifneq ($(wildcard $(BUILD_WORK)/nightshade/.build_complete),)
nightshade:
	@echo "Using previously built nightshade."
else
nightshade: nightshade-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/nightshade && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-x \
		--disable-rpath \
		--disable-sdltest \
		--disable-dependency-tracking
	+$(MAKE) -C $(BUILD_WORK)/nightshade
	+$(MAKE) -C $(BUILD_WORK)/nightshade install \
		DESTDIR=$(BUILD_STAGE)/nightshade
	+$(MAKE) -C $(BUILD_WORK)/nightshade install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/nightshade/.build_complete
endif

nightshade-package: nightshade-stage
	# nightshade.mk Package Structure
	rm -rf $(BUILD_DIST)/nightshade

	# nightshade.mk Prep nightshade
	cp -a $(BUILD_STAGE)/nightshade $(BUILD_DIST)

	# nightshade.mk Sign
	$(call SIGN,nightshade,general.xml)

	# nightshade.mk Make .debs
	$(call PACK,nightshade,DEB_NIGHTSHADE_V)

	# nightshade.mk Build cleanup
	rm -rf $(BUILD_DIST)/nightshade

.PHONY: nightshade nightshade-package
