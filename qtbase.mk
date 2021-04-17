ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += qtbase
QTBASE_VERSION := 6.0.3
DEB_QTBASE_V   ?= $(QTBASE_VERSION)

qtbase-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://download.qt.io/official_releases/qt/6.0/6.0.3/single/qt-everywhere-src-6.0.3.tar.xz
	$(call EXTRACT_TAR,qt-everywhere-src-$(QTBASE_VERSION).tar.xz,qt-everywhere-src-$(QTBASE_VERSION),qtbase)

ifneq ($(wildcard $(BUILD_WORK)/qtbase/.build_complete),)
qtbase:
	@echo "Using previously built qtbase."
else
qtbase: qtbase-setup
	cd $(BUILD_WORK)/qtbase/qtbase && ./configure -h \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=$(MEMO_PREFIX)$(MEMO_SUB_PREFIX) \
		--localstatedir=$(MEMO_PREFIX)/var \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--bindir=$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin \
		--mandir=$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/man
		--gui=yes \
		--widgets=yes \
		--xcb=yes \
		--qt-host-path=/usr/local/Cellar/qt/6.0.3
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