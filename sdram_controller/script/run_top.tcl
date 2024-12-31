source .synopsys_dc.setup

define_design_lib WORK -path ./work
set PERIOD 7.5

# /* Read Verilog files */
analyze ./rtl -autoread -format verilog -define {sg75 den128Mb x16}
elaborate top
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
set_dont_touch_network [get_clocks {*_clk}]
set_dont_touch_network [get_ports {sys_rst_n uart_* sdram_* aref_*}]
#set_dont_touch [get_cells sdram_model]

# /* Compile */
set compile_new_boolean_structure 
set_structure false 
compile -map_effort medium
check_design 

# /* Write out report */
report_area > ./report/top_syn.report
report_timing -path full -delay max >> ./report/top_syn.report
report_power >> ./report/top_syn.report
report_cell > ./report/top_syn_cell.report

# /* Write out netlist */
write -format verilog -hierarchy -output ./mapped/top_syn.v

# /* Write out SDF */
write_sdf -version 1.0 -context verilog -load_delay cell ./mapped/top_syn.sdf
