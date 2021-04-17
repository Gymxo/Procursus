ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += motif
MOTIF_VERSION := 2.3.8
DEB_MOTIF_V   ?= $(MOTIF_VERSION)

motif-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://downloads.sourceforge.net/project/motif/Motif%202.3.8%20Source%20Code/motif-2.3.8.tar.gz
	$(call EXTRACT_TAR,motif-$(MOTIF_VERSION).tar.gz,motif-$(MOTIF_VERSION),motif)

ifneq ($(wildcard $(BUILD_WORK)/motif/.build_completeq),)
motif:
	@echo "Using previously built motif."
else
motif: motif-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/motif && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-x \
		--enable-png \
		--enable-jpeg \
		--x-includes=$(BUILD_BASE)/usr/include \
		--x-libraries=$(BUILD_BASE)/usr/lib \
		--with-freetype-includes=$(BUILD_BASE)/usr/include \
		--with-freetype-lib=$(BUILD_BASE)/usr/lib \
		--with-libpng-lib=$(BUILD_BASE)/usr/lib \
		--with-libpng-includes=$(BUILD_BASE)/usr/include \
		--with-libjpeg-lib=$(BUILD_BASE)/usr/lib \
		--with-libjpeg-includes=$(BUILD_BASE)/usr/include \
		--with-fontconfig-includes=$(BUILD_BASE)/usr/include \
		--with-fontconfig-lib=$(BUILD_BASE)/usr/lib \
		--enable-xft \
		--disable-dependency-tracking \
        --disable-silent-rules \
		--enable-themes
	+$(MAKE) -i -C $(BUILD_WORK)/motif
	+$(MAKE) -i -C $(BUILD_WORK)/motif install \
		DESTDIR=$(BUILD_STAGE)/motif
	+$(MAKE) -i -C $(BUILD_WORK)/motif install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/motif/.build_complete
endif

motif-package: motif-stage
	# motif.mk Package Structure
	rm -rf $(BUILD_DIST)/motif

	# motif.mk Prep motif
	cp -a $(BUILD_STAGE)/motif $(BUILD_DIST)

	# motif.mk Sign
	$(call SIGN,motif,general.xml)

	# motif.mk Make .debs
	$(call PACK,motif,DEB_MOTIF_V)

	# motif.mk Build cleanup
	rm -rf $(BUILD_DIST)/motif

.PHONY: motif motif-package
