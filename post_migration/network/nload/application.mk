# Awkward. We have to have device specific code here because there's a single makefiles/custom-atari.mk which is used for ALL projects, but
# we need project atari includes here

ifeq ($(CURRENT_TARGET),atari)
# LDFLAGS += -Wl -D,__RESERVED_MEMORY__=0x0001
LDFLAGS += --start-addr 0x3000 -D,__RESERVED_MEMORY__=0x0001 -C src/atari/custom-atari.cfg
APPEND_TARGET := 0
endif
