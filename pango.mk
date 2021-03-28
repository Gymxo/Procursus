ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += pango
PANGO_VERSION := 1.0.8
DEB_PANGO_V   ?= $(PANGO_VERSION)

pango-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://gitlab.gnome.org/GNOME/pango/-/archive/1.48.4/pango-1.48.4.tar.gz
	$(call PGP_VERIFY,pango-$(PANGO_VERSION).tar.gz)
	$(call EXTRACT_TAR,pango-$(PANGO_VERSION).tar.gz,pango-$(PANGO_VERSION),pango)

ifneq ($(wildcard $(BUILD_WORK)/pango/.build_complete),)
pango:
	@echo "Using previously built pango."
else
pango: pango-setup libx11 libxau libxmu xorgproto libfribidi
	cd $(BUILD_WORK)/pango && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var
	+$(MAKE) -C $(BUILD_WORK)/pango
	+$(MAKE) -C $(BUILD_WORK)/pango install \
		DESTDIR=$(BUILD_STAGE)/pango
	+$(MAKE) -C $(BUILD_WORK)/pango install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/pango/.build_complete
endif

pango-package: pango-stage
# pango.mk Package Structure
	rm -rf $(BUILD_DIST)/pango
	
# pango.mk Prep pango
	cp -a $(BUILD_STAGE)/pango $(BUILD_DIST)
	
# pango.mk Sign
	$(call SIGN,pango,general.xml)
	
# pango.mk Make .debs
	$(call PACK,pango,DEB_PANGO_V)
	
# pango.mk Build cleanup
	rm -rf $(BUILD_DIST)/pango

.PHONY: pango pango-package