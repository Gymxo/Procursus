ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += libwnck
LIBWNCK_VERSION := 40.0
DEB_LIBWNCK_V   ?= $(LIBWNCK_VERSION)

libwnck-setup: setup
	wget -q -nc -P$(BUILD_SOURCE) https://download.gnome.org/sources/libwnck/40/libwnck-40.0.tar.xz
	$(call EXTRACT_TAR,libwnck-$(LIBWNCK_VERSION).tar.xz,libwnck-$(LIBWNCK_VERSION),libwnck)
	mkdir -p $(BUILD_WORK)/libwnck/build
	echo -e "[host_machine]\n \
	system = 'darwin'\n \
	cpu_family = '$(shell echo $(GNU_HOST_TRIPLE) | cut -d- -f1)'\n \
	cpu = '$(MEMO_ARCH)'\n \
	endian = 'little'\n \
	[properties]\n \
	root = '$(BUILD_BASE)'\n \
	sys_root = '$(BUILD_BASE)'\n \
	objcpp_args = ['-arch', 'arm64']\n \
	objcpp_link_args = ['-arch', 'arm64']\n \
	[paths]\n \
	prefix ='$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)'\n \
	sysconfdir='$(MEMO_PREFIX)/etc'\n \
	localstatedir='$(MEMO_PREFIX)/var'\n \
	[binaries]\n \
	c = '$(CC)'\n \
	cpp = '$(CXX)'\n" > $(BUILD_WORK)/libwnck/build/cross.txt

ifneq ($(wildcard $(BUILD_WORK)/libwnck/.build_complete),)
libwnck:
	find $(BUILD_STAGE)/libwnck -type f -exec codesign --remove {} \; &> /dev/null; \
	find $(BUILD_STAGE)/libwnck -type f -exec codesign --sign $(CODESIGN_IDENTITY) --force --preserve-metadata=entitlements,requirements,flags,runtime {} \; &> /dev/null
	@echo "Using previously built libwnck."
else
libwnck: libwnck-setup
	cd $(BUILD_WORK)/libwnck/build && PKG_CONFIG="pkg-config" meson \
		--cross-file cross.txt \
		-Dintrospection=disabled \
		-Dstartup_notification=disabled \
		..
	sed -i 's/,--version-script//g' $(BUILD_WORK)/libwnck/build/build.ninja
	ninja -C $(BUILD_WORK)/libwnck/build
	+DESTDIR="$(BUILD_STAGE)/libwnck" ninja -C $(BUILD_WORK)/libwnck/build install
	+DESTDIR="$(BUILD_BASE)" ninja -C $(BUILD_WORK)/libwnck/build install
	touch $(BUILD_WORK)/libwnck/.build_complete
endif

libwnck-package: libwnck-stage
	# gtk+.mk Package Structure
	rm -rf $(BUILD_DIST)/libwnck

	# gtk+.mk Prep libwnck
	cp -a $(BUILD_STAGE)/libwnck $(BUILD_DIST)

	# gtk+.mk Sign
	$(call SIGN,libwnck,general.xml)

	# gtk+.mk Make .debs
	$(call PACK,libwnck,DEB_LIBWNCK_V)

	# gtk+.mk Build cleanup
	rm -rf $(BUILD_DIST)/libwnck

.PHONY: libwnck libwnck-package
