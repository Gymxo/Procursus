ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += gtkcord
GTKCORD_VERSION := 0.0.4
DEB_GTKCORD_V   ?= $(GTKCORD_VERSION)

gtkcord-setup: setup
	if [ ! -d "$(BUILD_WORK)/gtkcord" ]; then \
		git clone https://github.com/diamondburned/gtkcord3.git $(BUILD_WORK)/gtkcord; \
	fi

ifneq ($(wildcard $(BUILD_WORK)/gtkcord/.build_complete),)
gtkcord:
	@echo "Using previously built gtkcord."
else
ifneq (,$(findstring darwin,$(MEMO_TARGET)))
gtkcord: gtkcord-setup
else
gtkcord: gtkcord-setup libiosexec
endif
	cd $(BUILD_WORK)/gtkcord && \
		$(DEFAULT_GOLANG_FLAGS) \
		go build -x
	cp -a $(BUILD_WORK)/gtkcord/gtkcord $(BUILD_STAGE)/gtkcord/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin
	cp -a $(BUILD_WORK)/gtkcord/gtkcord.1 $(BUILD_STAGE)/gtkcord/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/man/man1
	touch $(BUILD_WORK)/gtkcord/.build_complete
endif

gtkcord-package: gtkcord-stage
	# gtkcord.mk Package Structure
	rm -rf $(BUILD_DIST)/gtkcord
	mkdir -p $(BUILD_DIST)/gtkcord/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)

	# gtkcord.mk Prep gtkcord
	cp -a $(BUILD_STAGE)/gtkcord/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/{bin,share} $(BUILD_DIST)/gtkcord/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)

	# gtkcord.mk Sign
	$(call SIGN,gtkcord,general.xml)

	# gtkcord.mk Make .debs
	$(call PACK,gtkcord,DEB_GTKCORD_V)

	# gtkcord.mk Build cleanup
	rm -rf $(BUILD_DIST)/gtkcord

.PHONY: gtkcord gtkcord-package
