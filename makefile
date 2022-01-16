ifndef TOPNAME
$(error TOPNAME should be given)
endif

### Constants...
# Perl executable (from $PERL)
PERL = perl
# Path to Verilator kit (from $VERILATOR_ROOT)
VERILATOR_ROOT = /usr/share/verilator
# SystemC include directory with systemc.h (from $SYSTEMC_INCLUDE)
SYSTEMC_INCLUDE ?= 
# SystemC library directory with libsystemc.a (from $SYSTEMC_LIBDIR)
SYSTEMC_LIBDIR ?= 

### Switches...
# SystemC output mode?  0/1 (from --sc)
VM_SC = 0
# Legacy or SystemC output mode?  0/1 (from --sc)
VM_SP_OR_SC = $(VM_SC)
# Deprecated
VM_PCLI = 1
# Deprecated: SystemC architecture to find link library path (from $SYSTEMC_ARCH)
VM_SC_TARGET_ARCH = linux

### Vars...
# Design prefix (from --prefix)
VM_PREFIX = V$(TOPNAME)
# Module prefix (from --prefix)
VM_MODPREFIX = V$(TOPNAME)
# User CFLAGS (from -CFLAGS on Verilator command line)
VM_USER_CFLAGS = 

# User LDLIBS (from -LDFLAGS on Verilator command line)
VM_USER_LDLIBS = 

# User .cpp files (from .cpp's on Verilator command line)
VM_USER_CLASSES = 

# User .cpp directories (from .cpp's on Verilator command line)
VM_USER_DIR = .

# generated executable file
DST_DIR = build
DST_BIN = $(DST_DIR)/emu_board

# files of nboard
NBD_SRC = src
NBD_LIB = include
NBD_SRCS := $(shell find $(NBD_SRC) -name "*.cpp")
# update.cpp should be implemented by users.
NBD_OBJS := $(addprefix $(DST_DIR)/, $(addsuffix .o, $(basename $(notdir $(NBD_SRCS))))) \
            $(DST_DIR)/update.o

# files of emu
EMU_DIR = emu
EMU_SRCS := $(shell find $(EMU_DIR) -name "*.cpp")
EMU_OBJS := $(addprefix $(DST_DIR)/, $(addsuffix .o, $(basename $(notdir $(EMU_SRCS)))))

SDL_FLAGS = -lSDL2 -lSDL2_image

vpath %.cpp $(EMU_DIR)

### Default rules...
# Include list of all generated classes
include $(EMU_DIR)/V$(TOPNAME)_classes.mk
# Include global rules
include $(VERILATOR_ROOT)/include/verilated.mk

$(DST_BIN): $(NBD_OBJS) $(VK_USER_OBJS) $(VK_GLOBAL_OBJS) $(VM_PREFIX)__ALL.a $(VM_HIER_LIBS)
	@$(LINK) $(LD_FLAGS) $^ $(LOADLIBES) $(LDLIBS) $(LIBS) $(SC_LIBS) -o $@ $(SDL_FLAGS)

$(DST_DIR)/%.o: $(NBD_SRC)/%.cpp
	@mkdir -p $(dir $@)
	@$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST) \
	  -I $(NBD_LIB) -I $(EMU_DIR) -c -o $@ $^

$(DST_DIR)/%.o: $(EMU_DIR)/%.cpp
	@mkdir -p $(dir $@)
	@$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST) \
	  -I $(NBD_LIB) -I $(EMU_DIR) -c -o $@ $^

src/update.cpp: emu/update.cpp
	@ln -sf $(realpath ./$(EMU_DIR)/update.cpp) $(NBD_SRC)/update.cpp

run: $(DST_BIN)
	@$(DST_BIN)

clean:
	@rm -rf $(DST_DIR)

.PHONY: clean run