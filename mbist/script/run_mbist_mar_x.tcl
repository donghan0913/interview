source .synopsys_dc.setup

define_design_lib WORK -path ./work
set PERIOD 0.8

# /* Read Verilog files */
analyze ./rtl -autoread -format verilog -define {MARCH_X}
elaborate mbist_top
list_libs
list_designs

# /* Check and link */
link 
check_design
uniquify
set_fix_multiple_port_nets -all -buffer_constants

# /* Source constraint & additional constraints */
set_operating_conditions slow
source script/TOP.con
set_dont_touch_network [get_clocks clk]
set_dont_touch_network [get_ports rst_n]

# /* Compile */
set compile_new_boolean_structure 
set_structure false 
compile -map_effort medium
check_design 

# /* Write out report */
report_area > ./report/mbist_syn_march_x.report
report_timing -path full -delay max >> ./report/mbist_syn_march_x.report
report_power >> ./report/mbist_syn_march_x.report
report_cell > ./report/mbist_syn_cell_march_x.report

# /* Write out netlist */
write -format verilog -hierarchy -output ./mapped/mbist_syn.v

# /* Write out SDF */
write_sdf -version 1.0 -context verilog -load_delay cell ./mapped/mbist_syn.sdf
