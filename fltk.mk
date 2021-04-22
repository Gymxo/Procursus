ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += fltk
FLTK_VERSION := 1.3.5
DEB_FLTK_V   ?= $(FLTK_VERSION)

fltk-setup: setup
	if [ ! -d "$(BUILD_WORK)/fltk" ]; then \
 	git clone https://github.com/fltk/fltk.git  $(BUILD_WORK)/fltk; \
	fi
	$(call DO_PATCH,fltk,fltk,-p1)

ifneq ($(wildcard $(BUILD_WORK)/fltk/.build_complete`),)
fltk:
	@echo "Using previously built fltk."
else
fltk: fltk-setup libx11 libxau libxmu xorgproto
	cd $(BUILD_WORK)/fltk && ./autogen.sh -C \
	$(DEFAULT_CONFIGURE_FLAGS) \
	--with-x \
	--disable-gl \
	--enable-x11 \
	--disable-threads \
	--disable-xdbe \
	--x-libraries=$(BUILD_BASE)/usr/lib \
	--x-includes=$(BUILD_BASE)/usr/include
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