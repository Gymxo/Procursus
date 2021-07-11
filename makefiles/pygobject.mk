ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += pygobject
PYGOBJECT_VERSION := 3.40.1
DEB_PYGOBJECT_V   ?= $(PYGOBJECT_VERSION)

pygobject-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://download-fallback.gnome.org/sources/pygobject/3.40/pygobject-3.40.1.tar.xz
	$(call EXTRACT_TAR,pygobject-$(PYGOBJECT_VERSION).tar.xz,pygobject-$(PYGOBJECT_VERSION),pygobject)
	mkdir -p $(BUILD_WORK)/pygobject/build
	
	echo -e "[host_machine]\n \
	cpu_family = '$(shell echo $(GNU_HOST_TRIPLE) | cut -d- -f1)'\n \
	cpu = '$(MEMO_ARCH)'\n \
	endian = 'little'\n \
	system = 'darwin'\n \
	[properties]\n \
	root = '$(BUILD_BASE)'\n \
	needs_exe_wrapper = true\n \
	[paths]\n \
	prefix ='$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)'\n \
	[binaries]\n \
	c = '$(CC)'\n \
	objc = '$(CC)'\n \
	cpp = '$(CXX)'\n \
	pkgconfig = '$(shell which pkg-config)'\n" > $(BUILD_WORK)/pygobject/build/cross.txt


ifneq ($(wildcard $(BUILD_WORK)/pygobject/.build_complete),)
pygobject:
	@echo "Using previously built pygobject."
else
pygobject: pygobject-setup
	cd $(BUILD_WORK)/pygobject/build && meson \
		--cross-file cross.txt \
		-Dtests=false \
		..
	ninja -C $(BUILD_WORK)/pygobject/build
	+DESTDIR="$(BUILD_STAGE)/pygobject" ninja -C $(BUILD_WORK)/pygobject/build install
	+DESTDIR="$(BUILD_BASE)" ninja -C $(BUILD_WORK)/pygobject/build install
	touch $(BUILD_WORK)/pygobject/.build_complete
endif

pygobject-package: pygobject-stage
# pygobject.mk Package Structure
	rm -rf $(BUILD_DIST)/pygobject
	
# pygobject.mk Prep pygobject
	cp -a $(BUILD_STAGE)/pygobject $(BUILD_DIST)
	
# pygobject.mk Sign
	$(call SIGN,pygobject,general.xml)
	
# pygobject.mk Make .debs
	$(call PACK,pygobject,DEB_PYGOBJECT_V)
	
# pygobject.mk Build cleanup
	rm -rf $(BUILD_DIST)/pygobject

.PHONY: pygobject pygobject-package
