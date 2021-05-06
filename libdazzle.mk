ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += libdazzle
LIBDAZZLE_VERSION := 3.40.0
DEB_LIBDAZZLE_V   ?= $(LIBDAZZLE_VERSION)

libdazzle-setup: setup
	wget -q -nc -P$(BUILD_SOURCE) https://download-fallback.gnome.org/sources/libdazzle/3.40/libdazzle-3.40.0.tar.xz
	$(call EXTRACT_TAR,libdazzle-$(LIBDAZZLE_VERSION).tar.xz,libdazzle-$(LIBDAZZLE_VERSION),libdazzle)
	mkdir -p $(BUILD_WORK)/libdazzle/build
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
	cpp = '$(CXX)'\n" > $(BUILD_WORK)/libdazzle/build/cross.txt

ifneq ($(wildcard $(BUILD_WORK)/libdazzle/.build_complete),)
libdazzle:
	@echo "Using previously built libdazzle."
else
libdazzle: libdazzle-setup
	cd $(BUILD_WORK)/libdazzle/build && PKG_CONFIG="pkg-config" meson \
		--cross-file cross.txt \
		-Dwith_introspection=false \
		..
	ninja -C $(BUILD_WORK)/libdazzle/build
	+DESTDIR="$(BUILD_STAGE)/libdazzle" ninja -C $(BUILD_WORK)/libdazzle/build install
	+DESTDIR="$(BUILD_BASE)" ninja -C $(BUILD_WORK)/libdazzle/build install
	touch $(BUILD_WORK)/libdazzle/.build_complete
endif

libdazzle-package: libdazzle-stage
	rm -rf $(BUILD_DIST)/libdazzle{0,-dev}
	mkdir -p $(BUILD_DIST)/libdazzle{0,-dev}/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	#libdazzle.mk Prep libepxoy0
	cp -a $(BUILD_STAGE)/libdazzle/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libdazzle.0.dylib $(BUILD_DIST)/LIBDAZZLE0/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# libdazzle.mk Prep libdazzle-dev
	cp -a $(BUILD_STAGE)/libdazzle/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/!(libdazzle.0.dylib) $(BUILD_DIST)/libdazzle-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib
	cp -a $(BUILD_STAGE)/libdazzle/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include $(BUILD_DIST)/libdazzle-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)

	# libdazzle.mk Sign
	$(call SIGN,LIBDAZZLE0,general.xml)

	# libdazzle.mk Make .debs
	$(call PACK,LIBDAZZLE0,DEB_LIBDAZZLE_V)
	$(call PACK,libdazzle-dev,DEB_LIBDAZZLE_V)

	# libdazzle.mk Build cleanup
	rm -rf $(BUILD_DIST)/libdazzle{0,-dev}

.PHONY: libdazzle libdazzle-package
