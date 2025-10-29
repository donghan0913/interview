source .synopsys_dc.setup

define_design_lib WORK -path ./work
set PERIOD 6.5

# /* Read Verilog files */
analyze ./rtl -autoread -format verilog -define {LP_GATE}
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
  -max_fanout 64 \
  -control_point before

# /* Compile */
set compile_new_boolean_structure 
set_structure false 
compile -gate_clock -map_effort medium
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

