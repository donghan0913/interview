source .synopsys_dc.setup

define_design_lib WORK -path ./work
set PERIOD 5

# /* Read Verilog files */
analyze ./rtl -autoread -format verilog -define {sg75 den128Mb x16 AFIFO}
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

set_min_delay 1.0 -from [get_pins -hier *sdram_cmd_reg_reg[1]/Q*] -to [get_ports sdram_cas_n]
set_min_delay 1.0 -from [get_pins -hier *sdram_cmd_reg_reg[2]/Q*] -to [get_ports sdram_ras_n]
set_min_delay 1.0 -from [get_pins -hier *sdram_cmd_reg_reg[0]/Q*] -to [get_ports sdram_we_n]
set_min_delay 1.0 -from [get_pins -hier *sdram_addr_reg2*] -to [get_ports sdram_addr]

set_dont_touch_network [get_clocks {*_clk}]
set_dont_touch_network [get_ports {*rst_n sdram_* aref_*}]

#set_fix_hold [get_clocks sdram_clk]

# /* Compile */
set compile_new_boolean_structure 
set_structure false 
compile -map_effort medium
check_design 

# /* Write out report */
report_area > ./report/top_syn.report
report_timing -path full -delay max >> ./report/top_syn.report
report_timing -delay min >> ./report/top_syn.report
report_power >> ./report/top_syn.report
report_cell > ./report/top_syn_cell.report

# /* Write out netlist */
write -format verilog -hierarchy -output ./mapped/top_syn.v

# /* Write out SDF */
write_sdf -version 1.0 -context verilog -load_delay cell ./mapped/top_syn.sdf
