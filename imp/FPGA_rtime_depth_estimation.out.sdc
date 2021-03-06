## Generated SDC file "FPGA_rtime_depth_estimation.out.sdc"

## Copyright (C) 2018  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 18.0.0 Build 614 04/24/2018 SJ Standard Edition"

## DATE    "Fri Oct 04 21:12:45 2019"

##
## DEVICE  "5CGXFC9D6F27C7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************
create_clock -period 20.000 [get_ports CLOCK_50_B3B]
create_clock -period 20.000 [get_ports CLOCK_50_B4A]
create_clock -period 20.000 [get_ports CLOCK_50_B5B]
create_clock -period 20.000 [get_ports CLOCK_50_B6A]
create_clock -period 20.000 [get_ports CLOCK_50_B7A]
create_clock -period 20.000 [get_ports CLOCK_50_B8A]
#create_clock -name {clk} -period 5.000 -waveform { 0.000 2.500 } [get_ports {clk}]


#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

#set_clock_uncertainty -rise_from [get_clocks {clk}] -rise_to [get_clocks {clk}] -setup 0.100  
#set_clock_uncertainty -rise_from [get_clocks {clk}] -rise_to [get_clocks {clk}] -hold 0.060  
#set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {clk}] -setup 0.100  
#set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {clk}] -hold 0.060  
#set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {clk}] -setup 0.100  
#set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {clk}] -hold 0.060  
#set_clock_uncertainty -fall_from [get_clocks {clk}] -fall_to [get_clocks {clk}] -setup 0.100  
#set_clock_uncertainty -fall_from [get_clocks {clk}] -fall_to [get_clocks {clk}] -hold 0.060  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

