ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += xterm
XTERM_VERSION := 0.52.1
DEB_XTERM_V   ?= $(XTERM_VERSION)

xterm-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://invisible-island.net/datafiles/release/xterm.tar.gz
	$(call EXTRACT_TAR,xterm.tar.gz,xterm-366,xterm)

ifneq ($(wildcard $(BUILD_WORK)/xterm/.build_complete),)
xterm:
	@echo "Using previously built xterm."
else
xterm: xterm-setup libx11 libxau libxmu xorgproto 
	cd $(BUILD_WORK)/xterm && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var
	+$(MAKE) -C $(BUILD_WORK)/xterm
	+$(MAKE) -C $(BUILD_WORK)/xterm install \
		DESTDIR=$(BUILD_STAGE)/xterm
	+$(MAKE) -C $(BUILD_WORK)/xterm install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xterm/.build_complete
endif

xterm-package: xterm-stage
# xterm.mk Package Structure
	rm -rf $(BUILD_DIST)/xterm
	
# xterm.mk Prep xterm
	cp -a $(BUILD_STAGE)/xterm $(BUILD_DIST)
	
# xterm.mk Sign
	$(call SIGN,xterm,general.xml)
	
# xterm.mk Make .debs
	$(call PACK,xterm,DEB_XTERM_V)
	
# xterm.mk Build cleanup
	rm -rf $(BUILD_DIST)/xterm

.PHONY: xterm xterm-package