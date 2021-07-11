ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS += qBittorrent
QBITTORRENT_VERSION := 4.3.4.1
DEB_QBITTORRENT_V   ?= $(QBITTORRENT_VERSION)

qBittorrent-setup: setup
	wget -q -nc -P $(BUILD_SOURCE)  https://github.com/qbittorrent/qBittorrent/archive/refs/tags/release-4.3.4.1.tar.gz
	$(call EXTRACT_TAR,release-$(QBITTORRENT_VERSION).tar.gz,qBittorrent-release-$(QBITTORRENT_VERSION),qBittorrent)

ifneq ($(wildcard $(BUILD_WORK)/qBittorrent/.build_complete),)
qBittorrent:
	@echo "Using previously built qBittorrent."
else
qBittorrent: qBittorrent-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/qBittorrent && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=/etc \
		--localstatedir=/var
	+$(MAKE) -C $(BUILD_WORK)/qBittorrent
	+$(MAKE) -C $(BUILD_WORK)/qBittorrent install \
		DESTDIR=$(BUILD_STAGE)/qBittorrent
	+$(MAKE) -C $(BUILD_WORK)/qBittorrent install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/qBittorrent/.build_complete
endif

qBittorrent-package: qBittorrent-stage
# qBittorrent.mk Package Structure
	rm -rf $(BUILD_DIST)/qBittorrent
	
# qBittorrent.mk Prep qBittorrent
	cp -a $(BUILD_STAGE)/qBittorrent $(BUILD_DIST)
	
# qBittorrent.mk Sign
	$(call SIGN,qBittorrent,general.xml)
	
# qBittorrent.mk Make .debs
	$(call PACK,qBittorrent,DEB_QBITTORRENT _V)
	
# qBittorrent.mk Build cleanup
	rm -rf $(BUILD_DIST)/qBittorrent

.PHONY: qBittorrent qBittorrent-package