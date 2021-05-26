ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += qtbase
QTBASE_VERSION := 5.15.2
DEB_QTBASE_V   ?= $(QTBASE_VERSION)

qtbase-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://download.qt.io/official_releases/qt/5.15/5.15.2/single/qt-everywhere-src-5.15.2.tar.xz
	$(call EXTRACT_TAR,qt-everywhere-src-$(QTBASE_VERSION).tar.xz,qt-everywhere-src-$(QTBASE_VERSION),qtbase)

ifneq ($(wildcard $(BUILD_WORK)/qtbase/.build_complete),)
qtbase:
	@echo "Using previously built qtbase."
else
qtbase: qtbase-setup
	cd $(BUILD_WORK)/qtbase && ./configure \
		-xplatform macx-ios-clang \
		-xcb \
		-xcb-xlib \
		-L$(BUILD_BASE)$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib \
		-I$(BUILD_BASE)$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include \
		-prefix $(MEMO_PREFIX)$(MEMO_SUB_PREFIX) \
		-sysconfdir $(MEMO_PREFIX)/etc \
		-bindir $(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin \
		-gui \
		-widgets \
		-release \
        -opensource \
        -confirm-license \
        -shared \
        -nomake examples \
        -nomake tests \
        -verbose \
        -skip wayland \
        -qt-pcre \
        -xkbcommon \
        -dbus \
        -no-linuxfb \
        -no-libudev \
        -no-avx \
        -no-avx2 \
        -optimize-size \
		-sysroot $(TARGET_SYSROOT) \
		-continue \
		QMAKE_LFLAGS+="$(LDFLAGS)"
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