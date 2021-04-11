ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += libepoxy
LIBEPOXY_VERSION := 1.5.5
DEB_LIBEPOXY_V   ?= $(LIBEPOXY_VERSION)

libepoxy-setup: setup
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

ifneq ($(wildcard $(BUILD_WORK)/libepoxy/.build_complete),)
libepoxy:
	@echo "Using previously built libepoxy."
else
libepoxy: libepoxy-setup libx11 libxau libxmu xorgproto
	cd $(BUILD_WORK)/libepoxy && cd _build && PKG_CONFIG="pkg-config" meson \
		--cross-file cross.txt
	cd $(BUILD_WORK)/libepoxy/_build; \
		DESTDIR="$(BUILD_STAGE)/libepoxy" meson install; \
		DESTDIR="$(BUILD_BASE)" meson install
	touch $(BUILD_WORK)/libepoxy/.build_complete
endif

libepoxy-package: libepoxy-stage
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