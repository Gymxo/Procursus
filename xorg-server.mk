ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

<<<<<<< HEAD
SUBPROJECTS    += xorg-server
=======
SUBPROJECTS         += xorg-server
>>>>>>> b3101346967d65d30c8678c524e834b1862b3ab0
XORG-SERVER_VERSION := 1.20.10
DEB_XORG-SERVER_V   ?= $(XORG-SERVER_VERSION)

xorg-server-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive//individual/xserver/xorg-server-$(XORG-SERVER_VERSION).tar.gz{,.sig}
	$(call PGP_VERIFY,xorg-server-$(XORG-SERVER_VERSION).tar.gz)
	$(call EXTRACT_TAR,xorg-server-$(XORG-SERVER_VERSION).tar.gz,xorg-server-$(XORG-SERVER_VERSION),xorg-server)
<<<<<<< HEAD
=======
	$(call DO_PATCH,xorg-server,xorg-server,-p1)
	$(SED) -i 's/__APPLE__/__PEAR__/' $(BUILD_WORK)/xorg-server/miext/rootless/rootlessWindow.c

#   --enable-glamor needs GBM and libepoxy

###
# No package 'xcb-renderutil' found
# No package 'xcb-image' found
# No package 'xcb-icccm' found
# No package 'xcb-keysyms' found
###
>>>>>>> b3101346967d65d30c8678c524e834b1862b3ab0

ifneq ($(wildcard $(BUILD_WORK)/xorg-server/.build_complete),)
xorg-server:
	@echo "Using previously built xorg-server."
else
<<<<<<< HEAD
xorg-server: xorg-server-setup libx11 libxau libxmu xorgproto font-util libpixman libpng16 mesa libxfont2 libxkbfile glproto xcb-util-image xcb-util-keysyms
	cd $(BUILD_WORK)/xorg-server && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--enable-kdrive \
		--enable-xorg \
		--disable-glamor \
		--with-default-font-path \
		--enable-xephyr
=======
xorg-server: xorg-server-setup libx11 libxau libxmu xorgproto font-util libpixman libpng16 mesa libxfont2 libxkbfile libxdamage libxt libxpm libxaw libxres libxext xcb-util
	cd $(BUILD_WORK)/xorg-server && ./autogen.sh -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--enable-xorg \
		--with-default-font-path \
		--enable-dmx \
		--enable-xephyr \
		--enable-kdrive \
		--disable-glamor \
		--disable-xquartz \
		PKG_CONFIG="pkg-config --define-prefix"
	$(SED) -i 's|panoramiX.\$$(OBJEXT)||' $(BUILD_WORK)/xorg-server/hw/dmx/Makefile
#   ^^ Wtf
>>>>>>> b3101346967d65d30c8678c524e834b1862b3ab0
	+$(MAKE) -C $(BUILD_WORK)/xorg-server
	+$(MAKE) -C $(BUILD_WORK)/xorg-server install \
		DESTDIR=$(BUILD_STAGE)/xorg-server
	+$(MAKE) -C $(BUILD_WORK)/xorg-server install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xorg-server/.build_complete
endif

xorg-server-package: xorg-server-stage
# xorg-server.mk Package Structure
	rm -rf $(BUILD_DIST)/xorg-server
	
# xorg-server.mk Prep xorg-server
	cp -a $(BUILD_STAGE)/xorg-server $(BUILD_DIST)
	
# xorg-server.mk Sign
	$(call SIGN,xorg-server,general.xml)
	
# xorg-server.mk Make .debs
	$(call PACK,xorg-server,DEB_xorg-server_V)
	
# xorg-server.mk Build cleanup
	rm -rf $(BUILD_DIST)/xorg-server

<<<<<<< HEAD
.PHONY: xorg-server xorg-server-package
=======
.PHONY: xorg-server xorg-server-package
>>>>>>> b3101346967d65d30c8678c524e834b1862b3ab0
