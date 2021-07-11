ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += gnustep-make
GNUSTEP-MAKE_VERSION := 2.7.0
DEB_GNUSTEP-MAKE_V   ?= $(GNUSTEP-MAKE_VERSION)

gnustep-make-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) http://ftpmain.gnustep.org/pub/gnustep/core/gnustep-make-2.7.0.tar.gz
	$(call EXTRACT_TAR,gnustep-make-$(GNUSTEP-MAKE_VERSION).tar.gz,gnustep-make-$(GNUSTEP-MAKE_VERSION),gnustep-make)

ifneq ($(wildcard $(BUILD_WORK)/gnustep-make/.build_complete),)
gnustep-make:
	@echo "Using previously built gnustep-make."
else
gnustep-make: gnustep-make-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/gnustep-make && ./configure -C \
		--build=$$($(BUILD_MISC)/config.guess) \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr/GNUstep \
		--with-layout=gnustep \
		--with-config-file=/usr/GNUstep/Local/Configuration/GNUstep.conf
	+$(MAKE) -C $(BUILD_WORK)/gnustep-make
	+$(MAKE) -C $(BUILD_WORK)/gnustep-make install \
		DESTDIR=$(BUILD_STAGE)/gnustep-make
	+$(MAKE) -C $(BUILD_WORK)/gnustep-make install \
		DESTDIR=$(BUILD_BASE)
	sudo $(MAKE) -C $(BUILD_WORK)/gnustep-make install
	touch $(BUILD_WORK)/gnustep-make/.build_complete
endif

gnustep-make-package: gnustep-make-stage
	# gnustep-make.mk Package Structure
	rm -rf $(BUILD_DIST)/gnustep-make

	# gnustep-make.mk Prep gnustep-make
	cp -a $(BUILD_STAGE)/gnustep-make $(BUILD_DIST)

	# gnustep-make.mk Sign
	$(call SIGN,gnustep-make,general.xml)

	# gnustep-make.mk Make .debs
	$(call PACK,gnustep-make,DEB_GNUSTEP-MAKE_V)

	# gnustep-make.mk Build cleanup
	rm -rf $(BUILD_DIST)/gnustep-make

.PHONY: gnustep-make gnustep-make-package
