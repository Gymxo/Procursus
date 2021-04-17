ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += ois
OIS_VERSION := 1.5
DEB_OIS_V   ?= $(OIS_VERSION)

ois-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://codeload.github.com/wgois/OIS/tar.gz/refs/tags/v$(OIS_VERSION)
	cd $(BUILD_SOURCE) && cp v$(OIS_VERSION) $(BUILD_SOURCE)/v$(OIS_VERSION).tar.gz
	rm $(BUILD_SOURCE)/v$(OIS_VERSION)
	$(call EXTRACT_TAR,v$(OIS_VERSION).tar.gz,ois-$(OIS_VERSION),ois)

ifneq ($(wildcard $(BUILD_WORK)/ois/.build_complete1),)
ois:
	@echo "Using previously built ois."
else
ois: ois-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/ois && cmake . \
		$(DEFAULT_CMAKE_FLAGS) \
		.
	+$(MAKE) -C $(BUILD_WORK)/ois
	+$(MAKE) -C $(BUILD_WORK)/ois install \
		DESTDIR=$(BUILD_STAGE)/ois
	+$(MAKE) -C $(BUILD_WORK)/ois install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/ois/.build_complete
endif

ois-package: ois-stage
	# ois.mk Package Structure
	rm -rf $(BUILD_DIST)/ois

	# ois.mk Prep ois
	cp -a $(BUILD_STAGE)/ois $(BUILD_DIST)

	# ois.mk Sign
	$(call SIGN,ois,general.xml)

	# ois.mk Make .debs
	$(call PACK,ois,DEB_OIS_V)

	# ois.mk Build cleanup
	rm -rf $(BUILD_DIST)/ois

.PHONY: ois ois-package
