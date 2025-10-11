#-------------------------------------------------------------------------------------------------------------------------------------------#
## set basic vcs & verdi option to execute command, do compile/run together, with kdb
VCS = vcs -full64 +v2k -kdb -debug_accell+all +neg_tchk -R
#COMP = vcs -kdb -debug_access+all -f filelist.f -l comp.log
#RUN = ./simv -l run.log
VERDI_RTL = verdi -ssf ./waveform/top.fsdb
VERDI_GATE = verdi -ssf ./waveform/top_syn.fsdb
RTL_SIM_FILE = ./filelist.f
GATE_SIM_FILE = ./filelist_gate.f
DC = dc_shell -f script/run_top.tcl | tee -i dc.log

#-------------------------------------------------------------------------------------------------------------------------------------------#
## RTL simulation
rsim:
	$(VCS) -sverilog -f $(RTL_SIM_FILE) +define+PERIOD=5 +define+sg75 +define+den128Mb +define+x16 +define+AFIFO -l run_rtl.log

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

## Gate-Level simulation
gsim:
	$(VCS) -f $(GATE_SIM_FILE) +define+GATE_SIM +define+PERIOD=5 -v /home/m110/m110061576/process/CBDK_TSMC90GUTM_Arm_f1.0/orig_lib/aci/sc-x/verilog/tsmc090.v -l run_gate.log

## verdi gui
verdi_gate:
	$(VERDI_GATE) &

#------------------------------------------------------------------------------------------------------------------------------------------#
## DATA_NUM for test patterns in each test, TEST_NUM for test number
comp_run_random_seed:
	$(VCS) +define+SEED=$(shell date +%N) +define+DATA_NUM=20 +define+TEST_NUM=500
