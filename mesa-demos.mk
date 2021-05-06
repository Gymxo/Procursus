ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

<<<<<<< HEAD
SUBPROJECTS    += mesa-demos
MESA-DEMOS_VERSION := 8.4.0
DEB_MESA-DEMOS_V   ?= $(MESA-DEMOS_VERSION)

mesa-demos-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://archive.mesa3d.org/demos/mesa-demos-$(MESA-DEMOS_VERSION).tar.gz{,.sig} 
	$(call PGP_VERIFY,mesa-demos-$(MESA-DEMOS_VERSION).tar.gz)
	$(call EXTRACT_TAR,mesa-demos-$(MESA-DEMOS_VERSION).tar.gz,mesa-demos-$(MESA-DEMOS_VERSION),mesa-demos)
=======
SUBPROJECTS        += mesa-demos
MESA_DEMOS_VERSION := 8.4.0
DEB_MESA_DEMOS_V   ?= $(MESA_DEMOS_VERSION)

mesa-demos-setup: setup
	wget -q -nc -P$(BUILD_SOURCE) https://archive.mesa3d.org//demos/mesa-demos-$(MESA_DEMOS_VERSION).tar.gz
	$(call EXTRACT_TAR,mesa-demos-$(MESA_DEMOS_VERSION).tar.gz,mesa-demos-$(MESA_DEMOS_VERSION),mesa-demos)
	$(SED) -i s/OpenGL/GL/ $(BUILD_WORK)/mesa-demos/src/util/gl_wrap.h
>>>>>>> 7dfd23f (uhh)

ifneq ($(wildcard $(BUILD_WORK)/mesa-demos/.build_complete),)
mesa-demos:
	@echo "Using previously built mesa-demos."
else
<<<<<<< HEAD
mesa-demos: mesa-demos-setup libx11 libxau libxmu xorgproto mesa
	cd $(BUILD_WORK)/mesa-demos && ./autogen.sh \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var
	+$(MAKE) -C $(BUILD_WORK)/mesa-demos
	+$(MAKE) -C $(BUILD_WORK)/mesa-demos install \
		DESTDIR=$(BUILD_STAGE)/mesa-demos
	+$(MAKE) -C $(BUILD_WORK)/mesa-demos install \
		DESTDIR=$(BUILD_BASE)
=======
mesa-demos: mesa-demos-setup mesa libglu glew libx11 libxext freetype
	cd $(BUILD_WORK)/mesa-demos && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--enable-x11 \
		--enable-gles2 \
		--enable-gles1 \
		--enable-osmesa
	+$(MAKE) -C $(BUILD_WORK)/mesa-demos
	+$(MAKE) -C $(BUILD_WORK)/mesa-demos install \
		DESTDIR=$(BUILD_STAGE)/mesa-demos
>>>>>>> 7dfd23f (uhh)
	touch $(BUILD_WORK)/mesa-demos/.build_complete
endif

mesa-demos-package: mesa-demos-stage
<<<<<<< HEAD
# mesa-demos.mk Package Structure
	rm -rf $(BUILD_DIST)/mesa-demos
	
# mesa-demos.mk Prep mesa-demos
	cp -a $(BUILD_STAGE)/mesa-demos $(BUILD_DIST)
	
# mesa-demos.mk Sign
	$(call SIGN,mesa-demos,general.xml)
	
# mesa-demos.mk Make .debs
	$(call PACK,mesa-demos,DEB_MESA-DEMOS_V)
	
# mesa-demos.mk Build cleanup
	rm -rf $(BUILD_DIST)/mesa-demos

.PHONY: mesa-demos mesa-demos-package
=======
	# mesa-demos.mk Package Structure
	rm -rf $(BUILD_DIST)/mesa-demos
	mkdir -p $(BUILD_DIST)/mesa-demos
	
	# mesa-demos.mk Prep mesa-demos
	cp -a $(BUILD_STAGE)/mesa-demos $(BUILD_DIST)
	
	# mesa-demos.mk Sign
	$(call SIGN,mesa-demos,general.xml)
	
	# mesa-demos.mk Make .debs
	$(call PACK,mesa-demos,DEB_MESA_DEMOS_V)
	
	# mesa-demos.mk Build cleanup
	rm -rf $(BUILD_DIST)/mesa-demos

.PHONY: mesa-demos mesa-demos-package
>>>>>>> 7dfd23f (uhh)
