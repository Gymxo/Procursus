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
	cd $(BUILD_WORK)/graphene && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--enable-introspection=no
	+$(MAKE) -C $(BUILD_WORK)/graphene
	+$(MAKE) -C $(BUILD_WORK)/graphene install \s
		DESTDIR=$(BUILD_STAGE)/graphene
	+$(MAKE) -C $(BUILD_WORK)/graphene install \
		DESTDIR=$(BUILD_BASE)
	$(call AFTER_BUILD)
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
