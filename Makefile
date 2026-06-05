# Build system for the factory CPU32 (MC68331) firmware image.
#
# Each build configuration sets a `type` value and an `nvram size`, which are
# injected into main.s at assemble time via `as --defsym`.
#
# Usage:
#   make            # build the default config
#   make default    # build a single named config
#   make all        # build every config
#   make list       # show available configs and their values
#   make clean      # remove build artifacts
#
# Add a new config by appending its name to CONFIGS and defining
# <name>_TYPE and <name>_NVRAM below.

AS      := m68k-linux-gnu-as
OBJCOPY := m68k-linux-gnu-objcopy
ASFLAGS := -mcpu=cpu32

SRC     := main.s
HDRSKIP := 4096                 # bytes of header stripped from the raw image

# -- Build configurations ----------------------------------------------------
# name        type            nvram size
CONFIGS := default small large

default_TYPE  := 0x31415926
default_NVRAM := 0x80000

small_TYPE    := 0x31415926
small_NVRAM   := 0x40000

large_TYPE    := 0x31415926
large_NVRAM   := 0x100000
# ----------------------------------------------------------------------------

DEFAULT_CONFIG := default
BINS := $(foreach c,$(CONFIGS),factory_$(c).bin)

.PHONY: all clean list $(CONFIGS)

# Bare `make` builds the default config and exposes it as factory.bin.
factory.bin: factory_$(DEFAULT_CONFIG).bin
	cp $< $@

all: $(BINS)

# Named target per config, e.g. `make small` -> factory_small.bin
$(CONFIGS): %: factory_%.bin

# Pattern rule: assemble + extract the binary for any config.
factory_%.bin: $(SRC)
	@echo "Building config '$*': TYPE=$($*_TYPE) NVRAM_SIZE=$($*_NVRAM)"
	$(AS) $(ASFLAGS) --defsym TYPE=$($*_TYPE) --defsym NVRAM_SIZE=$($*_NVRAM) $(SRC) -o factory_$*.o
	$(OBJCOPY) -O binary factory_$*.o factory_$*_raw.bin
	dd if=factory_$*_raw.bin of=$@ bs=1 skip=$(HDRSKIP)
	rm -f factory_$*.o factory_$*_raw.bin

list:
	@echo "Available configs:"
	@$(foreach c,$(CONFIGS),printf '  %-10s TYPE=%s  NVRAM_SIZE=%s\n' '$(c)' '$($(c)_TYPE)' '$($(c)_NVRAM)';)

clean:
	rm -f factory.bin $(BINS) factory_*.o factory_*_raw.bin
