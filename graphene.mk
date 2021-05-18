ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += graphene
GRAPHENE_VERSION := 1.5.4
DEB_GRAPHENE_V   ?= $(GRAPHENE_VERSION)

graphene-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://mirror.umd.edu/gnome/sources/graphene/1.5/graphene-1.5.4.tar.xz
	$(call EXTRACT_TAR,graphene-$(GRAPHENE_VERSION).tar.xz,graphene-$(GRAPHENE_VERSION),graphene)

ifneq ($(wildcard $(BUILD_WORK)/graphene/.build_complete),)
graphene:
	@echo "Using previously built graphene."
else
graphene: graphene-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/graphene && autoreconf -vfi && mkdir -p "native-build" && \
	pushd "native-build" && \
	unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS PKG_CONFIG_PATH PKG_CONFIG_LIBDIR ACLOCAL_PATH && export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig && ../configure \
    	--enable-introspection=yes \
		--prefix=/usr/local
	export GI_CROSS_LAUNCHER=$(PWD)/build_tools/gi-cross-launcher-save.sh && \
	$(MAKE) -C $(BUILD_WORK)/graphene/native-build
	cd $(BUILD_WORK)/graphene && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--enable-introspection=no
	export GI_CROSS_LAUNCHER=$(PWD)/build_tools/gi-cross-launcher-load.sh && \
	$(MAKE) CFLAGS="-arch arm64 $(CFLAGS)" -C $(BUILD_WORK)/graphene
	+$(MAKE) -C $(BUILD_WORK)/graphene install \s
		DESTDIR=$(BUILD_STAGE)/graphene
	+$(MAKE) -C $(BUILD_WORK)/graphene install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/graphene/.build_complete
endif

graphene-package: graphene-stage
	# graphene.mk Package Structure
	rm -rf $(BUILD_DIST)/graphene

	# graphene.mk Prep graphene
	cp -a $(BUILD_STAGE)/graphene $(BUILD_DIST)

	# graphene.mk Sign
	$(call SIGN,graphene,general.xml)

	# graphene.mk Make .debs
	$(call PACK,graphene,DEB_GRAPHENE_V)

	# graphene.mk Build cleanup
	rm -rf $(BUILD_DIST)/graphene

.PHONY: graphene graphene-package
