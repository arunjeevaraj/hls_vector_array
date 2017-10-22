### connect the microblaze system
startgroup
# interrupt controller.
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Slave "/microblaze_0_axi_intc/s_axi" intc_ip "/microblaze_0_axi_periph" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins microblaze_0/M_AXI_DC]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Slave "/microblaze_0_axi_intc/s_axi" intc_ip "/microblaze_0_axi_periph" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins microblaze_0/M_AXI_IC]
# connect the cache.
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Cached)" intc_ip "Auto" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins mig_7series_0/S_AXI]
# connect the mig module.
apply_bd_automation -rule xilinx.com:bd_rule:board -config {Board_Interface "reset ( Reset ) " }  [get_bd_pins mig_7series_0/sys_rst]
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config {Clk "/clk_wiz_1/clk_out2 (200 MHz)" }  [get_bd_pins mig_7series_0/sys_clk_i]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" intc_ip "/microblaze_0_axi_periph" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins axi_uartlite_0/S_AXI]
# connect the uart module.
apply_bd_automation -rule xilinx.com:bd_rule:board -config {Board_Interface "usb_uart ( USB UART ) " }  [get_bd_intf_pins axi_uartlite_0/UART]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Cached)" intc_ip "Auto" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]
# connect the block ram.
apply_bd_automation -rule xilinx.com:bd_rule:bram_cntlr -config {BRAM "Auto" }  [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA]
apply_bd_automation -rule xilinx.com:bd_rule:bram_cntlr -config {BRAM "Auto" }  [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTB]
apply_bd_automation -rule xilinx.com:bd_rule:board -config {Board_Interface "reset ( Reset ) " }  [get_bd_pins clk_wiz_1/resetn]
# connect the clock in and reset.
apply_bd_automation -rule xilinx.com:bd_rule:board -config {Board_Interface "sys_clock ( System Clock ) " }  [get_bd_pins clk_wiz_1/clk_in1]
apply_bd_automation -rule xilinx.com:bd_rule:board -config {Board_Interface "reset ( Reset ) " }  [get_bd_pins rst_clk_wiz_1_100M/ext_reset_in]
endgroup
# connect the DDR RAM external ports.
startgroup
make_bd_intf_pins_external  [get_bd_intf_pins mig_7series_0/DDR2]
endgroup
# connect the axi timer block
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" intc_ip "/microblaze_0_axi_periph" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins axi_timer_0/S_AXI]

### ADD Design Under Test.
# add an AXI DMA IP.
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0
endgroup
# configure the AXI DMA with simple mode.
startgroup
set_property -dict [list CONFIG.c_include_sg {0} CONFIG.c_sg_include_stscntrl_strm {0}] [get_bd_cells axi_dma_0]
endgroup
startgroup
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" intc_ip "/microblaze_0_axi_periph" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins axi_dma_0/S_AXI_LITE]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Slave "/mig_7series_0/S_AXI" intc_ip "/microblaze_0_axi_periph" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins axi_dma_0/M_AXI_MM2S]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Slave "/mig_7series_0/S_AXI" intc_ip "/microblaze_0_axi_periph" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins axi_dma_0/M_AXI_S2MM]
endgroup

#########
## add the data AXI fifo
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:1.1 axis_data_fifo_0
endgroup
## connect in loopback configuration.
connect_bd_intf_net [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S] [get_bd_intf_pins axis_data_fifo_0/S_AXIS]
connect_bd_intf_net [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM] [get_bd_intf_pins axis_data_fifo_0/M_AXIS]

## connect the reset and clock to the FIFO
connect_bd_net [get_bd_pins axis_data_fifo_0/s_axis_aresetn] [get_bd_pins rst_clk_wiz_1_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axis_data_fifo_0/s_axis_aclk] [get_bd_pins clk_wiz_1/clk_out1]
# connect the interrupt of the DMA.
connect_bd_net [get_bd_pins axi_dma_0/mm2s_introut] [get_bd_pins microblaze_0_xlconcat/In0]
connect_bd_net [get_bd_pins axi_dma_0/s2mm_introut] [get_bd_pins microblaze_0_xlconcat/In1]

set_property  ip_repo_paths  { /home/arun/Desktop/work/design_1.0/mb_dma_hls/hls_mult/vivado_hls/matrix_dut_prj/solution9/impl/ip} [current_project]
update_ip_catalog
#####



##place the ip
#startgroup
#create_bd_cell -type ip -vlnv xilinx.com:hls:dut:1.0 dut_0
#endgroup
##add extra port to the xlconcat
#startgroup
#set_property -dict [list CONFIG.NUM_PORTS {3}] [get_bd_cells microblaze_0_xlconcat]
#endgroup
## connect the interrupt port to the intc controller.
#connect_bd_net [get_bd_pins dut_0/interrupt] [get_bd_pins microblaze_0_xlconcat/In2]
#connect_bd_intf_net [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM] [get_bd_intf_pins dut_0/frame_o]
#connect_bd_intf_net [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S] [get_bd_intf_pins dut_0/frame_i]
## connect the slave axi port.
#apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/microblaze_0 (Periph)" intc_ip "/microblaze_0_axi_periph" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins dut_0/s_axi_AXILiteS]

### regenerate and DRC check.
regenerate_bd_layout
validate_bd_design
save_bd_design

# generate bitstreams and wrap the hdl
#generate_target all [get_files  /home/arun/Desktop/embedded_advanced/embedded_advanced/mb_dma_simple_with_interrupt/mb_dma_simple_with_interrupt.srcs/sources_1/bd/mb_dma_simple_lb/mb_dma_simple_lb.bd]
