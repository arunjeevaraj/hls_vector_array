# *******************************************************************************
# Author: Arun Jeevaraj
# Associated Filename: run_hls.tcl
# Purpose: Tcl commands to setup a Vivado HLS prject
# Device: Xilinx FPGA devices.
# Revision History: 2017 initial version.
# Copyright: All rights reserved.
##############################################
####Project settings
# Create a project
open_project	-reset matrix_dut_prj
# The source file and test bench
add_files	  dut.cpp
add_files -tb dut_test.cpp
add_files -tb Beam_init.bin
add_files -tb Beam_end.bin
add_files -tb R_drift.bin
add_files -tb R_qfdef.bin
add_files -tb R_qffoc.bin
# Specify the top-level function for synthesis
set_top	 dut

####Solution settings.
# OpenC a solution.
open_solution -reset "post_opt"
#set fPGA part
set_part {xc7a100tcsg324-1}
create_clock -period 8 -name default
set_clock_uncertainty 1.25
#Add optimization directives
source "./directives.tcl"


####Test and verify, Export.
# simulate
csim_design -compiler gcc
#synthesis
csynth_design
#RTL-C co sythesis
cosim_design -trace_level all
#export RTL
export_design -rtl verilog -format ip_catalog
# Exit the Vivado Instance.
exit
