#-------------------------------------------------------------------------------------------------------------------------------------------#
## set basic vcs & verdi option to execute command, do compile/run together, with kdb
VCS 		= vcs -full64 +v2k -kdb -debug_accell+all +neg_tchk -R
#COMP = vcs -kdb -debug_access+all -f filelist.f -l comp.log
#RUN = ./simv -l run.log
VERDI_RTL 	= verdi -ssf ./waveform/top.fsdb
VERDI_GATE 	= verdi -ssf ./waveform/top_syn.fsdb
RTL_SIM_FILE 	= ./filelist.f
GATE_SIM_FILE 	= ./filelist_gate.f
DC 		= dc_shell -f script/run_top.tcl | tee -i dc.log
DC_MULTPIP 	= dc_shell -f script/run_top_multpip.tcl | tee -i dc.log
DC_LP_GATE 	= dc_shell -f script/run_top_lp_gate.tcl | tee -i dc.log
DFT_LP 	  	= dc_shell-t -f script/DFT_lp.tcl | tee -i dft.log
ATPG 		= tmax -shell < script/ATPG.tcl | tee -i atpg.log

#-------------------------------------------------------------------------------------------------------------------------------------------#
## RTL simulation
rsim:
	$(VCS) -f $(RTL_SIM_FILE) +define+PERIOD=6.5 -l run_rtl.log

rsim_multpip:
	$(VCS) -f $(RTL_SIM_FILE) +define+PERIOD=6.5 +define+MULT_PIP -l run_rtl.log

rsim_lp:
	$(VCS) -f $(RTL_SIM_FILE) +define+PERIOD=6.5 +define+MULT_PIP +define+LP_GATE -l run_rtl.log

## verdi gui
verdi_rtl:
	$(VERDI_RTL) &

## clean database
clean:
	rm -rf *vpd *rc verdi* novas* unrSimv* simv* csrc* *.log *key ./waveform/*fsdb *Log *bak *el *report no_trace* partition* dprof* clk* *DB *dir ./work/* *lib *.svf

#-------------------------------------------------------------------------------------------------------------------------------------------#
## Synthesis, move out "sdram_model" file from rtl directory when synthesis
dc:
	$(DC)

dc_multpip:
	$(DC_MULTPIP)

dc_lp:
	$(DC_LP_GATE)

## Gate-Level simulation
gsim:
	$(VCS) -f $(GATE_SIM_FILE) +define+GATE_SIM +define+PERIOD=6.4 -v /home/m110/m110061576/process/CBDK_TSMC90GUTM_Arm_f1.0/orig_lib/aci/sc-x/verilog/tsmc090.v -l run_gate.log

## verdi gui
verdi_gate:
	$(VERDI_GATE) &

## DFT & ATPG
dft_lp:
	$(DFT_LP)

atpg:
	$(ATPG)

#------------------------------------------------------------------------------------------------------------------------------------------#
## DATA_NUM for test patterns in each test, TEST_NUM for test number
comp_run_random_seed:
	$(VCS) +define+SEED=$(shell date +%N) +define+DATA_NUM=20 +define+TEST_NUM=500
