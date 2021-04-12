ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

<<<<<<< HEAD
SUBPROJECTS    += libepoxy
=======
SUBPROJECTS      += libepoxy
>>>>>>> b3101346967d65d30c8678c524e834b1862b3ab0
LIBEPOXY_VERSION := 1.5.5
DEB_LIBEPOXY_V   ?= $(LIBEPOXY_VERSION)

libepoxy-setup: setup
<<<<<<< HEAD
	wget -q -nc -P $(BUILD_SOURCE) https://github.com/anholt/libepoxy/releases/download/1.5.5/libepoxy-1.5.5.tar.xz
	$(call EXTRACT_TAR,libepoxy-$(LIBEPOXY_VERSION).tar.xz,libepoxy-$(LIBEPOXY_VERSION),libepoxy)
	$(call DO_PATCH,libepoxy,libepoxy,-p1)
	mkdir -p $(BUILD_WORK)/libepoxy/_build

	echo -e "[host_machine]\n \
	cpu_family = '$(shell echo $(GNU_HOST_TRIPLE) | cut -d- -f1)'\n \
	cpu = '$(MEMO_ARCH)'\n \
	endian = 'little'\n \
	system = 'darwin'\n \
	[properties]\n \
	root = '$(BUILD_BASE)'\n \
	[paths]\n \
	prefix ='/usr'\n \
	[binaries]\n \
	c = '$(CC)'\n \
	cpp = '$(CXX)'\n" > $(BUILD_WORK)/libepoxy/_build/cross.txt

	@echo "You need to install Mako with pip3 before building."
	@echo "/usr/bin/pip3 install mako --user"
=======
	wget -q -nc -P$(BUILD_SOURCE) https://download.gnome.org/sources/libepoxy/$(shell echo $(LIBEPOXY_VERSION) | cut -d. -f-2)/libepoxy-$(LIBEPOXY_VERSION).tar.xz
	$(call EXTRACT_TAR,libepoxy-$(LIBEPOXY_VERSION).tar.xz,libepoxy-$(LIBEPOXY_VERSION),libepoxy)
	mkdir -p $(BUILD_WORK)/libepoxy/build
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
	cpp = '$(CXX)'\n" > $(BUILD_WORK)/libepoxy/build/cross.txt
>>>>>>> b3101346967d65d30c8678c524e834b1862b3ab0

ifneq ($(wildcard $(BUILD_WORK)/libepoxy/.build_complete),)
libepoxy:
	@echo "Using previously built libepoxy."
else
<<<<<<< HEAD
libepoxy: libepoxy-setup libx11 libxau libxmu xorgproto
	cd $(BUILD_WORK)/libepoxy && cd _build && PKG_CONFIG="pkg-config" meson \
		--cross-file cross.txt
	cd $(BUILD_WORK)/libepoxy/_build; \
		DESTDIR="$(BUILD_STAGE)/libepoxy" meson install; \
		DESTDIR="$(BUILD_BASE)" meson install
=======
libepoxy: libepoxy-setup libx11 mesa
	cd $(BUILD_WORK)/libepoxy/build && PKG_CONFIG="pkg-config" meson \
		--cross-file cross.txt \
		-Dtests=false \
		..
	+ninja -C $(BUILD_WORK)/libepoxy/build
	+DESTDIR="$(BUILD_STAGE)/libepoxy" ninja -C $(BUILD_WORK)/libepoxy/build install
	+DESTDIR="$(BUILD_BASE)" ninja -C $(BUILD_WORK)/libepoxy/build install
>>>>>>> b3101346967d65d30c8678c524e834b1862b3ab0
	touch $(BUILD_WORK)/libepoxy/.build_complete
endif

libepoxy-package: libepoxy-stage
<<<<<<< HEAD
# libepoxy.mk Package Structure
	rm -rf $(BUILD_DIST)/libepoxy
	
# libepoxy.mk Prep libepoxy
	cp -a $(BUILD_STAGE)/libepoxy $(BUILD_DIST)
	
# libepoxy.mk Sign
	$(call SIGN,libepoxy,general.xml)
	
# libepoxy.mk Make .debs
	$(call PACK,libepoxy,DEB_LIBEPOXY_V)
	
# libepoxy.mk Build cleanup
	rm -rf $(BUILD_DIST)/libepoxy

.PHONY: libepoxy libepoxy-package
=======
	# libepoxy.mk Package Structure
	rm -rf $(BUILD_DIST)/libepoxy
	mkdir -p $(BUILD_DIST)/libepoxy
	
	# libepoxy.mk Prep libepoxy
	cp -a $(BUILD_STAGE)/libepoxy $(BUILD_DIST)
	
	# libepoxy.mk Sign
	$(call SIGN,libepoxy,general.xml)
	
	# libepoxy.mk Make .debs
	$(call PACK,libepoxy,DEB_LIBEPOXY_V)
	
	# libepoxy.mk Build cleanup
	rm -rf $(BUILD_DIST)/libepoxy

.PHONY: libepoxy libepoxy-package

>>>>>>> b3101346967d65d30c8678c524e834b1862b3ab0
