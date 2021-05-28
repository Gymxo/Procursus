ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += qtbase
QTBASE_VERSION := 5.15.2
DEB_QTBASE_V   ?= $(QTBASE_VERSION)

qtbase-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://download.qt.io/official_releases/qt/5.15/$(QTBASE_VERSION)/single/qt-everywhere-src-$(QTBASE_VERSION).tar.xz
	$(call EXTRACT_TAR,qt-everywhere-src-$(QTBASE_VERSION).tar.xz,qt-everywhere-src-$(QTBASE_VERSION),qtbase)

ifneq ($(wildcard $(BUILD_WORK)/qtbase/.build_complete),)
qtbase:
	@echo "Using previously built qtbase."
else
qtbase: qtbase-setup
	cd $(BUILD_WORK)/qtbase && ./configure \
	    -confirm-license \
		-platform macx-clang \
		-xplatform linux-clang \
		-L$(BUILD_BASE)$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib \
		-I$(BUILD_BASE)$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include \
		-prefix $(MEMO_PREFIX)$(MEMO_SUB_PREFIX) \
		-sysconfdir $(MEMO_PREFIX)/etc \
		-bindir $(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin \
        -opensource \
	    -plugin-sql-mysql \
	    -plugin-sql-odbc \
	    -plugin-sql-psql \
	    -plugin-sql-sqlite \
	    -no-sql-sqlite2 \
	    -plugin-sql-tds \
	    -system-sqlite \
	    -system-harfbuzz \
	    -system-zlib \
	    -system-libpng \
	    -system-libjpeg \
	    -system-doubleconversion \
	    -system-pcre \
	    -openssl \
	    -no-rpath \
	    -verbose \
	    -optimized-qmake \
	    -dbus-linked \
	    -no-strip \
	    -no-separate-debug-info \
	    -qpa xcb \
	    -xcb \
		-no-pch \
	    -glib \
	    -icu \
	    -accessibility \
	    -compile-examples \
	    -no-directfb \
	    -no-use-gold-linker \
	    -no-mimetype-database \
	    -no-feature-relocatable \
	    -xcb-native-painting \
		-sysroot $(BUILD_BASE) \
		-continue \
	    QMAKE_CFLAGS="$(CFLAGS)" \
	    QMAKE_CXXFLAGS="$(CXXFLAGS)" \
	    QMAKE_LFLAGS="$(LDFLAGS)"
	+$(MAKE) -i -C $(BUILD_WORK)/qtbase
	+$(MAKE) -i -C $(BUILD_WORK)/qtbase install \
		DESTDIR=$(BUILD_STAGE)/qtbase
	+$(MAKE) -i -C $(BUILD_WORK)/qtbase install \
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