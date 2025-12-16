source .synopsys_dc.setup

define_design_lib WORK -path ./work
set PERIOD 0.68

# /* Read Verilog files */
analyze ./rtl -autoread -format verilog -define {MARCH_C_SUB LOPOW_ADDR_GEN}
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
source script/TOP_LOPOW.con

set_dont_touch_network [get_clocks clk]
set_dont_touch_network [get_ports rst_n]
#set_ideal_network [get_ports {clk rst_n}]

set_dont_touch [get_cells \
   "inst_clk_gen/u_xnor_en1 \
    inst_clk_gen/u_and_en2  \
    inst_clk_gen/u_or_clk1  \
    inst_clk_gen/u_or_clk2  \
    inst_clk_gen/u_lat_en1  \
    inst_clk_gen/u_lat_en2"]

# /* Compile */
set compile_new_boolean_structure 
set_structure false 
compile -map_effort medium
check_design  

# /* Write out report */
report_area > ./report/mbist_syn_march_c_sub_lopow.report
report_timing -path full -delay max >> ./report/mbist_syn_march_c_sub_lopow.report
report_power >> ./report/mbist_syn_march_c_sub_lopow.report
report_power -analysis_effort medium -hierarchy -nosplit >> ./report/mbist_syn_march_c_sub_lopow.report
report_cell > ./report/mbist_syn_cell_march_c_sub_lopow.report

# /* Write out netlist */
write -format verilog -hierarchy -output ./mapped/mbist_syn.v

# /* Write out SDF */
write_sdf -version 1.0 -context verilog -load_delay cell ./mapped/mbist_syn.sdf
