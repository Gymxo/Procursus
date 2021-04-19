ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += jam
JAM_VERSION := 2.5
DEB_JAM_V   ?= $(JAM_VERSION)

jam-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://master.dl.sourceforge.net/project/ede/jam/2.5-haiku-20080327/jam-2.5-haiku-20080327.tar.gz
	$(call EXTRACT_TAR,jam-$(JAM_VERSION)-haiku-20080327.tar.gz,jam,jam)

ifneq ($(wildcard $(BUILD_WORK)/jam/.build_complete),)
jam:
	@echo "Using previously built jam."
else
jam: jam-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/jam && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-x \
		--x-libraries=$(BUILD_BASE)/usr/lib \
		--x-includes=$(BUILD_BASE)/usr/include \
		--with-fltk-path=$(BUILD_BASE)
	+$(MAKE) -C $(BUILD_WORK)/jam
	+$(MAKE) -C $(BUILD_WORK)/jam install \
		DESTDIR=$(BUILD_STAGE)/jam
	+$(MAKE) -C $(BUILD_WORK)/jam install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/jam/.build_complete
endif

jam-package: jam-stage
	# jam.mk Package Structure
	rm -rf $(BUILD_DIST)/jam

	# jam.mk Prep jam
	cp -a $(BUILD_STAGE)/jam $(BUILD_DIST)

	# jam.mk Sign
	$(call SIGN,jam,general.xml)

	# jam.mk Make .debs
	$(call PACK,jam,DEB_JAM_V)

	# jam.mk Build cleanup
	rm -rf $(BUILD_DIST)/jam

.PHONY: jam jam-package
