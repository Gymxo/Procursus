ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += enlightenment
ENLIGHTENMENT_VERSION := 0.24.2
DEB_ENLIGHTENMENT_V   ?= $(ENLIGHTENMENT_VERSION)

enlightenment-setup: setup
	wget -q -nc -P$(BUILD_SOURCE) https://download.enlightenment.org/rel/apps/enlightenment/enlightenment-0.24.2.tar.xz
	$(call EXTRACT_TAR,enlightenment-$(ENLIGHTENMENT_VERSION).tar.xz,enlightenment-$(ENLIGHTENMENT_VERSION),enlightenment)
	mkdir -p $(BUILD_WORK)/enlightenment/build
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
	cpp = '$(CXX)'\n" > $(BUILD_WORK)/enlightenment/build/cross.txt

ifneq ($(wildcard $(BUILD_WORK)/enlightenment/.build_complete),)
enlightenment:
	@echo "Using previously built enlightenment."
else
enlightenment: enlightenment-setup libx11 mesa
	cd $(BUILD_WORK)/enlightenment/build && PKG_CONFIG="pkg-config" meson \
		--cross-file cross.txt \
		-Dsystemd=false \
		-Dwl-x11=false \
		-Dxwayland=false \
		-Dpam=true \
		-Ddevice-udev=false \
		..
	+ninja -C $(BUILD_WORK)/enlightenment/build
	+DESTDIR="$(BUILD_STAGE)/enlightenment" ninja -C $(BUILD_WORK)/enlightenment/build install
	+DESTDIR="$(BUILD_BASE)" ninja -C $(BUILD_WORK)/enlightenment/build install
	touch $(BUILD_WORK)/enlightenment/.build_complete
endif

enlightenment-package: enlightenment-stage
	# enlightenment.mk Package Structure
	rm -rf $(BUILD_DIST)/enlightenment
	mkdir -p $(BUILD_DIST)/enlightenment
	
	# enlightenment.mk Prep enlightenment
	cp -a $(BUILD_STAGE)/enlightenment $(BUILD_DIST)
	
	# enlightenment.mk Sign
	$(call SIGN,enlightenment,general.xml)
	
	# enlightenment.mk Make .debs
	$(call PACK,enlightenment,DEB_ENLIGHTENMENT_V)
	
	# enlightenment.mk Build cleanup
	rm -rf $(BUILD_DIST)/enlightenment

.PHONY: enlightenment enlightenment-package

