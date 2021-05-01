ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += fltk
FLTK_VERSION := 1.3.5
DEB_FLTK_V   ?= $(FLTK_VERSION)

fltk-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.fltk.org/pub/fltk/1.3.5/fltk-1.3.5-source.tar.gz
	$(call EXTRACT_TAR,fltk-$(FLTK_VERSION)-source.tar.gz,fltk-$(FLTK_VERSION),fltk)
	$(SED) -i -e 's/-U__APPLE__//' -e 's/-mmacosx-version-min=10.3//' $(BUILD_WORK)/fltk/configure

ifneq ($(wildcard $(BUILD_WORK)/fltk/.build_complete`),)
fltk:
	@echo "Using previously built fltk."
else
fltk: fltk-setup libx11 libxau libxmu xorgproto
	cd $(BUILD_WORK)/fltk && ./configure -C \
	$(DEFAULT_CONFIGURE_FLAGS) \
	--with-x \
	--disable-gl \
	--enable-x11 \
	--disable-tests \
	--enable-threads \
	--x-libraries=$(BUILD_BASE)/usr/lib \
	--x-includes=$(BUILD_BASE)/usr/include
	cd $(BUILD_WORK)/fltk && $(SED) -i 's/__APPLE__/NONEXIST/' $(grep -rl -- __APPLE__ $(find . -name \*.c -o -name \*.cxx -o -name \*.h -o -name \*.H))
	$(SED) -i 's/fluid test/fluid/' $(BUILD_WORK)/fltk/Makefile
	+$(MAKE) -C $(BUILD_WORK)/fltk
	+$(MAKE) -C $(BUILD_WORK)/fltk install \
		DESTDIR=$(BUILD_STAGE)/fltk
	+$(MAKE) -C $(BUILD_WORK)/fltk install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/fltk/.build_complete
endif

fltk-package: fltk-stage
	# fltk.mk Package Structure
	rm -rf $(BUILD_DIST)/fltk

	# fltk.mk Prep fltk
	cp -a $(BUILD_STAGE)/fltk $(BUILD_DIST)

	# fltk.mk Sign
	$(call SIGN,fltk,general.xml)

	# fltk.mk Make .debs
	$(call PACK,fltk,DEB_FLTK_V)

	# fltk.mk Build cleanup
	rm -rf $(BUILD_DIST)/fltk

.PHONY: fltk fltk-package