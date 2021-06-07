ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += xpra
XPRA_VERSION := 4.2
DEB_XPRA_V   ?= $(XPRA_VERSION)

xpra-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://github.com/Xpra-org/xpra/archive/refs/tags/v4.2.tar.gz
	$(call EXTRACT_TAR,v$(XPRA_VERSION).tar.gz,xpra-$(XPRA_VERSION),xpra)

ifneq ($(wildcard $(BUILD_WORK)/xpra/.build_complete),)
xpra:
	@echo "Using previously built xpra."
else
xpra: xpra-setup
	cd $(BUILD_WORK)/xpra && $(DEFAULT_SETUP_PY_ENV) python3 ./setup.py install \
	--prefix="$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)" \
	--root="$(BUILD_STAGE)/xpra" \
	--with-Xdummy \
	--with-x11 \
	--with-debug
endif

xpra-package: xpra-stage
# xpra.mk Package Structure
	rm -rf $(BUILD_DIST)/xpra
	
# xpra.mk Prep xpra
	cp -a $(BUILD_STAGE)/xpra $(BUILD_DIST)
	
# xpra.mk Sign
	$(call SIGN,xpra,general.xml)
	
# xpra.mk Make .debs
	$(call PACK,xpra,DEB_XPRA_V)
	
# xpra.mk Build cleanup
	rm -rf $(BUILD_DIST)/xpra

.PHONY: xpra xpra-package
