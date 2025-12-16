set DESIGN "mbist_top"

##   Step 1 :Read In Files            ##
read_netlist ./mapped/mbist_syn_dft.v
read_netlist /home/m110/m110061576/process/CBDK_TSMC90GUTM_Arm_f1.0/CIC/Verilog/tsmc090.v -library
report_modules -summary 
report_modules -error 
report_modules -undefined 

##   Step 2 :Build ATPG Design Model  ##
run_build_mode $DESIGN

##   Step 3 :Design Rule Validation   ##
set_drc -allow_unstable_set_resets
run_drc ./mapped/mbist_syn_dft.stil

##   Step 4 :Run ATPG                 ##
#### 4a     :Run Flush test           ##
set_faults -model stuck
add_faults -all
set_patterns -delete
set_atpg -chain_test 0011R
run_atpg basic_scan_only

write_patterns ./mapped/mbist_syn_dft_flush.stil -format stil -replace

#### 4b     :Run Stuck-at test        ##
set_atpg -chain_test off
remove_faults -all
set_faults -model stuck
add_faults -all
set_atpg -merge high -abort_limit 250 -coverage 100 -decision random -fill x
run_atpg

report_faults -summary >  ./report/mbist_syn_fault_march_c_sub.report
write_patterns ./mapped/mbist_syn_dft_stuck.stil -format stil -replace

#### 4c     :Run Delay test           ##
remove_faults -all
set_faults -model transition
add_faults -all
#set_delay -launch_cycle last_shift
set_delay -launch_cycle system_clock
set_atpg -capture_cycles 2 -merge high -abort_limit 250 -coverage 100 -decision random -fill x
run_atpg

report_faults -summary >> ./report/mbist_syn_fault_march_c_sub.report
report_faults -class AU >> ./report/mbist_syn_fault_march_c_sub.report
write_patterns ./mapped/mbist_syn_dft_tran.stil  -format stil -replace






