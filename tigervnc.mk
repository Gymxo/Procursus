ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += tigervnc
TIGERVNC_VERSION := 1.11.0
DEB_TIGERVNC_V   ?= $(TIGERVNC_VERSION)

tigervnc-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://github.com/TigerVNC/tigervnc/archive/refs/tags/v1.11.0.tar.gz
	$(call EXTRACT_TAR,v$(TIGERVNC_VERSION).tar.gz,tigervnc-$(TIGERVNC_VERSION),tigervnc)

ifneq ($(wildcard $(BUILD_WORK)/tigervnc/.build_complete),)
tigervnc:
	@echo "Using previously built tigervnc."
else
tigervnc: tigervnc-setup libx11 libxau libxmu xorgproto 
	cd $(BUILD_WORK)/tigervnc && cmake . \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_SYSTEM_NAME=Darwin \
		-DCMAKE_CROSSCOMPILING=true \
		-DCMAKE_INSTALL_PREFIX=/ \
		-DCMAKE_INSTALL_NAME_DIR=/usr/lib \
		-DCMAKE_OSX_SYSROOT="$(TARGET_SYSROOT)" \
		-DCMAKE_FIND_ROOT_PATH=$(BUILD_BASE) \
		-DCMAKE_INSTALL_RPATH=/usr \
		-DBUILD_VIEWER=OFF
	+$(MAKE) -C $(BUILD_WORK)/tigervnc
	+$(MAKE) -C $(BUILD_WORK)/tigervnc install \
		DESTDIR=$(BUILD_STAGE)/tigervnc
	+$(MAKE) -C $(BUILD_WORK)/tigervnc install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/tigervnc/.build_complete
endif

tigervnc-package: tigervnc-stage
# tigervnc.mk Package Structure
	rm -rf $(BUILD_DIST)/tigervnc
	
# tigervnc.mk Prep tigervnc
	cp -a $(BUILD_STAGE)/tigervnc $(BUILD_DIST)
	
# tigervnc.mk Sign
	$(call SIGN,tigervnc,general.xml)
	
# tigervnc.mk Make .debs
	$(call PACK,tigervnc,DEB_TIGERVNC_V)
	
# tigervnc.mk Build cleanup
	rm -rf $(BUILD_DIST)/tigervnc

.PHONY: tigervnc tigervnc-package