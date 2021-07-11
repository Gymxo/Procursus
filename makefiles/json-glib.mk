ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += json-glib
JSON-GLIB_VERSION := 1.6.2
DEB_JSON-GLIB_V   ?= $(JSON-GLIB_VERSION)

json-glib-setup: setup
	wget -q -nc -P$(BUILD_SOURCE) https://download.gnome.org/sources/json-glib/1.6/json-glib-1.6.2.tar.xz
	$(call EXTRACT_TAR,json-glib-$(JSON-GLIB_VERSION).tar.xz,json-glib-$(JSON-GLIB_VERSION),json-glib)
	mkdir -p $(BUILD_WORK)/json-glib/build
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
	cpp = '$(CXX)'\n" > $(BUILD_WORK)/json-glib/build/cross.txt

ifneq ($(wildcard $(BUILD_WORK)/json-glib/.build_complete),)
json-glib:
	@echo "Using previously built json-glib."
else
json-glib: json-glib-setup
	cd $(BUILD_WORK)/json-glib/build && PKG_CONFIG="pkg-config" meson \
		--cross-file cross.txt \
		-Dintrospection=disabled \
		-Dgtk_doc=disabled \
		..
	ninja -C $(BUILD_WORK)/json-glib/build
	+DESTDIR="$(BUILD_STAGE)/json-glib" ninja -C $(BUILD_WORK)/json-glib/build install
	+DESTDIR="$(BUILD_BASE)" ninja -C $(BUILD_WORK)/json-glib/build install
	touch $(BUILD_WORK)/json-glib/.build_complete
endif

json-glib-package: json-glib-stage
	# gtk+.mk Package Structure
	rm -rf $(BUILD_DIST)/json-glib

	# gtk+.mk Prep json-glib
	cp -a $(BUILD_STAGE)/json-glib $(BUILD_DIST)

	# gtk+.mk Sign
	$(call SIGN,json-glib,general.xml)

	# gtk+.mk Make .debs
	$(call PACK,json-glib,DEB_JSON-GLIB_V)

	# gtk+.mk Build cleanup
	rm -rf $(BUILD_DIST)/json-glib

.PHONY: json-glib json-glib-package
