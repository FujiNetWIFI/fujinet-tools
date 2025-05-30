###################################################################
# Apple
###################################################################
ifeq ($(DEBUG),true)
    $(info >>>Starting custom-apple2.mk)
endif

#################################################################
# COMPILE FLAGS

#################################################################
# DISK creation

SUFFIX =
DISK_TASKS += .po
AUTOBOOT := -l
APPLE_TOOLS_DIR := ../../platform-tools/apple

.po:
	$(call RMFILES,$(DIST_DIR)/$(PROGRAM_TGT).po)
	$(call RMFILES,$(DIST_DIR)/$(PROGRAM))

# $(PROGRAM) is the name of the app (like weather) - we'll use that name to add with add-file.sh
# $(PROGRAM_TGT) is the name of the current target build (apple2 / apple2enh)
# if the program name is too large it won't autostart!

	$(APPLE_TOOLS_DIR)/mk-bitsy.sh $(DIST_DIR)/$(PROGRAM_TGT).po $(PROGRAM_TGT)$(SUFFIX)
	$(APPLE_TOOLS_DIR)/add-file.sh $(AUTOBOOT) $(DIST_DIR)/$(PROGRAM_TGT).po $(DIST_DIR)/$(PROGRAM_TGT)$(SUFFIX) $(PROGRAM)


# Applewin debug script
.gendebug: $(PROGRAM_TGT)
	@if [ -f "$(BUILD_DIR)/$(PROGRAM_TGT).lbl" ]; then \
		echo "Generating debug.scr script for AppleWin"; \
		echo 'echo "Loading symbols"' > $(BUILD_DIR)/debug.scr; \
		awk '{printf("sym %s = %s\n", substr($$3, 2), $$2)}' < $(BUILD_DIR)/$(PROGRAM_TGT).lbl >> $(BUILD_DIR)/debug.scr; \
		echo 'bpx _main' >> $(BUILD_DIR)/debug.scr; \
		echo 'bpx _debug' >> $(BUILD_DIR)/debug.scr; \
		echo 'bpx _network_open' >> $(BUILD_DIR)/debug.scr; \
		echo 'bpx _sp_init' >> $(BUILD_DIR)/debug.scr; \
	fi

ALL_TASKS += .gendebug

################################################################
# TESTING / EMULATOR
