# Whereas TARGETS are normally atari, c64, etc, we will use the mechanism for all apps instead.
TARGETS := fcd \
	fconfig fcopy feject fesclk fhost finfo fld flh fls fmall \
	fmount fnet fnew freset fscan ncd ncopy ndel ndir nlogin \
	nmkdir npwd nren nrmdir ntrans rautoans rbaudlok rlisten rsniff \
	flobby 

# Name of the final, single-file executable. This will be set to currently building target
PROGRAM := 

# Path(s) to additional libraries required for linking the program
# Use only if you don't want to place copies of the libraries in SRCDIR
# Default: none
LIBS	:= 

# Custom linker configuration file
# Use only if you don't want to place it in SRCDIR
# Default: none
CONFIG  :=

# Additional C compiler flags and options.
# Default: none
CFLAGS  = -Os

# Additional assembler flags and options.
# Default: none
ASFLAGS =

# Additional linker flags and options.
# Default: none
LDFLAGS = $(LDFLAGS.$(TARGETLIST))
LDFLAGS.atari = --mapfile $(TARGETLIST).map

# Path to the directory containing C and ASM sources.
# Default: src
SRCDIR :=

# Path to the directory where object files are to be stored (inside respective target subdirectories).
# Default: obj
OBJDIR :=

# Command used to run the emulator.
# Default: depending on target platform. For default (c64) target: x64 -kernal kernal -VICIIdsize -autoload
EMUCMD :=

# Build dir for putting final built program rather than cluttering root
BUILD_DIR = build

# Optional commands used before starting the emulation process, and after finishing it.
# Default: none
#PREEMUCMD := osascript -e "tell application \"System Events\" to set isRunning to (name of processes) contains \"X11.bin\"" -e "if isRunning is true then tell application \"X11\" to activate"
#PREEMUCMD := osascript -e "tell application \"X11\" to activate"
#POSTEMUCMD := osascript -e "tell application \"System Events\" to tell process \"X11\" to set visible to false"
#POSTEMUCMD := osascript -e "tell application \"Terminal\" to activate"
PREEMUCMD :=
POSTEMUCMD :=

# On Windows machines VICE emulators may not be available in the PATH by default.
# In such case, please set the variable below to point to directory containing
# VICE emulators. 
#VICE_HOME := "C:\Program Files\WinVICE-2.2-x86\"
VICE_HOME :=

# Options state file name. You should not need to change this, but for those
# rare cases when you feel you really need to name it differently - here you are
STATEFILE := Makefile.options

###################################################################################
####  DO NOT EDIT BELOW THIS LINE, UNLESS YOU REALLY KNOW WHAT YOU ARE DOING!  ####
###################################################################################

###################################################################################
### Mapping abstract options to the actual compiler, assembler and linker flags ###
### Predefined compiler, assembler and linker flags, used with abstract options ###
### valid for 2.14.x. Consult the documentation of your cc65 version before use ###
###################################################################################

# Compiler flags used to tell the compiler to optimise for SPEED
define _optspeed_
 CFLAGS += -Oris
endef

# Compiler flags used to tell the compiler to optimise for SIZE
define _optsize_
 CFLAGS += -Or
endef

# Compiler and assembler flags for generating listings
define _listing_
 CFLAGS += --listing $(subst obj,build,$$(@:.o=.lst))
 ASFLAGS += --listing $(subst obj,build,$$(@:.o=.lst))
 # how do we do this?
 REMOVES += $(addsuffix .lst,$(basename $(OBJECTS)))
endef

# Linker flags for generating map file
define _mapfile_
 LDFLAGS += --mapfile $(BUILD_DIR)/$$@.map
 REMOVES += $(BUILD_DIR)/$(PROGRAM).map
endef

# Linker flags for generating VICE label file
define _labelfile_
 LDFLAGS += -Ln $(BUILD_DIR)/$$@.lbl
 REMOVES += $(BUILD_DIR)/$(PROGRAM).lbl
endef

# Linker flags for generating a debug file
define _debugfile_
 LDFLAGS += -Wl --dbgfile,$(BUILD_DIR)/$$@.dbg
 REMOVES += $(BUILD_DIR)/$(PROGRAM).dbg
endef

###############################################################################
###  Defaults to be used if nothing defined in the editable sections above  ###
###############################################################################

# Presume the C64 target like the cl65 compile & link utility does.
# Set TARGETS to override.
ifeq ($(TARGETS),)
 TARGETS := c64
endif

# Presume we're in a project directory so name the program like the current
# directory. Set PROGRAM to override.
ifeq ($(PROGRAM),)
 PROGRAM := $(notdir $(CURDIR))
endif

# Presume the C and asm source files to be located in the subdirectory 'src'.
# Set SRCDIR to override.
ifeq ($(SRCDIR),)
 SRCDIR := src
endif

# Presume the object and dependency files to be located in the subdirectory
# 'obj' (which will be created). Set OBJDIR to override.
ifeq ($(OBJDIR),)
 OBJDIR := obj
endif
TARGETOBJDIR := $(OBJDIR)/$(TARGETS)

# On Windows it is mandatory to have CC65_HOME set. So do not unnecessarily
# rely on cl65 being added to the PATH in this scenario.
ifdef CC65_HOME
 CC := $(CC65_HOME)/bin/cl65
else
 CC := cl65
endif

# Default emulator commands and options for particular targets.
# Set EMUCMD to override.
c64_EMUCMD := $(VICE_HOME)xscpu64 -VICIIdsize -autostart 
c128_EMUCMD := $(VICE_HOME)x128 -kernal kernal -VICIIdsize -autoload
vic20_EMUCMD := $(VICE_HOME)xvic -kernal kernal -VICdsize -autoload
pet_EMUCMD := $(VICE_HOME)xpet -Crtcdsize -autoload
plus4_EMUCMD := $(VICE_HOME)xplus4 -TEDdsize -autoload
# So far there is no x16 emulator in VICE (why??) so we have to use xplus4 with -memsize option
c16_EMUCMD := $(VICE_HOME)xplus4 -ramsize 16 -TEDdsize -autoload
cbm510_EMUCMD := $(VICE_HOME)xcbm2 -model 510 -VICIIdsize -autoload
cbm610_EMUCMD := $(VICE_HOME)xcbm2 -model 610 -Crtcdsize -autoload
#atari_EMUCMD := atari800 -windowed -xl -pal -nopatchall -run

ifeq '$(findstring ;,$(PATH))' ';'
    detected_OS := Windows
else
    detected_OS := $(shell uname 2>/dev/null || echo Unknown)
    detected_OS := $(patsubst CYGWIN%,Cygwin,$(detected_OS))
    detected_OS := $(patsubst MSYS%,MSYS,$(detected_OS))
    detected_OS := $(patsubst MINGW%,MSYS,$(detected_OS))
endif

XS := ""
ifeq ($(detected_OS),$(filter $(detected_OS),MSYS MINGW))
# need an eXtra Slash for altirra things
	XS := /
endif

ALTIRRA ?= $(ALTIRRA_HOME)/Altirra64.exe \
  $(XS)/portable $(XS)/portablealt:altirra-debug.ini \
  $(XS)/debug \
  $(XS)/debugcmd: ".loadsym build\$(TARGETLIST).lbl" \
  $(XS)/debugcmd: "bp debug" \

  # $(XS)/debugcmd: "bp pre_init" \
  # $(XS)/debugcmd: "bp start"

atari_EMUCMD := $(ALTIRRA)

ifeq ($(EMUCMD),)
  EMUCMD = $($(CC65TARGET)_EMUCMD)
endif

###############################################################################
### The magic begins                                                        ###
###############################################################################

# The "Native Win32" GNU Make contains quite some workarounds to get along with
# cmd.exe as shell. However it does not provide means to determine that it does
# actually activate those workarounds. Especially does $(SHELL) NOT contain the
# value 'cmd.exe'. So the usual way to determine if cmd.exe is being used is to
# execute the command 'echo' without any parameters. Only cmd.exe will return a
# non-empy string - saying 'ECHO is on/off'.
#
# Many "Native Win32" prorams accept '/' as directory delimiter just fine. How-
# ever the internal commands of cmd.exe generally require '\' to be used.
#
# cmd.exe has an internal command 'mkdir' that doesn't understand nor require a
# '-p' to create parent directories as needed.
#
# cmd.exe has an internal command 'del' that reports a syntax error if executed
# without any file so make sure to call it only if there's an actual argument.
ifeq ($(shell echo),)
 MKDIR = mkdir -p $1
 RMDIR = rmdir $1
 RMFILES = $(RM) $1
else
 MKDIR = mkdir $(subst /,\,$1)
 RMDIR = rmdir $(subst /,\,$1)
 RMFILES = $(if $1,del /f $(subst /,\,$1))
endif
COMMA := ,
SPACE := $(N/A) $(N/A)
define NEWLINE


endef
# Note: Do not remove any of the two empty lines above !

TARGETLIST := $(subst $(COMMA),$(SPACE),$(TARGETS))

ifeq ($(words $(TARGETLIST)),1)

# Set PROGRAM to something like 'myprog.c64'.
override PROGRAM := $(TARGETLIST).com

# Set SOURCES to something like '<prog>/src/foo.c <prog>/src/bar.s'.
# Use of assembler files with names ending differently than .s is deprecated!
SOURCES := $(wildcard $(TARGETLIST)/$(SRCDIR)/*.c)
SOURCES += $(wildcard $(TARGETLIST)/$(SRCDIR)/*.s)

# Set OBJECTS
OBJ1 := $(SOURCES:.c=.o)
OBJECTS := $(OBJ1:.s=.o)
# change from prog/src/ -> obj/prog/
OBJECTS := $(OBJECTS:$(TARGETLIST)/$(SRCDIR)/%=$(OBJDIR)/$(TARGETLIST)/%)

# Set DEPENDS to something like 'obj/prog/foo.d obj/prog/bar.d'.
DEPENDS := $(OBJECTS:.o=.d)

# Add to LIBS something like 'src/foo.lib src/c64/bar.lib'.
LIBS += $(wildcard $(TARGETLIST)/$(SRCDIR)/*.lib)
LIBS += $(wildcard $(TARGETLIST)/$(SRCDIR)/$(TARGETLIST)/*.lib)
# add the common libs last
LIBS += $(wildcard libs/*.lib)

# Add to CONFIG
# allow program specific cfg file to override default
CONFIG += $(wildcard $(TARGETLIST)/$(SRCDIR)/*.cfg)
CONFIG += cfg/atari.cfg

# Select CONFIG file to use. Target specific configs have higher priority.
ifneq ($(word 2,$(CONFIG)),)
 CONFIG := $(firstword $(CONFIG))
 $(info Using config file $(CONFIG) for linking)
endif

ASFLAGS += --asm-include-dir include
CFLAGS += --include-dir include

.SUFFIXES:
.PHONY: all test clean zap

all: $(PROGRAM)

-include $(DEPENDS)
-include $(STATEFILE)

# If OPTIONS are given on the command line then save them to STATEFILE
# if (and only if) they have actually changed. But if OPTIONS are not
# given on the command line then load them from STATEFILE. Have object
# files depend on STATEFILE only if it actually exists.
ifeq ($(origin OPTIONS),command line)
 ifneq ($(OPTIONS),$(_OPTIONS_))
   ifeq ($(OPTIONS),)
     $(info Removing OPTIONS)
     $(shell $(RM) $(STATEFILE))
     $(eval $(STATEFILE):)
   else
     $(info Saving OPTIONS=$(OPTIONS))
     $(shell echo _OPTIONS_=$(OPTIONS) > $(STATEFILE))
   endif
   $(eval $(OBJECTS): $(STATEFILE))
 endif
else
 ifeq ($(origin _OPTIONS_),file)
   $(info Using saved OPTIONS=$(_OPTIONS_))
   OPTIONS = $(_OPTIONS_)
   $(eval $(OBJECTS): $(STATEFILE))
 endif
endif

# Transform the abstract OPTIONS to the actual cc65 options.
$(foreach o,$(subst $(COMMA),$(SPACE),$(OPTIONS)),$(eval $(_$o_)))

CC65TARGET := atari

# The remaining targets.
$(TARGETOBJDIR):
	$(call MKDIR,$@)

$(BUILD_DIR):
	$(call MKDIR,$@)

SRC_INC_DIRS := \
 $(sort $(dir $(wildcard $(TARGETLIST)/$(SRCDIR)/*)))

# $(info $$SOURCES = ${SOURCES})
# $(info $$OBJECTS = ${OBJECTS})
# $(info $$SRC_INC_DIRS = ${SRC_INC_DIRS})
# $(info $$ASFLAGS = ${ASFLAGS})
# $(info $$TARGETOBJDIR = ${TARGETOBJDIR})
# $(info $$TARGETLIST = ${TARGETLIST})

vpath %.c $(SRC_INC_DIRS)

$(TARGETOBJDIR)/%.o: %.c | $(TARGETOBJDIR) $(BUILD_DIR)
	$(CC) -t $(CC65TARGET) -c --create-dep $(@:.o=.d) $(CFLAGS) -o $@ $<

vpath %.s $(SRC_INC_DIRS)

$(TARGETOBJDIR)/%.o: %.s | $(TARGETOBJDIR) $(BUILD_DIR)
	$(CC) -t $(CC65TARGET) -Wa -DDYN_DRV=0 -c --create-dep $(@:.o=.d) $(ASFLAGS) -o $@ $<

$(PROGRAM): $(CONFIG) $(OBJECTS) $(LIBS) | $(BUILD_DIR)
	$(CC) -t $(CC65TARGET) $(LDFLAGS) -o $(BUILD_DIR)/$@ $(patsubst %.cfg,-C %.cfg,$^)

test: $(PROGRAM)
	$(PREEMUCMD)
	$(EMUCMD) $(BUILD_DIR)\\$<
	$(POSTEMUCMD)

clean:
	$(call RMFILES,$(OBJECTS))
	$(call RMFILES,$(DEPENDS))
	$(call RMFILES,$(REMOVES))
	$(call RMFILES,$(PROGRAM))
	$(call RMFILES,dist/$(PROGRAM))

else # $(words $(TARGETLIST)),1

all test clean:
	$(foreach t,$(TARGETLIST),$(MAKE) --no-print-directory TARGETS=$t $@$(NEWLINE))

endif # $(words $(TARGETLIST)),1

OBJDIRLIST := $(wildcard $(OBJDIR)/*)

zap:
	$(foreach o,$(OBJDIRLIST),-$(call RMFILES,$o/*.o $o/*.d $o/*.lst)$(NEWLINE))
	$(foreach o,$(OBJDIRLIST),-$(call RMDIR,$o)$(NEWLINE))
	-$(call RMDIR,$(OBJDIR))
	-$(call RMFILES,$(BUILD_DIR)/*.com)
	-$(call RMFILES,$(BUILD_DIR)/*.com.*)

TOOLFILES := $(foreach tool,$(TARGETS),$(BUILD_DIR)/$(tool).com)

dist: $(TOOLFILES)
	mkdir -p dist
	mkdir -p dist-doc
	cp $^ dist/
	cp doc/* dist-doc/
	dir2atr 720 fnc-tools.atr dist/
	dir2atr 720 fnc-tools-doc.atr dist-doc/

$(BUILD_DIR)/%.com:
	$(info Making $@ ($(@:.com=)))
	$(MAKE) --no-print-directory TARGETS=$(basename $(@:.com=)) clean all

###################################################################
###  Place your additional targets in the additional Makefiles  ###
### in the same directory - their names have to end with ".mk"! ###
###################################################################
-include *.mk
