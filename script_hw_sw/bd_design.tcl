
### make a new project.
#create a project
create_project mb_dma_design_1_0 ./ -part xc7a100tcsg324-1
#set the board property.
set_property board_part digilentinc.com:nexys4_ddr:part0:1.1 [current_project]
#open the block design mb_dma_simple_lb
create_bd_design "mb_dma_simple_lb"

### place the micorblaze HW system
#place microblaze
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:10.0 microblaze_0
endgroup
#place mig memory controller.
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:mig_7series:4.0 mig_7series_0
endgroup
#place the axi uartlite.
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0
endgroup
#place the bram controller.
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 axi_bram_ctrl_0
endgroup
#place the axi timer block.
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer:2.0 axi_timer_0
endgroup


### Configuring the microblaze system.
#Apply the block automation on microblaze
apply_bd_automation -rule xilinx.com:bd_rule:microblaze -config {local_mem "32KB" ecc "None" cache "16KB" debug_module "Debug Only" axi_periph "Enabled" axi_intc "1" clk "New Clocking Wizard (100 MHz)" }  [get_bd_cells microblaze_0]
#Confure the clock wizard. Add second clock source(200 MHz), change the reset to active low.
startgroup
set_property -dict [list CONFIG.CLK_IN1_BOARD_INTERFACE {sys_clock} CONFIG.RESET_BOARD_INTERFACE {reset} CONFIG.CLKOUT2_USED {true} CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {200.000} CONFIG.RESET_TYPE {ACTIVE_LOW} CONFIG.PRIM_SOURCE {Single_ended_clock_capable_pin} CONFIG.MMCM_DIVCLK_DIVIDE {1} CONFIG.MMCM_CLKOUT1_DIVIDE {5} CONFIG.NUM_OUT_CLKS {2} CONFIG.RESET_PORT {resetn} CONFIG.CLKOUT2_JITTER {114.829} CONFIG.CLKOUT2_PHASE_ERROR {98.575}] [get_bd_cells clk_wiz_1]
endgroup
#Apply the block automation on the MIG
apply_bd_automation -rule xilinx.com:bd_rule:mig_7series -config {Board_Interface "ddr2_sdram" }  [get_bd_cells mig_7series_0]

# the bd automation ends with an error and exits the tcl file. The work around now is to run the part_2.tcl file after running this script.
