set DESIGN "mbist_top"
set CLK_period 0.84

##      Step 1 : Read In Files                ##
read_file ./mapped/mbist_syn.v -format verilog
current_design "mbist_top"

##      Step 2 : Set ATE Configuration        ##
set_scan_configuration -style multiplexed_flip_flop -chain_count 1
create_clock -name "clk" -period $CLK_period clk

set_dft_signal -view existing_dft -type ScanClock -port clk -timing {45 55}
set_dft_signal -view existing_dft -port rst_n -type reset -active_state 0

##      Step 3 : Design Rule Validation       ##
create_test_protocol
dft_drc

##      Step 4 : Scan Chain Synthesis         ##
insert_dft

##      Step 5 : Write Out Files              ##
report_area > ./report/mbist_syn_dft_march_c_sub.report
report_timing >> ./report/mbist_syn_dft_march_c_sub.report
report_power >> ./report/mbist_syn_dft_march_c_sub.report

write -format verilog -hierarchy -output ./mapped/mbist_syn_dft.v
write_test_protocol -output ./mapped/mbist_syn_dft.stil

#exit


