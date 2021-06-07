ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += libhandy
LIBHANDY_VERSION := 1.2.2
DEB_LIBHANDY_V   ?= $(LIBHANDY_VERSION)

libhandy-setup: setup
	wget -q -nc -P$(BUILD_SOURCE) https://gitlab.gnome.org/GNOME/libhandy/-/archive/1.2.2/libhandy-1.2.2.tar.gz
	$(call EXTRACT_TAR,libhandy-$(LIBHANDY_VERSION).tar.gz,libhandy-$(LIBHANDY_VERSION),libhandy)
	mkdir -p $(BUILD_WORK)/libhandy/build
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
	cpp = '$(CXX)'\n" > $(BUILD_WORK)/libhandy/build/cross.txt

ifneq ($(wildcard $(BUILD_WORK)/libhandy/.build_complete),)
libhandy:
	@echo "Using previously built libhandy."
else
libhandy: libhandy-setup
	cd $(BUILD_WORK)/libhandy/build && PKG_CONFIG="pkg-config" meson \
		--cross-file cross.txt \
		-Dintrospection=disabled \
		-Dvalpi=disabled \
		..
	ninja -C $(BUILD_WORK)/libhandy/build
	+DESTDIR="$(BUILD_STAGE)/libhandy" ninja -C $(BUILD_WORK)/libhandy/build install
	+DESTDIR="$(BUILD_BASE)" ninja -C $(BUILD_WORK)/libhandy/build install
	touch $(BUILD_WORK)/libhandy/.build_complete
endif

libhandy-package: libhandy-stage
	rm -rf $(BUILD_DIST)/libhandy{0,-dev}
	mkdir -p $(BUILD_DIST)/libhandy{0,-dev}/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	#libhandy.mk Prep libepxoy0
	cp -a $(BUILD_STAGE)/libhandy/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libhandy.0.dylib $(BUILD_DIST)/LIBHANDY0/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# libhandy.mk Prep libhandy-dev
	cp -a $(BUILD_STAGE)/libhandy/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/!(libhandy.0.dylib) $(BUILD_DIST)/libhandy-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib
	cp -a $(BUILD_STAGE)/libhandy/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include $(BUILD_DIST)/libhandy-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)

	# libhandy.mk Sign
	$(call SIGN,LIBHANDY0,general.xml)

	# libhandy.mk Make .debs
	$(call PACK,LIBHANDY0,DEB_LIBHANDY_V)
	$(call PACK,libhandy-dev,DEB_LIBHANDY_V)

	# libhandy.mk Build cleanup
	rm -rf $(BUILD_DIST)/libhandy{0,-dev}

.PHONY: libhandy libhandy-package
