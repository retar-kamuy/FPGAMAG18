# Variables: Defaults
#
TOP			= tb_fmrv32im_core
SRC_DIR		= ./modules ./modules/fmrv32im_v1/src

# Variables: Verilog
#
SRCS		= $(foreach src,$(SRC_DIR),$(wildcard $(src)/*.v)) \
				fmrv32im_core.sv \
				./modules/axilm_v1/src/fmrv32im_axilm.v \
				./modules/axim_v1/src/fmrv32im_axim.v \
				./modules/cache_v1/src/fmrv32im_cache.v \
				./modules/dbussel_v1/src/fmrv32im_dbussel.v \
				./modules/plic_v1/src/fmrv32im_plic.v \
				./modules/timer_v1/src/fmrv32im_timer.v \

TESTS		= ./src/tb_fmrv32im_core.v ./src/tb_axil_slave_model.v ./src/tb_axi_slave_model.v

VFLAGS		=
VOPT_FLAGS	= +acc
#-debug,cell vopt -access=rw+/. -cellaccess=rw+/.
TRANSCRIPT	= "add wave -r /*; run -all; quit"

# Variables: Lists of objects, source and deps
#
BUILD_DIR	= build
OPT_DESIGN	= optdesign
WLF			= vsim.wlf

# Rules
#
all: run
build: $(BUILD_DIR)/$(OPT_DESIGN)

$(BUILD_DIR):
	vlib $(BUILD_DIR)
	vmap $(BUILD_DIR) $(BUILD_DIR)

$(BUILD_DIR)/$(OPT_DESIGN) : $(SRCS) $(TESTS)
	vlog $(VFLAGS) $^ -work $(BUILD_DIR)
	vopt $(VOPT_FLAGS) $(TOP) -work $(BUILD_DIR) -o $(OPT_DESIGN)

run: $(BUILD_DIR)/$(OPT_DESIGN)
	vsim $(BUILD_DIR).$(OPT_DESIGN) -c -wlf $(WLF) -do $(TRANSCRIPT) -l vsim.log

clean:
	rm -rf $(BUILD_DIR) vsim.log $(WLF) modelsim.ini
