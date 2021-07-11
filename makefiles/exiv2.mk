ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += exiv2
EXIV2_VERSION := 0.27.3
DEB_EXIV2_V   ?= $(EXIV2_VERSION)-1

exiv2-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) \
		https://exiv2.org/builds/exiv2-0.27.3-Source.tar.gz
	$(call EXTRACT_TAR,exiv2-$(EXIV2_VERSION)-Source.tar.gz,exiv2-$(EXIV2_VERSION)-Source,exiv2)

# TODO: build all bins
ifneq ($(wildcard $(BUILD_WORK)/exiv2/.build_complete),)
exiv2:
	@echo "Using previously built exiv2."
else
exiv2: exiv2-setup
	cd $(BUILD_WORK)/exiv2 && cmake . \
		$(DEFAULT_CMAKE_FLAGS) \
		.
	+$(MAKE) -C $(BUILD_WORK)/exiv2
	+$(MAKE) -C $(BUILD_WORK)/exiv2 install \
		DESTDIR="$(BUILD_STAGE)/exiv2"
	+$(MAKE) -C $(BUILD_WORK)/exiv2 install \
		DESTDIR="$(BUILD_BASE)"
	touch $(BUILD_WORK)/exiv2/.build_complete
endif

exiv2-package: exiv2-stage
	# exiv2.mk Package Structure
	rm -rf $(BUILD_DIST)/exiv2

	# exiv2.mk Prep exiv2
	cp -a $(BUILD_STAGE)/exiv2 $(BUILD_DIST)

	# exiv2.mk Sign
	$(call SIGN,exiv2,general.xml)

	# exiv2.mk Make .debs
	$(call PACK,exiv2,DEB_EXIV2_V)

	# exiv2.mk Build cleanup
	rm -rf $(BUILD_DIST)/exiv2

.PHONY: exiv2 exiv2-package
