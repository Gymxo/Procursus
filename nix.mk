ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += nix
NIX_VERSION := 2.3.11
DEB_NIX_V   ?= $(NIX_VERSION)

nix-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://releases.nixos.org/nix/nix-2.3.11/nix-2.3.11.tar.xz
	$(call EXTRACT_TAR,nix-$(NIX_VERSION).tar.xz,nix-$(NIX_VERSION),nix)

ifneq ($(wildcard $(BUILD_WORK)/nix/.build_complete),)
nix:
	@echo "Using previously built nix."
else
nix: nix-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/nix && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--disable-dependency-tracking
	+$(MAKE) -C $(BUILD_WORK)/nix
	+$(MAKE) -C $(BUILD_WORK)/nix install \
		DESTDIR=$(BUILD_STAGE)/nix
	+$(MAKE) -C $(BUILD_WORK)/nix install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/nix/.build_complete
endif

nix-package: nix-stage
	# nix.mk Package Structure
	rm -rf $(BUILD_DIST)/nix

	# nix.mk Prep nix
	cp -a $(BUILD_STAGE)/nix $(BUILD_DIST)

	# nix.mk Sign
	$(call SIGN,nix,general.xml)

	# nix.mk Make .debs
	$(call PACK,nix,DEB_NIX_V)

	# nix.mk Build cleanup
	rm -rf $(BUILD_DIST)/nix

.PHONY: nix nix-package
