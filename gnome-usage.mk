ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += gnome-usage
GNOME-USAGE_VERSION := 3.38.1
DEB_GNOME-USAGE_V   ?= $(GNOME-USAGE_VERSION)

gnome-usage-setup: setup
	wget -q -nc -P$(BUILD_SOURCE) https://download.gnome.org/sources/gnome-usage/3.38/gnome-usage-3.38.1.tar.xz
	$(call EXTRACT_TAR,gnome-usage-$(GNOME-USAGE_VERSION).tar.xz,gnome-usage-$(GNOME-USAGE_VERSION),gnome-usage)
	mkdir -p $(BUILD_WORK)/gnome-usage/build
	echo -e "[host_machine]\n \
	system = 'darwin'\n \
	cpu_family = '$(shell echo $(GNU_HOST_TRIPLE) | cut -d- -f1)'\n \
	cpu = '$(MEMO_ARCH)'\n \
	endian = 'little'\n \
	[properties]\n \
	root = '$(BUILD_BASE)'\n \
	[paths]\n \
	prefix ='$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)'\n \
	sysconfdir='$(MEMO_PREFIX)/etc'\n \
	localstatedir='$(MEMO_PREFIX)/var'\n \
	[binaries]\n \
	c = '$(CC)'\n \
	cpp = '$(CXX)'\n" > $(BUILD_WORK)/gnome-usage/build/cross.txt

ifneq ($(wildcard $(BUILD_WORK)/gnome-usage/.build_complete),)
gnome-usage:
	@echo "Using previously built gnome-usage."
else
gnome-usage: gnome-usage-setup
	cd $(BUILD_WORK)/gnome-usage/build && PKG_CONFIG="pkg-config" meson \
		--cross-file cross.txt \
		..
	ninja -C $(BUILD_WORK)/gnome-usage/build
	+DESTDIR="$(BUILD_STAGE)/gnome-usage" ninja -C $(BUILD_WORK)/gnome-usage/build install
	+DESTDIR="$(BUILD_BASE)" ninja -C $(BUILD_WORK)/gnome-usage/build install
	touch $(BUILD_WORK)/gnome-usage/.build_complete
endif

gnome-usage-package: gnome-usage-stage
	rm -rf $(BUILD_DIST)/gnome-usage{0,-dev}
	mkdir -p $(BUILD_DIST)/gnome-usage{0,-dev}/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	#gnome-usage.mk Prep libepxoy0
	cp -a $(BUILD_STAGE)/gnome-usage/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/gnome-usage.0.dylib $(BUILD_DIST)/GNOME-USAGE0/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# gnome-usage.mk Prep gnome-usage-dev
	cp -a $(BUILD_STAGE)/gnome-usage/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/!(gnome-usage.0.dylib) $(BUILD_DIST)/gnome-usage-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib
	cp -a $(BUILD_STAGE)/gnome-usage/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include $(BUILD_DIST)/gnome-usage-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)

	# gnome-usage.mk Sign
	$(call SIGN,GNOME-USAGE0,general.xml)

	# gnome-usage.mk Make .debs
	$(call PACK,GNOME-USAGE0,DEB_GNOME-USAGE_V)
	$(call PACK,gnome-usage-dev,DEB_GNOME-USAGE_V)

	# gnome-usage.mk Build cleanup
	rm -rf $(BUILD_DIST)/gnome-usage{0,-dev}

.PHONY: gnome-usage gnome-usage-package
