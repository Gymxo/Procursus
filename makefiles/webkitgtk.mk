ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += webkitgtk
WEBKITGTK_VERSION := 2.23.91
DEB_WEBKITGTK_V   ?= $(WEBKITGTK_VERSION)

webkitgtk-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://webkitgtk.org/releases/webkitgtk-2.23.91.tar.xz
	$(call EXTRACT_TAR,webkitgtk-$(WEBKITGTK_VERSION).tar.xz,webkitgtk-$(WEBKITGTK_VERSION),webkitgtk)
	mkdir -p $(BUILD_WORK)/webkitgtk/build

ifneq ($(wildcard $(BUILD_WORK)/webkitgtk/.build_complete),)
webkitgtk:
	@echo "Using previously built webkitgtk."
else
webkitgtk: webkitgtk-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/webkitgtk/build && cmake \
		$(DEFAULT_CMAKE_FLAGS) \
		-DCMAKE_BUILD_TYPE=Release  \
      	-DCMAKE_SKIP_RPATH=ON       \
      	-DPORT=GTK                  \
      	-DUSE_LIBHYPHEN=OFF         \
      	-DENABLE_GAMEPAD=OFF        \
      	-DENABLE_MINIBROWSER=ON     \
      	-DUSE_WOFF2=OFF             \
      	-DUSE_WPE_RENDERER=ON       \
      	-DUSE_SYSTEMD=OFF           \
		-DUSE_ATK=OFF \
      	-DENABLE_BUBBLEWRAP_SANDBOX=OFF \
		-DUSE_EGL=OFF \
		-DUSE_SYSTEM_MALLOC=ON \
		-DUSE_OPENGL=OFF \
		-DUSE_LIBEPOXY=OFF \
		..
	+$(MAKE) -C $(BUILD_WORK)/webkitgtk
	+$(MAKE) -C $(BUILD_WORK)/webkitgtk install \
		DESTDIR=$(BUILD_STAGE)/webkitgtk
	+$(MAKE) -C $(BUILD_WORK)/webkitgtk install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/webkitgtk/.build_complete
endif

webkitgtk-package: webkitgtk-stage
# webkitgtk.mk Package Structure
	rm -rf $(BUILD_DIST)/webkitgtk
	
# webkitgtk.mk Prep webkitgtk
	cp -a $(BUILD_STAGE)/webkitgtk $(BUILD_DIST)
	
# webkitgtk.mk Sign
	$(call SIGN,webkitgtk,general.xml)
	
# webkitgtk.mk Make .debs
	$(call PACK,webkitgtk,DEB_WEBKITGTK_V)
	
# webkitgtk.mk Build cleanup
	rm -rf $(BUILD_DIST)/webkitgtk

.PHONY: webkitgtk webkitgtk-package