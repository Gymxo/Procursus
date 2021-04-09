ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += libxkbcommon
LIBXKBCOMMON_VERSION := 1.2.1
DEB_LIBXKBCOMMON_V   ?= $(LIBXKBCOMMON_VERSION)

libxkbcommon-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://xkbcommon.org/download/libxkbcommon-1.2.1.tar.xz
	$(call EXTRACT_TAR,libxkbcommon-$(LIBXKBCOMMON_VERSION).tar.xz,libxkbcommon-$(LIBXKBCOMMON_VERSION),libxkbcommon)
	mkdir -p $(BUILD_WORK)/libxkbcommon/build

	echo -e "[host_machine]\n \
	cpu_family = '$(shell echo $(GNU_HOST_TRIPLE) | cut -d- -f1)'\n \
	cpu = '$(MEMO_ARCH)'\n \
	endian = 'little'\n \
	system = 'darwin'\n \
	[properties]\n \
	root = '$(BUILD_BASE)'\n \
	skip_sanity_check = true\n \
	sys_root = '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk'\n \
	objcpp_args = ['-arch', 'arm64']\n \
	objcpp_link_args = ['-arch', 'arm64']\n \
	[paths]\n \
	prefix ='/usr'\n \
	[binaries]\n \
	c = '$(CC)'\n \
	cpp = '$(CXX)'\n" > $(BUILD_WORK)/libxkbcommon/build/cross.txt

ifneq ($(wildcard $(BUILD_WORK)/libxkbcommon/.build_complete),)
libxkbcommon:
	@echo "Using previously built libxkbcommon."
else
libxkbcommon: libxkbcommon-setup libx11 libxau libxmu xorgproto libfribidi
	cd $(BUILD_WORK)/libxkbcommon/build && PKG_CONFIG="pkg-config" meson \
		--cross-file cross.txt \
		-Denable-wayland=false \
		-Denable-docs=false 
	cd $(BUILD_WORK)/libxkbcommon/build; \
		DESTDIR="$(BUILD_STAGE)/libxkbcommon" meson install; \
		DESTDIR="$(BUILD_BASE)" meson install
	touch $(BUILD_WORK)/libxkbcommon/.build_complete
endif

libxkbcommon-package: libxkbcommon-stage
# libxkbcommon.mk Package Structure
	rm -rf $(BUILD_DIST)/libxkbcommon
	
# libxkbcommon.mk Prep libxkbcommon
	cp -a $(BUILD_STAGE)/libxkbcommon $(BUILD_DIST)
	
# libxkbcommon.mk Sign
	$(call SIGN,libxkbcommon,general.xml)
	
# libxkbcommon.mk Make .debs
	$(call PACK,libxkbcommon,DEB_LIBXKBCOMMON_V)
	
# libxkbcommon.mk Build cleanup
	rm -rf $(BUILD_DIST)/libxkbcommon

.PHONY: libxkbcommon libxkbcommon-package