ifneq ($(PROCURSUS),1)
$(error Use the main MakEFLle)
endif

SUBPROJECTS      += efl
EFL_VERSION := 1.25.1
DEB_EFL_V   ?= $(EFL_VERSION)

efl-setup: setup
	wget -q -nc -P$(BUILD_SOURCE) https://download.enlightenment.org/rel/libs/efl/efl-1.25.1.tar.xz
	$(call EXTRACT_TAR,efl-$(EFL_VERSION).tar.xz,efl-$(EFL_VERSION),efl)
	mkdir -p $(BUILD_WORK)/efl/build
	echo -e "[host_machine]\n \
	system = 'darwin'\n \
	cpu_family = '$(shell echo $(GNU_HOST_TRIPLE) | cut -d- -f1)'\n \
	cpu = '$(MEMO_ARCH)'\n \
	endian = 'little'\n \
	[properties]\n \
	root = '$(BUILD_BASE)'\n \
	sys_root = '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk'\n \
	objcpp_args = ['-arch', 'arm64']\n \
	objcpp_link_args = ['-arch', 'arm64']\n \
	[paths]\n \
	prefix ='$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)'\n \
	sysconfdir='$(MEMO_PREFIX)/etc'\n \
	localstatedir='$(MEMO_PREFIX)/var'\n \
	[binaries]\n \
	c = '$(CC)'\n \
	cpp = '$(CXX)'\n" > $(BUILD_WORK)/efl/build/cross.txt

ifneq ($(wildcard $(BUILD_WORK)/efl/.build_complete),)
efl:
	@echo "Using previously built efl."
else
efl: efl-setup libx11 mesa
	cd $(BUILD_WORK)/efl/build && PKG_CONFIG="pkg-config" meson \
		--cross-file cross.txt \
		-Daudio=false \
		-Dx11=true \
		-Dcocoa=false \
		-Dsystemd=false \
		-Dgstreamer=false \
		-Dpulseaudio=false \
		-Dvnc-server=true \
		-Dlibmount=false \
		-Deeze=false \
		..
	+ninja -C $(BUILD_WORK)/efl/build
	+DESTDIR="$(BUILD_STAGE)/efl" ninja -C $(BUILD_WORK)/efl/build install
	+DESTDIR="$(BUILD_BASE)" ninja -C $(BUILD_WORK)/efl/build install
	touch $(BUILD_WORK)/efl/.build_complete
endif

efl-package: efl-stage
	# efl.mk Package Structure
	rm -rf $(BUILD_DIST)/efl
	mkdir -p $(BUILD_DIST)/efl
	
	# efl.mk Prep efl
	cp -a $(BUILD_STAGE)/efl $(BUILD_DIST)
	
	# efl.mk Sign
	$(call SIGN,efl,general.xml)
	
	# efl.mk Make .debs
	$(call PACK,efl,DEB_EFL_V)
	
	# efl.mk Build cleanup
	rm -rf $(BUILD_DIST)/efl

.PHONY: efl efl-package

