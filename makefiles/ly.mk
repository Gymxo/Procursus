ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS  += ly
LY_VERSION := 0.5.0
DEB_LY_V   ?= $(LY_VERSION)

ly-setup: setup
	if [ ! -d "$(BUILD_WORK)/ly" ]; then \
		git clone https://github.com/nullgemm/ly.git $(BUILD_WORK)/ly; \
	fi
	$(SED) -i 's/gcc/cc/g' $(BUILD_WORK)/ly/makefile
	$(SED) -i 's|\$$(FLAGS)|\$$(FLAGS) $(LDFLAGS) $(CFLAGS)|g' $(BUILD_WORK)/ly/makefile

ifneq ($(wildcard $(BUILD_WORK)/ly/.build_complete),)
ly:
	@echo "Using previously built ly."
else
ly: ly-setup libx11 libxau freetype libgcrypt libxmu libxft libxext
	+$(MAKE) -C $(BUILD_WORK)/ly github
	+$(MAKE) -C $(BUILD_WORK)/ly
	+$(MAKE) -C $(BUILD_WORK)/ly install \
		DESTDIR=$(BUILD_STAGE)/ly
	+$(MAKE) -C $(BUILD_WORK)/ly install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/ly/.build_complete
endif

ly-package: ly-stage
	# ly.mk Package Structure
	rm -rf $(BUILD_DIST)/ly

	# ly.mk Prep ly
	cp -a $(BUILD_STAGE)/ly $(BUILD_DIST)

	# ly.mk Sign
	$(call SIGN,ly,general.xml)

	# ly.mk Make .debs
	$(call PACK,ly,DEB_LY_V)

	# ly.mk Build cleanup
	rm -rf $(BUILD_DIST)/ly

.PHONY: ly ly-package
