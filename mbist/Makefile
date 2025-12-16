#-------------------------------------------------------------------------------------------------------------------------------------------#
## set basic vcs & verdi option to execute command, do compile/run together, with kdb
VCS = vcs -full64 +v2k -kdb -debug_accell+all +neg_tchk -R
#COMP = vcs -kdb -debug_access+all -f filelist.f -l comp.log
#RUN = ./simv -l run.log
VERDI_RTL = verdi -ssf ./waveform/mbist.fsdb
VERDI_GATE = verdi -ssf ./waveform/mbist_syn.fsdb
RTL_SIM_FILE = ./filelist.f
GATE_SIM_FILE = ./filelist_gate.f

DC_CKR 			= dc_shell -f script/run_mbist_ckr.tcl | tee -i dc.log
DC_MAR_C_SUB 		= dc_shell -f script/run_mbist_mar_c_sub.tcl | tee -i dc.log
DC_MAR_C_SUB_LOPOW 	= dc_shell -f script/run_mbist_mar_c_sub_lopow.tcl | tee -i dc.log
DC_MAR_X 		= dc_shell -f script/run_mbist_mar_x.tcl | tee -i dc.log
DC_MAR_X_LOPOW 		= dc_shell -f script/run_mbist_mar_x_lopow.tcl | tee -i dc.log
DFT 			= dc_shell-t -f script/DFT.tcl | tee -i dft.log
DFT_LP 	  = dc_shell-t -f script/DFT_lp.tcl | tee -i dft.log
ATPG 			= tmax -shell < script/ATPG.tcl | tee -i atpg.log
ATPG_ALL_TEST 		= tmax -shell < script/ATPG_alltest.tcl | tee -i atpg.log
  

#-------------------------------------------------------------------------------------------------------------------------------------------#
# RTL simulation
## Functional mode test
rsim_func:
	$(VCS) -f $(RTL_SIM_FILE) +define+PERIOD=10.0 +define+FUNC_MODE -l run_rtl.log

## Test mode Checkerboard
rsim_ckr:
	$(VCS) -f $(RTL_SIM_FILE) +define+PERIOD=10.0 +define+CHECKERBOARD -l run_rtl.log

## Test mode March C-
rsim_mar_c_sub:
	$(VCS) -f $(RTL_SIM_FILE) +define+PERIOD=10.0 +define+MARCH_C_SUB -l run_rtl.log

## Test mode March C- with low power LFSR AG
rsim_mar_c_sub_lp:
	$(VCS) -f $(RTL_SIM_FILE) +define+PERIOD=10.0 +define+MARCH_C_SUB +define+LOPOW_ADDR_GEN +define+SIM +notimingcheck -v /home/m110/m110061576/process/CBDK_TSMC90GUTM_Arm_f1.0/orig_lib/aci/sc-x/verilog/tsmc090.v -l run_rtl.log

## Test mode March X
rsim_mar_x:
	$(VCS) -f $(RTL_SIM_FILE) +define+PERIOD=10.0 +define+MARCH_X -l run_rtl.log

## Test mode March X with low power LFSR AG
rsim_mar_x_lp:
	$(VCS) -f $(RTL_SIM_FILE) +define+PERIOD=10.0 +define+MARCH_X +define+LOPOW_ADDR_GEN +define+SIM -l run_rtl.log

# verdi gui
verdi_rtl:
	$(VERDI_RTL) &

# clean database
clean:
	rm -rf *vpd *rc verdi* novas* unrSimv* simv* csrc* *.log *key ./waveform/*fsdb *Log *bak *el *report no_trace* partition* dprof* clk* *DB *dir ./work/* *lib *.svf

#-------------------------------------------------------------------------------------------------------------------------------------------#
# Synthesis
dc_ckr:
	$(DC_CKR)

dc_mar_c_sub:
	$(DC_MAR_C_SUB)

dc_mar_c_sub_lp:
	$(DC_MAR_C_SUB_LOPOW)

dc_mar_x:
	$(DC_MAR_X)

dc_mar_x_lp:
	$(DC_MAR_X_LOPOW)

## Gate-Level simulation
gsim:
	$(VCS) -f $(GATE_SIM_FILE) +define+GATE_SIM +define+PERIOD=0.78 -v /home/m110/m110061576/process/CBDK_TSMC90GUTM_Arm_f1.0/orig_lib/aci/sc-x/verilog/tsmc090.v -l run_gate.log

gsim_lp:
	$(VCS) -f $(GATE_SIM_FILE) +define+GATE_SIM +define+PERIOD=0.68 +define+LOPOW_ADDR_GEN -v /home/m110/m110061576/process/CBDK_TSMC90GUTM_Arm_f1.0/orig_lib/aci/sc-x/verilog/tsmc090.v -l run_gate.log

## verdi gui
verdi_gate:
	$(VERDI_GATE) &

## DFT/ATPG
dft:
	$(DFT)

dft_lp:
	$(DFT_LP)

atpg:
	$(ATPG)

atpg_all:
	$(ATPG_ALL_TEST)


#------------------------------------------------------------------------------------------------------------------------------------------#
## DATA_NUM for test patterns in each test, TEST_NUM for test number
comp_run_random_seed:
	$(VCS) +define+SEED=$(shell date +%N) +define+DATA_NUM=20 +define+TEST_NUM=500
