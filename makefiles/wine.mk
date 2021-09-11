ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += wine
WINE_VERSION := 1
DEB_WINE_V   ?= $(WINE_VERSION)

wine-setup: setup

ifneq ($(wildcard $(BUILD_WORK)/wine/.build_complete),)
wine:
	@echo "Using previously built wine."
else
wine: wine-setup
	cd $(BUILD_WORK)/wine && autoreconf -fiv
	cd $(BUILD_WORK)/wine && ./configure -C \
	$(DEFAULT_CONFIGURE_FLAGS) \
	--with-wine-tools=/Users/nathan/wine \
	--with-freetype \
	--with-gettext \
	--disable-tests \
	--without-dbus \
	FREETYPE_CFLAGS="-I$(BUILD_BASE)$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include/freetype2" \
	FREETYPE_LIBS="-L$(BUILD_BASE)$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib -lfreetype"
	+$(MAKE) -j8 -C $(BUILD_WORK)/wine
	+$(MAKE) -C $(BUILD_WORK)/wine install \
		DESTDIR=$(BUILD_STAGE)/wine
	$(call AFTER_BUILD)
endif

wine-package: wine-stage
# wine.mk Package Structure
	rm -rf $(BUILD_DIST)/wine
	
# wine.mk Prep wine
	cp -a $(BUILD_STAGE)/wine $(BUILD_DIST)
	
# wine.mk Sign
	$(call SIGN,wine,general.xml)
	
# wine.mk Make .debs
	$(call PACK,wine,DEB_WINE_V)
	
# wine.mk Build cleanup
	rm -rf $(BUILD_DIST)/wine

.PHONY: wine wine-package
