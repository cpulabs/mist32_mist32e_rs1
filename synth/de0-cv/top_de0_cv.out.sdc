## Generated SDC file "top_de0_cv.out.sdc"

## Copyright (C) 1991-2015 Altera Corporation. All rights reserved.
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, the Altera Quartus Prime License Agreement,
## the Altera MegaCore Function License Agreement, or other 
## applicable license agreement, including, without limitation, 
## that your use is for the sole purpose of programming logic 
## devices manufactured by Altera and sold by Altera or its 
## authorized distributors.  Please refer to the applicable 
## agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 15.1.0 Build 185 10/21/2015 SJ Lite Edition"

## DATE    "Wed Nov 25 12:32:51 2015"

##
## DEVICE  "5CEBA4F23C7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {MAIN_CLOCK} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLOCK_50}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]} -source [get_pins {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|refclkin}] -duty_cycle 50.000 -multiply_by 51 -divide_by 2 -master_clock {MAIN_CLOCK} [get_pins {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]}] 
create_generated_clock -name {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk} -source [get_pins {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|vco0ph[0]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 51 -master_clock {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]} [get_pins {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] 
create_generated_clock -name {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk} -source [get_pins {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|vco0ph[0]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 64 -master_clock {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]} [get_pins {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {MAIN_CLOCK}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {MAIN_CLOCK}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {MAIN_CLOCK}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {MAIN_CLOCK}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {MAIN_CLOCK}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {MAIN_CLOCK}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {MAIN_CLOCK}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {MAIN_CLOCK}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {MAIN_CLOCK}] -rise_to [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {MAIN_CLOCK}] -fall_to [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {MAIN_CLOCK}] -rise_to [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {MAIN_CLOCK}] -fall_to [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {MAIN_CLOCK}] -rise_to [get_clocks {MAIN_CLOCK}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {MAIN_CLOCK}] -rise_to [get_clocks {MAIN_CLOCK}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {MAIN_CLOCK}] -fall_to [get_clocks {MAIN_CLOCK}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {MAIN_CLOCK}] -fall_to [get_clocks {MAIN_CLOCK}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {MAIN_CLOCK}] -rise_to [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {MAIN_CLOCK}] -fall_to [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {MAIN_CLOCK}] -rise_to [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {MAIN_CLOCK}] -fall_to [get_clocks {GLOBAL_CLOCK|VGA_PLL|system_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {MAIN_CLOCK}] -rise_to [get_clocks {MAIN_CLOCK}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {MAIN_CLOCK}] -rise_to [get_clocks {MAIN_CLOCK}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {MAIN_CLOCK}] -fall_to [get_clocks {MAIN_CLOCK}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {MAIN_CLOCK}] -fall_to [get_clocks {MAIN_CLOCK}] -hold 0.060  


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

