ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += tracker
TRACKER_VERSION := 3.1.1
DEB_TRACKER_V   ?= $(TRACKER_VERSION)

tracker-setup: setup
	wget -q -nc -P$(BUILD_SOURCE) https://download-fallback.gnome.org/sources/tracker/3.1/tracker-3.1.1.tar.xz
	$(call EXTRACT_TAR,tracker-$(TRACKER_VERSION).tar.xz,tracker-$(TRACKER_VERSION),tracker)
	mkdir -p $(BUILD_WORK)/tracker/build
	echo -e "[host_machine]\n \
	system = 'darwin'\n \
	cpu_family = '$(shell echo $(GNU_HOST_TRIPLE) | cut -d- -f1)'\n \
	cpu = '$(MEMO_ARCH)'\n \
	endian = 'little'\n \
	[properties]\n \
	root = '$(BUILD_BASE)'\n \
	[paths]\n \
	prefix ='$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)'\n \
	sysconfdir='$(MEMO_PREFIX)/etc'\n \
	localstatedir='$(MEMO_PREFIX)/var'\n \
	[binaries]\n \
	c = '$(CC)'\n \
	cpp = '$(CXX)'\n" > $(BUILD_WORK)/tracker/build/cross.txt

ifneq ($(wildcard $(BUILD_WORK)/tracker/.build_complete),)
tracker:
	@echo "Using previously built tracker."
else
tracker: tracker-setup
	cd $(BUILD_WORK)/tracker/build && PKG_CONFIG="pkg-config" meson \
		--cross-file cross.txt \
		-Dwith_introspection=false \
		..
	ninja -C $(BUILD_WORK)/tracker/build
	+DESTDIR="$(BUILD_STAGE)/tracker" ninja -C $(BUILD_WORK)/tracker/build install
	+DESTDIR="$(BUILD_BASE)" ninja -C $(BUILD_WORK)/tracker/build install
	touch $(BUILD_WORK)/tracker/.build_complete
endif

tracker-package: tracker-stage
	rm -rf $(BUILD_DIST)/tracker{0,-dev}
	mkdir -p $(BUILD_DIST)/tracker{0,-dev}/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	#tracker.mk Prep libepxoy0
	cp -a $(BUILD_STAGE)/tracker/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/tracker.0.dylib $(BUILD_DIST)/TRACKER0/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# tracker.mk Prep tracker-dev
	cp -a $(BUILD_STAGE)/tracker/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/!(tracker.0.dylib) $(BUILD_DIST)/tracker-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib
	cp -a $(BUILD_STAGE)/tracker/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include $(BUILD_DIST)/tracker-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)

	# tracker.mk Sign
	$(call SIGN,TRACKER0,general.xml)

	# tracker.mk Make .debs
	$(call PACK,TRACKER0,DEB_TRACKER_V)
	$(call PACK,tracker-dev,DEB_TRACKER_V)

	# tracker.mk Build cleanup
	rm -rf $(BUILD_DIST)/tracker{0,-dev}

.PHONY: tracker tracker-package
