cmake_minimum_required(VERSION 3.14)

project(fmrv32im_core)

# set(CMAKE_CC_COMPILER "/usr/bin/clang")
# set(CMAKE_CXX_COMPILER "/usr/bin/clang++")

set(target Vtb_top)

find_package(verilator HINTS $ENV{VERILATOR_ROOT})

add_executable(${target} sc_main.cpp)

include_directories(/opt/googletest-1.13.0/include)

set(dut 
    ./tb_top.sv
    ./env/tb_axi_slave_model.v
    ./src/fmrv32im_core.sv
    ./src/axilm_v1/src/fmrv32im_axilm.v
    ./src/axim_v1/src/fmrv32im_axim.v
    ./src/cache_v1/src/fmrv32im_cache.sv
    ./src/dbussel_v1/src/fmrv32im_dbussel.v
    ./src/fmrv32im_v1/src/fmrv32im.v
    ./src/fmrv32im_v1/src/fmrv32im_alu.v
    ./src/fmrv32im_v1/src/fmrv32im_csr.v
    ./src/fmrv32im_v1/src/fmrv32im_decode.v
    ./src/fmrv32im_v1/src/fmrv32im_div.sv
    ./src/fmrv32im_v1/src/fmrv32im_mul.v
    ./src/fmrv32im_v1/src/fmrv32im_reg.v
    ./src/plic_v1/src/fmrv32im_plic.v
    ./src/timer_v1/src/fmrv32im_timer.v
    ./src/uart_v1/src/fmrv32im_axis_uart.v  
)

set(VERILATOR_ARGS CACHE STRING "")

verilate(${target}
    SYSTEMC
    SOURCES ${dut}
    VERILATOR_ARGS --Wno-lint ${VERILATOR_ARGS} --timing -LDFLAGS "-L/opt/googletest-1.13.0/lib -lgtest -lpthread"
)

verilator_link_systemc(${target})

# CTest
include(GoogleTest)
gtest_discover_tests(${target})
