ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

<<<<<<< HEAD
SUBPROJECTS    += mc
MC_VERSION := 4.8.26
DEB_MC_V   ?= $(MC_VERSION)
=======
SUBPROJECTS += mc
MC_VERSION  := 4.8.26
DEB_MC_V    ?= $(MC_VERSION)
>>>>>>> b3101346967d65d30c8678c524e834b1862b3ab0

mc-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) http://ftp.midnight-commander.org/mc-$(MC_VERSION).tar.xz
	$(call EXTRACT_TAR,mc-$(MC_VERSION).tar.xz,mc-$(MC_VERSION),mc)

ifneq ($(wildcard $(BUILD_WORK)/mc/.build_complete),)
mc:
	@echo "Using previously built mc."
else
<<<<<<< HEAD
mc: mc-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/mc && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS)
	+$(MAKE) -C $(BUILD_WORK)/mc
	+$(MAKE) -C $(BUILD_WORK)/mc install \
		DESTDIR=$(BUILD_STAGE)/mc
	+$(MAKE) -C $(BUILD_WORK)/mc install \
		DESTDIR=$(BUILD_BASE)
=======
mc: mc-setup slang2 glib2.0 gettext libssh2
	cd $(BUILD_WORK)/mc && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		PKG_CONFIG="pkg-config --define-prefix"
	+$(MAKE) -C $(BUILD_WORK)/mc
	+$(MAKE) -C $(BUILD_WORK)/mc install \
		DESTDIR=$(BUILD_STAGE)/mc
>>>>>>> b3101346967d65d30c8678c524e834b1862b3ab0
	touch $(BUILD_WORK)/mc/.build_complete
endif

mc-package: mc-stage
# mc.mk Package Structure
	rm -rf $(BUILD_DIST)/mc
	
# mc.mk Prep mc
	cp -a $(BUILD_STAGE)/mc $(BUILD_DIST)
	
# mc.mk Sign
	$(call SIGN,mc,general.xml)
	
# mc.mk Make .debs
	$(call PACK,mc,DEB_MC_V)
	
# mc.mk Build cleanup
	rm -rf $(BUILD_DIST)/mc

.PHONY: mc mc-package
