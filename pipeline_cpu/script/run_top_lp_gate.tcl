source .synopsys_dc.setup

define_design_lib WORK -path ./work
set PERIOD 6.4

# /* Read Verilog files */
analyze ./rtl -autoread -format verilog -define {MULT_PIP LP_GATE}
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

#set_dont_touch_network [get_clocks {clk}]
#set_dont_touch_network [get_ports {rst_n addr_out}]
set_ideal_network [get_ports {clk rst_n}]

set high_fanout_net_threshold 1500

# /* Set clock gating ICG cell style*/
set_app_var power_cg_iscgs_enable true
set design_pip [get_designs -quiet {pipreg_ifid_WIDTH_I32 \ 
                                    pipreg_idex_WIDTH_D32_ADDR_RFILE5 \
                                    pipreg_exmem_WIDTH_D32_ADDR_RFILE5 \ 
                                    pipreg_memwb_WIDTH_D32_ADDR_RFILE5 \ 
                                    rfile_WIDTH_I32_ADDR_RFILE5_DEPTH_RFILE32 \
                                    data_mem_BYTE8_WIDTH_D32_DEPTH_D256}]

set cg_setup [expr {$PERIOD*0.05}]
set cg_hold  [expr {$PERIOD*0.02}]

set_clock_gating_style -minimum_bitwidth 10000

set_clock_gating_style -designs $design_pip \
  -sequential_cell latch \
  -positive_edge_logic and \
  -negative_edge_logic or \
  -setup $cg_setup -hold $cg_hold \
  -minimum_bitwidth 16 \
  -max_fanout 256 \
  -control_point before

# /* Compile */
set compile_new_boolean_structure 
set_structure false 
compile -gate_clock -map_effort medium
check_design 

# /* Solve setup violation in GLS, due to ENCLK from cg cell*/
set enclk [get_pins inst_pipreg_memwb/clk_gate_mem_to_rfile_t3_reg/ENCLK]
set ep_cells [all_fanout -from $enclk -flat -endpoints_only -only_cells]
set ck_pins [get_pins -of_object $ep_cells -filter "is_clock_pin==true && (pin_name==CK || pin_name==CP)"]
set ck_pin_py7 [get_pins inst_pipreg_memwb/py_out_t_reg[7]/CK]
set ck_pin_py6 [get_pins inst_pipreg_memwb/py_out_t_reg[6]/CK]
set p_nets [get_nets p]
#set buf_lib [get_lib_cells slow/CLKBUFX1]
set buf_lib [get_lib_cells slow/CLKBUFX40]

#insert_buffer -new_cell_names enclk_buf_py7 -new_net_names enclk_n1 $ck_pin_py7 $buf_lib
#insert_buffer -new_cell_names enclk_buf_py7 -new_net_names enclk_n1 $ck_pin_py6 $buf_lib
insert_buffer -new_cell_names pbuf -new_net_names p_mid $p_nets $buf_lib

# /* Compile again for setup violation*/
compile -incremental -map_effort medium
check_design

# /* Write out report */
report_area > ./report/top_lp_gate_syn.report
report_timing -path full -delay max >> ./report/top_lp_gate_syn.report
report_power >> ./report/top_lp_gate_syn.report
report_power -analysis_effort medium -hierarchy -nosplit >> ./report/top_lp_gate_syn.report
report_cell > ./report/top_lp_gate_syn_cell.report
report_clock_gating -nosplit > ./report/top_clock_gate.report

# /* Write out netlist */
write -format verilog -hierarchy -output ./mapped/top_syn.v

# /* Write out SDF */
write_sdf -version 1.0 -context verilog -load_delay cell ./mapped/top_syn.sdf
