ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += awesome
AWESOME_VERSION := 4.3
DEB_AWESOME_V   ?= $(AWESOME_VERSION)

awesome-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://github.com/awesomeWM/awesome-releases/raw/master/awesome-4.3.tar.xz
	$(call EXTRACT_TAR,awesome-$(AWESOME_VERSION).tar.xz,awesome-$(AWESOME_VERSION),awesome)

ifneq ($(wildcard $(BUILD_WORK)/awesome/.build_complete),)
awesome:
	@echo "Using previously built awesome."
else
awesome: awesome-setup libx11 libxau libxmu xorgproto xxhash
	mkdir -p $(BUILD_WORK)/awesome/build
	cd $(BUILD_WORK)/awesome/build && cmake .. \
		$(DEFAULT_CMAKE_FLAGS) \
		..
	+$(MAKE) -C $(BUILD_WORK)/awesome/build
	+$(MAKE) -C $(BUILD_WORK)/awesome/build install \
		DESTDIR=$(BUILD_STAGE)/awesome
	+$(MAKE) -C $(BUILD_WORK)/awesome/build install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/awesome/.build_complete
endif

awesome-package: awesome-stage
# awesome.mk Package Structure
	rm -rf $(BUILD_DIST)/awesome
	
# awesome.mk Prep awesome
	cp -a $(BUILD_STAGE)/awesome $(BUILD_DIST)
	
# awesome.mk Sign
	$(call SIGN,awesome,general.xml)
	
# awesome.mk Make .debs
	$(call PACK,awesome,DEB_AWESOME_V)
	
# awesome.mk Build cleanup
	rm -rf $(BUILD_DIST)/awesome

.PHONY: awesome awesome-package