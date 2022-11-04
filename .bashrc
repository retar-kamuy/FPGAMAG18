export SYSTEMC_HOME=/usr/local/systemc-2.3.2
export SYSTEMC_INCLUDE=$SYSTEMC_HOME/include
export SYSTEMC_LIBDIR=$SYSTEMC_HOME/lib-linux64

export LD_LIBRARY_PATH=$SYSTEMC_LIBDIR:$LD_LIBRARY_PATH

export MTI_HOME=/opt/intelFPGA/22.2/questa_fse

export VERILATOR_HOME=/usr/share/verilator
export VERILATOR_SRC=$VERILATOR_HOME/include

export RISCV_HOME=/opt/rv32im

export PATH=$MTI_HOME/bin:$RISCV_HOME/bin:$PATH
