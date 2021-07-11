ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += gnome-session
GNOME-SESSION_VERSION := 40.0
DEB_GNOME-SESSION_V   ?= $(GNOME-SESSION_VERSION)

gnome-session-setup: setup
	wget -q -nc -P$(BUILD_SOURCE) https://download.gnome.org/sources/gnome-session/40/gnome-session-40.0.tar.xz
	$(call EXTRACT_TAR,gnome-session-$(GNOME-SESSION_VERSION).tar.xz,gnome-session-$(GNOME-SESSION_VERSION),gnome-session)
	mkdir -p $(BUILD_WORK)/gnome-session/build
	echo -e "[host_machine]\n \
	system = 'darwin'\n \
	cpu_family = '$(shell echo $(GNU_HOST_TRIPLE) | cut -d- -f1)'\n \
	cpu = '$(MEMO_ARCH)'\n \
	endian = 'little'\n \
	[properties]\n \
	root = '$(BUILD_BASE)'\n \
	sys_root = '$(BUILD_BASE)'\n \
	objcpp_args = ['-arch', 'arm64']\n \
	objcpp_link_args = ['-arch', 'arm64']\n \
	[paths]\n \
	prefix ='$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)'\n \
	sysconfdir='$(MEMO_PREFIX)/etc'\n \
	localstatedir='$(MEMO_PREFIX)/var'\n \
	[binaries]\n \
	c = '$(CC)'\n \
	cpp = '$(CXX)'\n" > $(BUILD_WORK)/gnome-session/build/cross.txt

ifneq ($(wildcard $(BUILD_WORK)/gnome-session/.build_complete),)
gnome-session:
	@echo "Using previously built gnome-session."
else
gnome-session: gnome-session-setup
	cd $(BUILD_WORK)/gnome-session/build && PKG_CONFIG="pkg-config" meson \
		--cross-file cross.txt \
		-Dsystemd=false \
		-Ddocbook=false \
		-Dsystemd_session=disable \
		-Dsystemd_journal=false \
		-Dman=false \
		..
	ninja -C $(BUILD_WORK)/gnome-session/build
	+DESTDIR="$(BUILD_STAGE)/gnome-session" ninja -C $(BUILD_WORK)/gnome-session/build install
	+DESTDIR="$(BUILD_BASE)" ninja -C $(BUILD_WORK)/gnome-session/build install
	touch $(BUILD_WORK)/gnome-session/.build_complete
endif

gnome-session-package: gnome-session-stage
	# gtk+.mk Package Structure
	rm -rf $(BUILD_DIST)/gnome-session

	# gtk+.mk Prep gnome-session
	cp -a $(BUILD_STAGE)/gnome-session $(BUILD_DIST)

	# gtk+.mk Sign
	$(call SIGN,gnome-session,general.xml)

	# gtk+.mk Make .debs
	$(call PACK,gnome-session,DEB_GNOME-SESSION_V)

	# gtk+.mk Build cleanup
	rm -rf $(BUILD_DIST)/gnome-session

.PHONY: gnome-session gnome-session-package
