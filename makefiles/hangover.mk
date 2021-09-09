ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS += hangover
HANGOVER_VERSION := 2.2
DEB_HANGOVER_V   ?= $(HANGOVER_VERSION)

hangover-setup: setup
	if [ ! -d "$(BUILD_WORK)/hangover" ]; then \
		git clone https://github.com/AndreRH/hangover.git $(BUILD_WORK)/hangover; \
		cd "$(BUILD_WORK)/hangover"; \
		git fetch origin; \
		git reset --hard origin/master; \
		git submodule update --init; \
	fi

ifneq ($(wildcard $(BUILD_WORK)/hangover/.build_complete),)
hangover:
	@echo "Using previously built hangover."
else
hangover: hangover-setup
	+$(MAKE) -C $(BUILD_WORK)/hangover
	touch $(BUILD_WORK)/hangover/.build_complete
endif

hangover-package: hangover-stage
	# hangover.mk Package Structure
	rm -rf $(BUILD_DIST)/hangover

	# hangover.mk Prep hangover
	cp -a $(BUILD_STAGE)/hangover $(BUILD_DIST)

	# hangover.mk Make .debs
	$(call PACK,hangover,DEB_HANGOVER_V)

	# hangover.mk Build cleanup
	rm -rf $(BUILD_DIST)/hangover

.PHONY: hangover hangover-package
