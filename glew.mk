ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += glew
GLEW_VERSION := 2.2.0
DEB_GLEW_V   ?= $(GLEW_VERSION)

glew-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://github.com/nigels-com/glew/archive/refs/tags/glew-2.2.0.tar.gz
	$(call EXTRACT_TAR,glew-$(GLEW_VERSION).tar.gz,glew-glew-$(GLEW_VERSION),glew)

ifneq ($(wildcard $(BUILD_WORK)/glew/.build_complete),)
glew:
	@echo "Using previously built glew."
else
glew: glew-setup libx11 libxau libxmu xorgproto
	cd $(BUILD_WORK)/glew 
	+$(MAKE) -C $(BUILD_WORK)/glew
	+$(MAKE) -C $(BUILD_WORK)/glew install \
		DESTDIR=$(BUILD_STAGE)/glew
	+$(MAKE) -C $(BUILD_WORK)/glew install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/glew/.build_complete
endif

glew-package: glew-stage
# glew.mk Package Structure
	rm -rf $(BUILD_DIST)/glew
	
# glew.mk Prep glew
	cp -a $(BUILD_STAGE)/glew $(BUILD_DIST)
	
# glew.mk Sign
	$(call SIGN,glew,general.xml)
	
# glew.mk Make .debs
	$(call PACK,glew,DEB_GLEW_V)
	
# glew.mk Build cleanup
	rm -rf $(BUILD_DIST)/glew

.PHONY: glew glew-package