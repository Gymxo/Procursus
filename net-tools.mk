ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += net-tools
NET-TOOLS_VERSION := 2.10
DEB_NET-TOOLS_V   ?= $(NET-TOOLS_VERSION)

net-tools-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://pilotfiber.dl.sourceforge.net/project/net-tools/net-tools-2.10.tar.xz
	$(call EXTRACT_TAR,net-tools-$(NET-TOOLS_VERSION).tar.xz,net-tools-$(NET-TOOLS_VERSION),net-tools)

ifneq ($(wildcard $(BUILD_WORK)/net-tools/.build_complete),)
net-tools:
	@echo "Using previously built net-tools."
else
net-tools: net-tools-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/net-tools 
	+$(MAKE) -C $(BUILD_WORK)/net-tools hostname
	touch $(BUILD_WORK)/net-tools/.build_complete
endif

net-tools-package: net-tools-stage
# net-tools.mk Package Structure
	rm -rf $(BUILD_DIST)/net-tools
	
# net-tools.mk Prep net-tools
	cp -a $(BUILD_STAGE)/net-tools $(BUILD_DIST)
	
# net-tools.mk Sign
	$(call SIGN,net-tools,general.xml)
	
# net-tools.mk Make .debs
	$(call PACK,net-tools,DEB_NET-TOOLS_V)
	
# net-tools.mk Build cleanup
	rm -rf $(BUILD_DIST)/net-tools

.PHONY: net-tools net-tools-package