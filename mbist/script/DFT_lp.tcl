set DESIGN "mbist_top"
set CLK_period 0.68

##      Step 1 : Read In Files                ##
read_file ./mapped/mbist_syn.v -format verilog
current_design "mbist_top"

##      Step 2 : Set ATE Configuration        ##
create_clock -name "clk" -period $CLK_period clk
#create_clock -name "clk_1" -period $CLK_period clk_1
#create_clock -name "clk_2" -period $CLK_period clk_2

create_port -direction in  scan_en
create_port -direction in  scan_in
create_port -direction out scan_out

set_case_analysis 1 [get_ports test_mode]

set_dft_signal -view existing_dft -type TestMode    -port [get_ports test_mode] -active_state 1
set_dft_signal -view existing_dft -type ScanEnable  -port [get_ports scan_en]   -active_state 1
set_dft_signal -view existing_dft -type ScanDataIn  -port [get_ports scan_in]
set_dft_signal -view existing_dft -type ScanDataOut -port [get_ports scan_out]
set_dft_signal -view existing_dft -type ScanClock   -port clk -timing {45 55}
set_dft_signal -view existing_dft -type Reset       -port rst_n -active_state 0

set_scan_configuration -style multiplexed_flip_flop -chain_count 1 -replace true

##      Step 3 : Design Rule Validation       ##
create_test_protocol
dft_drc

##      Step 4 : Scan Chain Synthesis         ##
insert_dft

##      Step 5 : Write Out Files              ##
report_area > ./report/mbist_syn_dft_march_c_sub_lp.report
report_timing >> ./report/mbist_syn_dft_march_c_sub_lp.report
report_power >> ./report/mbist_syn_dft_march_c_sub_lp.report

write -format verilog -hierarchy -output ./mapped/mbist_syn_dft.v
write_test_protocol -output ./mapped/mbist_syn_dft.stil

#exit


