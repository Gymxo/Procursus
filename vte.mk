ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += vte
VTE_VERSION := 0.64.1
DEB_VTE_V   ?= $(VTE_VERSION)

vte-setup: setup
	wget -q -nc -P$(BUILD_SOURCE) https://download.gnome.org/sources/vte/0.64/vte-0.64.1.tar.xz
	$(call EXTRACT_TAR,vte-$(VTE_VERSION).tar.xz,vte-$(VTE_VERSION),vte)
	mkdir -p $(BUILD_WORK)/vte/build
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
	cpp = '$(CXX)'\n" > $(BUILD_WORK)/vte/build/cross.txt

ifneq ($(wildcard $(BUILD_WORK)/vte/.build_complete),)
vte:
	@echo "Using previously built vte."
else
vte: vte-setup
	cd $(BUILD_WORK)/vte/build && PKG_CONFIG="pkg-config" meson \
		--cross-file cross.txt \
		-D_b_symbolic_functions=false \
		-Dgir=false \
		-Dglade=false \
		-D_systemd=false \
		-Dvapi=false \
		..
	ninja -C $(BUILD_WORK)/vte/build
	+DESTDIR="$(BUILD_STAGE)/vte" ninja -C $(BUILD_WORK)/vte/build install
	+DESTDIR="$(BUILD_BASE)" ninja -C $(BUILD_WORK)/vte/build install
	touch $(BUILD_WORK)/vte/.build_complete
endif

vte-package: vte-stage
	# gtk+.mk Package Structure
	rm -rf $(BUILD_DIST)/vte

	# gtk+.mk Prep vte
	cp -a $(BUILD_STAGE)/vte $(BUILD_DIST)

	# gtk+.mk Sign
	$(call SIGN,vte,general.xml)

	# gtk+.mk Make .debs
	$(call PACK,vte,DEB_VTE_V)

	# gtk+.mk Build cleanup
	rm -rf $(BUILD_DIST)/vte

.PHONY: vte vte-package
