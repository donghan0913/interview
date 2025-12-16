source .synopsys_dc.setup

define_design_lib WORK -path ./work
set PERIOD_A 2.0
set PERIOD_B 3.0
set PERIOD_A_TICK 2
set PERIOD_B_TICK 3
set DEFINE_STR "PERIOD_A=$PERIOD_A_TICK PERIOD_B=$PERIOD_B_TICK"

# /* Read Verilog files */
analyze ./rtl_afifo -autoread -format verilog -define "$DEFINE_STR"
elaborate afifo

list_libs
list_designs

# /* Check and link */
link 
check_design
uniquify
set_fix_multiple_port_nets -all -buffer_constants

# /* Source constraint & additional constraints */
set_operating_conditions slow
source script/TOP_AFIFO.con
set_dont_touch_network [get_clocks {clk_*}]
set_dont_touch_network [get_ports rst_n]

# /* Compile */
set compile_new_boolean_structure 
set_structure false 
compile -map_effort medium
check_design 

# /* Write out report */
report_area > ./report/afifo_syn.report
report_timing -path full -delay max >> ./report/afifo_syn.report
report_power >> ./report/afifo_syn.report
report_power -analysis_effort medium -hierarchy -nosplit >> ./report/afifo_syn.report
report_cell > ./report/afifo_syn_cell.report

# /* Write out netlist */
write -format verilog -hierarchy -output ./mapped/afifo_syn.v

# /* Write out SDF */
write_sdf -version 1.0 -context verilog -load_delay cell ./mapped/afifo_syn.sdf

