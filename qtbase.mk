ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += qtbase
QTBASE_VERSION := 6.0.3
DEB_QTBASE_V   ?= $(QTBASE_VERSION)

qtbase-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://github.com/qt/qtbase/archive/refs/tags/v6.0.3.tar.gz
	$(call EXTRACT_TAR,v$(QTBASE_VERSION).tar.gz,qtbase-$(QTBASE_VERSION),qtbase)

ifneq ($(wildcard $(BUILD_WORK)/qtbase/.build_complete),)
qtbase:
	@echo "Using previously built qtbase."
else
qtbase: qtbase-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/qtbase && cmake . \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_SYSTEM_NAME=Darwin \
		-DCMAKE_CROSSCOMPILING=true \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DCMAKE_INSTALL_NAME_DIR=/usr \
		-DCMAKE_OSX_SYSROOT="$(TARGET_SYSROOT)" \
		-DCMAKE_FIND_ROOT_PATH=$(BUILD_BASE) \
		-DQT_HOST_PATH=/usr/local/Cellar/qt/6.0.3  \
		-DCMAKE_INSTALL_RPATH=/usr
	+$(MAKE) -C $(BUILD_WORK)/qtbase
	+$(MAKE) -C $(BUILD_WORK)/qtbase install \
		DESTDIR=$(BUILD_STAGE)/qtbase
	+$(MAKE) -C $(BUILD_WORK)/qtbase install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/qtbase/.build_complete
endif

qtbase-package: qtbase-stage
# qtbase.mk Package Structure
	rm -rf $(BUILD_DIST)/qtbase
	
# qtbase.mk Prep qtbase
	cp -a $(BUILD_STAGE)/qtbase $(BUILD_DIST)
	
# qtbase.mk Sign
	$(call SIGN,qtbase,general.xml)
	
# qtbase.mk Make .debs
	$(call PACK,qtbase,DEB_QTBASE_V)
	
# qtbase.mk Build cleanup
	rm -rf $(BUILD_DIST)/qtbase

.PHONY: qtbase qtbase-package