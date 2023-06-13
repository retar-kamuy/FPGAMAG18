# TCL File Generated by Component Editor 17.0
# Thu Jun 15 17:22:00 JST 2017
# DO NOT MODIFY


# 
# uart "uart" v1.0
#  2017.06.15.17:22:00
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module uart
# 
set_module_property DESCRIPTION ""
set_module_property NAME uart
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME uart
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL fmrv32im_axis_uart
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file fmrv32im_axis_uart.v VERILOG PATH src/fmrv32im_axis_uart.v {IS_CONFIGURATION_PACKAGE TOP_LEVEL_FILE}


# 
# parameters
# 


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock CLK clk Input 1


# 
# connection point UART
# 
add_interface UART conduit end
set_interface_property UART associatedClock clock
set_interface_property UART associatedReset ""
set_interface_property UART ENABLED true
set_interface_property UART EXPORT_OF ""
set_interface_property UART PORT_NAME_MAP ""
set_interface_property UART CMSIS_SVD_VARIABLES ""
set_interface_property UART SVD_ADDRESS_GROUP ""

add_interface_port UART TXD txd Output 1
add_interface_port UART RXD rxd Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset RST_N reset_n Input 1


# 
# connection point interrupt
# 
add_interface interrupt conduit end
set_interface_property interrupt associatedClock clock
set_interface_property interrupt associatedReset ""
set_interface_property interrupt ENABLED true
set_interface_property interrupt EXPORT_OF ""
set_interface_property interrupt PORT_NAME_MAP ""
set_interface_property interrupt CMSIS_SVD_VARIABLES ""
set_interface_property interrupt SVD_ADDRESS_GROUP ""

add_interface_port interrupt INTERRUPT interrupt Output 1


# 
# connection point gpio
# 
add_interface gpio conduit end
set_interface_property gpio associatedClock clock
set_interface_property gpio associatedReset ""
set_interface_property gpio ENABLED true
set_interface_property gpio EXPORT_OF ""
set_interface_property gpio PORT_NAME_MAP ""
set_interface_property gpio CMSIS_SVD_VARIABLES ""
set_interface_property gpio SVD_ADDRESS_GROUP ""

add_interface_port gpio GPIO_I i Input 32
add_interface_port gpio GPIO_O o Output 32
add_interface_port gpio GPIO_OT ot Output 32


# 
# connection point altera_axi4lite_slave
# 
add_interface altera_axi4lite_slave axi4lite end
set_interface_property altera_axi4lite_slave associatedClock clock
set_interface_property altera_axi4lite_slave associatedReset reset
set_interface_property altera_axi4lite_slave readAcceptanceCapability 1
set_interface_property altera_axi4lite_slave writeAcceptanceCapability 1
set_interface_property altera_axi4lite_slave combinedAcceptanceCapability 1
set_interface_property altera_axi4lite_slave readDataReorderingDepth 1
set_interface_property altera_axi4lite_slave bridgesToMaster ""
set_interface_property altera_axi4lite_slave ENABLED true
set_interface_property altera_axi4lite_slave EXPORT_OF ""
set_interface_property altera_axi4lite_slave PORT_NAME_MAP ""
set_interface_property altera_axi4lite_slave CMSIS_SVD_VARIABLES ""
set_interface_property altera_axi4lite_slave SVD_ADDRESS_GROUP ""

add_interface_port altera_axi4lite_slave S_AXI_AWADDR awaddr Input 16
add_interface_port altera_axi4lite_slave S_AXI_AWPROT awprot Input 3
add_interface_port altera_axi4lite_slave S_AXI_AWVALID awvalid Input 1
add_interface_port altera_axi4lite_slave S_AXI_AWREADY awready Output 1
add_interface_port altera_axi4lite_slave S_AXI_WDATA wdata Input 32
add_interface_port altera_axi4lite_slave S_AXI_WSTRB wstrb Input 4
add_interface_port altera_axi4lite_slave S_AXI_WVALID wvalid Input 1
add_interface_port altera_axi4lite_slave S_AXI_WREADY wready Output 1
add_interface_port altera_axi4lite_slave S_AXI_BVALID bvalid Output 1
add_interface_port altera_axi4lite_slave S_AXI_BREADY bready Input 1
add_interface_port altera_axi4lite_slave S_AXI_BRESP bresp Output 2
add_interface_port altera_axi4lite_slave S_AXI_ARADDR araddr Input 16
add_interface_port altera_axi4lite_slave S_AXI_ARPROT arprot Input 3
add_interface_port altera_axi4lite_slave S_AXI_ARVALID arvalid Input 1
add_interface_port altera_axi4lite_slave S_AXI_ARREADY arready Output 1
add_interface_port altera_axi4lite_slave S_AXI_RDATA rdata Output 32
add_interface_port altera_axi4lite_slave S_AXI_RRESP rresp Output 2
add_interface_port altera_axi4lite_slave S_AXI_RVALID rvalid Output 1
add_interface_port altera_axi4lite_slave S_AXI_RREADY rready Input 1
