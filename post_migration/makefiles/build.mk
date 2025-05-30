# Generic Build script
#

ifeq ($(DEBUG),true)
    $(info >Starting build.mk)
endif


# Ensure WSL2 Ubuntu and other linuxes use bash by default instead of /bin/sh, which does not always like the shell commands.
SHELL := /usr/bin/env bash
ALL_TASKS =
DISK_TASKS =

# try and load some target mappings for all platforms
-include ../../makefiles/os.mk

CC := cl65

SRCDIR := src
BUILD_DIR := build
OBJDIR := obj
DIST_DIR := dist
CACHE_DIR := ../../_cache

# This causes the output file to have the TARGET in the name, e.g. foo.atari.com
# Set to 0 for "foo.com" instead, but note this will fail for devices that have multiple targets like apple2 and apple2enh that would share same name and overwrite each other.
APPEND_TARGET := 1

# This allows src to be nested withing sub-directories.
rwildcard=$(wildcard $(1)$(2))$(foreach d,$(wildcard $1*), $(call rwildcard,$d/,$2))

PROGRAM_TGT := $(PROGRAM).$(CURRENT_TARGET)

SOURCES := $(wildcard $(SRCDIR)/*.c)
SOURCES += $(wildcard $(SRCDIR)/*.s)

# allow for a src/common/ dir and recursive subdirs
SOURCES += $(call rwildcard,$(SRCDIR)/common/,*.s)
SOURCES += $(call rwildcard,$(SRCDIR)/common/,*.c)

# allow src/<platform>/ and its recursive subdirs
SOURCES_PF := $(call rwildcard,$(SRCDIR)/$(CURRENT_PLATFORM)/,*.s)
SOURCES_PF += $(call rwildcard,$(SRCDIR)/$(CURRENT_PLATFORM)/,*.c)

# allow src/current-target/<target>/ and its recursive subdirs
SOURCES_TG := $(call rwildcard,$(SRCDIR)/current-target/$(CURRENT_TARGET)/,*.s)
SOURCES_TG += $(call rwildcard,$(SRCDIR)/current-target/$(CURRENT_TARGET)/,*.c)

# remove trailing and leading spaces.
SOURCES := $(strip $(SOURCES))
SOURCES_PF := $(strip $(SOURCES_PF))
SOURCES_TG := $(strip $(SOURCES_TG))

# convert from src/your/long/path/foo.[c|s] to obj/<target>/your/long/path/foo.o
# we need the target because compiling for previous target does not pick up potential macro changes
OBJ1 := $(SOURCES:.c=.o)
OBJECTS := $(OBJ1:.s=.o)
OBJECTS := $(OBJECTS:$(SRCDIR)/%=$(OBJDIR)/$(CURRENT_TARGET)/%)

OBJ2 := $(SOURCES_PF:.c=.o)
OBJECTS_PF := $(OBJ2:.s=.o)
OBJECTS_PF := $(OBJECTS_PF:$(SRCDIR)/%=$(OBJDIR)/$(CURRENT_TARGET)/%)

OBJ3 := $(SOURCES_TG:.c=.o)
OBJECTS_TG := $(OBJ3:.s=.o)
OBJECTS_TG := $(OBJECTS_TG:$(SRCDIR)/%=$(OBJDIR)/$(CURRENT_TARGET)/%)

OBJECTS += $(OBJECTS_PF)
OBJECTS += $(OBJECTS_TG)

# Ensure make recompiles parts it needs to if src files change
DEPENDS := $(OBJECTS:.o=.d)

ASFLAGS += --asm-include-dir src/common --asm-include-dir src/$(CURRENT_PLATFORM) --asm-include-dir src/current-target/$(CURRENT_TARGET)
CFLAGS += --include-dir src/common --include-dir src/$(CURRENT_PLATFORM) --include-dir src/current-target/$(CURRENT_TARGET)

ASFLAGS += --asm-include-dir $(SRCDIR)
CFLAGS += --include-dir $(SRCDIR)


#
# load the sub-makefiles
#

ifeq ($(DEBUG),true)
    $(info >>load common.mk)
endif

-include ../../makefiles/common.mk


ifeq ($(DEBUG),true)
    $(info >>load custom-$(CURRENT_PLATFORM).mk)
endif

-include ../../makefiles/custom-$(CURRENT_PLATFORM).mk


ifeq ($(DEBUG),true)
    $(info >>load application.mk)
endif

# allow for application specific config
-include ./application.mk



define _listing_
  CFLAGS += --listing $$(@:.o=.lst)
  ASFLAGS += --listing $$(@:.o=.lst)
endef

define _mapfile_
  LDFLAGS += --mapfile $$@.map
endef

define _labelfile_
  LDFLAGS += -Ln $$@.lbl
endef

.SUFFIXES:
.PHONY: all clean release $(DISK_TASKS) $(BUILD_TASKS) $(PROGRAM_TGT) $(ALL_TASKS)

all: $(ALL_TASKS) $(PROGRAM_TGT)

STATEFILE := Makefile.options
-include $(DEPENDS)
-include $(STATEFILE)

ifeq ($(origin _OPTIONS_),file)
OPTIONS = $(_OPTIONS_)
$(eval $(OBJECTS): $(STATEFILE))
endif

# Transform the abstract OPTIONS to the actual cc65 options.
$(foreach o,$(subst $(COMMA),$(SPACE),$(OPTIONS)),$(eval $(_$o_)))

ifeq ($(BUILD_DIR),)
BUILD_DIR := build
endif

ifeq ($(OBJDIR),)
OBJDIR := obj
endif

ifeq ($(DIST_DIR),)
DIST_DIR := dist
endif

$(OBJDIR):
	$(call MKDIR,$@)

$(BUILD_DIR):
	$(call MKDIR,$@)

$(DIST_DIR):
	$(call MKDIR,$@)

SRC_INC_DIRS := \
  $(sort $(dir $(wildcard $(SRCDIR)/$(CURRENT_TARGET)/*))) \
  $(sort $(dir $(wildcard $(SRCDIR)/common/*))) \
  $(SRCDIR)

vpath %.c $(SRC_INC_DIRS)

$(OBJDIR)/$(CURRENT_TARGET)/%.o: %.c $(VERSION_FILE) | $(OBJDIR)
	@$(call MKDIR,$(dir $@))
	$(CC) -t $(CURRENT_TARGET) -c --create-dep $(@:.o=.d) $(CFLAGS) -o $@ $<

vpath %.s $(SRC_INC_DIRS)

$(OBJDIR)/$(CURRENT_TARGET)/%.o: %.s $(VERSION_FILE) | $(OBJDIR)
	@$(call MKDIR,$(dir $@))
	$(CC) -t $(CURRENT_TARGET) -c --create-dep $(@:.o=.d) $(ASFLAGS) -o $@ $<


$(BUILD_DIR)/$(PROGRAM_TGT): $(OBJECTS) $(LIBS) | $(BUILD_DIR)
	$(CC) -t $(CURRENT_TARGET) $(LDFLAGS) -o $@ $^

$(PROGRAM_TGT): $(BUILD_DIR)/$(PROGRAM_TGT) | $(BUILD_DIR)


ifeq ($(DEBUG),true)
    $(info PROGRAM_TGT is set to: $(PROGRAM_TGT) )
    $(info BUILD_DIR is set to: $(BUILD_DIR) )
    $(info CURRENT_TARGET is set to: $(CURRENT_TARGET) )
    $(info ........................... )
endif


test: $(PROGRAM_TGT)
	$(PREEMUCMD)
	$(EMUCMD) $(BUILD_DIR)/$<
	$(POSTEMUCMD)

# Use "./" in front of all dirs being removed as a simple safety guard to
# ensure deleting from current dir, and not something like root "/".
clean:
	@for d in $(BUILD_DIR) $(OBJDIR) $(DIST_DIR); do \
      if [ -d "./$$d" ]; then \
	    echo "Removing $$d"; \
        rm -rf ./$$d; \
      fi; \
    done

release: all | $(BUILD_DIR) $(DIST_DIR)
ifeq ($(APPEND_TARGET),1)
	cp $(BUILD_DIR)/$(PROGRAM_TGT) $(DIST_DIR)/$(PROGRAM_TGT)$(SUFFIX)
else
	cp $(BUILD_DIR)/$(PROGRAM_TGT) $(DIST_DIR)/$(PROGRAM)$(SUFFIX)
endif

disk: release $(DISK_TASKS)
