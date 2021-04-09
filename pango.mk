ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += pango
PANGO_VERSION := 1.48.4
DEB_PANGO_V   ?= $(PANGO_VERSION)

pango-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://download.gnome.org/sources/pango/1.48/pango-1.48.4.tar.xz
	$(call EXTRACT_TAR,pango-$(PANGO_VERSION).tar.xz,pango-$(PANGO_VERSION),pango)
	$(call DO_PATCH,pango,pango,-p1)
	mkdir -p $(BUILD_WORK)/pango/build

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
	cpp = '$(CXX)'\n" > $(BUILD_WORK)/pango/build/cross.txt

ifneq ($(wildcard $(BUILD_WORK)/pango/.build_complete),)
pango:
	@echo "Using previously built pango."
else
pango: pango-setup libx11 libxau libxmu xorgproto libfribidi
	cd $(BUILD_WORK)/pango/build && PKG_CONFIG="pkg-config" meson \
		--cross-file cross.txt
	cd $(BUILD_WORK)/pango/build; \
		DESTDIR="$(BUILD_STAGE)/pango" meson install; \
		DESTDIR="$(BUILD_BASE)" meson install
	touch $(BUILD_WORK)/pango/.build_complete
endif

pango-package: pango-stage
# pango.mk Package Structure
	rm -rf $(BUILD_DIST)/pango
	
# pango.mk Prep pango
	cp -a $(BUILD_STAGE)/pango $(BUILD_DIST)
	
# pango.mk Sign
	$(call SIGN,pango,general.xml)
	
# pango.mk Make .debs
	$(call PACK,pango,DEB_PANGO_V)
	
# pango.mk Build cleanup
	rm -rf $(BUILD_DIST)/pango

.PHONY: pango pango-package