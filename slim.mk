ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS  += slim
SLIM_VERSION := 1.3.6
DEB_SLIM_V   ?= $(SLIM_VERSION)

slim-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://managedway.dl.sourceforge.net/project/slim.berlios/slim-$(SLIM_VERSION).tar.gz
	$(call EXTRACT_TAR,slim-$(SLIM_VERSION).tar.gz,slim-$(SLIM_VERSION),slim)

ifneq ($(wildcard $(BUILD_WORK)/slim/.build_complete),)
slim:
	@echo "Using previously built slim."
else
slim: slim-setup libx11 libxau freetype libgcrypt libxmu libxft libxext
	cd $(BUILD_WORK)/slim && cmake . \
		$(DEFAULT_CMAKE_FLAGS) \
		-DBUILD_SLIMLOCK=true \
		-DUSE_PAM=false \
		..
	+$(MAKE) -C $(BUILD_WORK)/slim
	+$(MAKE) -C $(BUILD_WORK)/slim install \
		DESTDIR=$(BUILD_STAGE)/slim
	+$(MAKE) -C $(BUILD_WORK)/slim install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/slim/.build_complete
endif

slim-package: slim-stage
	# slim.mk Package Structure
	rm -rf $(BUILD_DIST)/slim

	# slim.mk Prep slim
	cp -a $(BUILD_STAGE)/slim $(BUILD_DIST)

	# slim.mk Sign
	$(call SIGN,slim,general.xml)

	# slim.mk Make .debs
	$(call PACK,slim,DEB_SLIM_V)

	# slim.mk Build cleanup
	rm -rf $(BUILD_DIST)/slim

.PHONY: slim slim-package
