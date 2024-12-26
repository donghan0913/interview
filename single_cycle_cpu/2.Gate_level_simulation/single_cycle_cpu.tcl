define_design_lib WORK -path ./work
set PERIOD 4.2

#/*1. Read Verilog files */
analyze ../rtl -autoread -format verilog
elaborate single_cycle_cpu
list_libs
list_designs

#/* Set top module name */
set_operating_conditions slow

#/*2. Set constraint */
create_clock -period $PERIOD [get_ports clk]
set_dont_touch_network [get_clocks clk]
set_dont_touch_network [get_ports rstn]

set_output_delay -max [expr {$PERIOD * 0.6}] -clock clk [all_outputs]
set_drive 1 [all_inputs]
set_load [load_of slow/CLKBUFX20/A] [all_outputs]

## /* Set RAM & ROM as a black box */
#set_dont_touch [get_cells instruction_mem]
#set_dont_touch [get_cells data_mem]

#/*3. Check and link */
link 
check_design
uniquify
set_fix_multiple_port_nets -all -buffer_constants

#/*4. Compile */
set compile_new_boolean_structure 
set_structure false 
compile -map_effort medium 
check_design 

#/*5. Write out file */
report_area > ./single_cycle_cpu_syn.report
report_timing -path full -delay max >> ./single_cycle_cpu_syn.report
report_power >> ./single_cycle_cpu_syn.report
report_cell > ./single_cycle_cpu_cells.report

#/* Write out netlist */
write -format verilog -hierarchy -output ./single_cycle_cpu_syn.v
write -format verilog -hierarchy -output ../3.Post_layout_Simulation/APR/design_data/single_cycle_cpu_syn.v


exit
