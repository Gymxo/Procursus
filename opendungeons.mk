ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += opendungeons
OPENDUNGEONS_VERSION := 0.7.1
DEB_OPENDUNGEONS_V   ?= $(OPENDUNGEONS_VERSION)

opendungeons-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) http://download.tuxfamily.org/opendungeons/0.7/opendungeons-0.7.1.tar.xz
	$(call EXTRACT_TAR,opendungeons-$(OPENDUNGEONS_VERSION).tar.xz,opendungeons-$(OPENDUNGEONS_VERSION),opendungeons)

ifneq ($(wildcard $(BUILD_WORK)/opendungeons/.build_complete),)
opendungeons:
	@echo "Using previously built opendungeons."
else
opendungeons: opendungeons-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/opendungeons && cmake . \
		$(DEFAULT_CMAKE_FLAGS) \
		.
	+$(MAKE) -C $(BUILD_WORK)/opendungeons
	+$(MAKE) -C $(BUILD_WORK)/opendungeons install \
		DESTDIR=$(BUILD_STAGE)/opendungeons
	+$(MAKE) -C $(BUILD_WORK)/opendungeons install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/opendungeons/.build_complete
endif

opendungeons-package: opendungeons-stage
	# opendungeons.mk Package Structure
	rm -rf $(BUILD_DIST)/opendungeons

	# opendungeons.mk Prep opendungeons
	cp -a $(BUILD_STAGE)/opendungeons $(BUILD_DIST)

	# opendungeons.mk Sign
	$(call SIGN,opendungeons,general.xml)

	# opendungeons.mk Make .debs
	$(call PACK,opendungeons,DEB_OPENDUNGEONS_V)

	# opendungeons.mk Build cleanup
	rm -rf $(BUILD_DIST)/opendungeons

.PHONY: opendungeons opendungeons-package
