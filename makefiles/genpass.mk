ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += genpass
GENPASS_VERSION := 1.20.10
DEB_GENPASS_V   ?= $(GENPASS_VERSION)

genpass-setup: setup

ifneq ($(wildcard $(BUILD_WORK)/genpass/.build_complete),)
genpass:
	@echo "Using previously built genpass."
else
genpass: genpass-setup 
	+$(MAKE) -C $(BUILD_WORK)/genpass
	+$(MAKE) -C $(BUILD_WORK)/genpass install \
		DESTDIR=$(BUILD_STAGE)/genpass
	+$(MAKE) -C $(BUILD_WORK)/genpass install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/genpass/.build_complete
endif

genpass-package: genpass-stage
# genpass.mk Package Structure
	rm -rf $(BUILD_DIST)/genpass
	
# genpass.mk Prep genpass
	cp -a $(BUILD_STAGE)/genpass $(BUILD_DIST)
	
# genpass.mk Sign
	$(call SIGN,genpass,general.xml)
	
# genpass.mk Make .debs
	$(call PACK,genpass,DEB_GENPASS_V)
	
# genpass.mk Build cleanup
	rm -rf $(BUILD_DIST)/genpass

.PHONY: genpass genpass-package