#-------------------------------------------------------------------------------------------------------------------------------------------#
## set basic vcs & verdi option to execute command, do compile/run together, with kdb
VCS = vcs -full64 +v2k -kdb -debug_accell+all +neg_tchk -R -l run.log
#COMP = vcs -kdb -debug_access+all -f filelist.f -l comp.log
#RUN = ./simv -l run.log
VERDI_RTL = verdi -ssf ./waveform/percep_top.fsdb
VERDI_GATE = verdi -ssf ./waveform/percep_top_syn.fsdb
RTL_SIM_FILE = ./filelist.f
GATE_SIM_FILE = ./filelist_gate.f
DC_PIP2_LZD = dc_shell -f script/run_pip2_lzd.tcl | tee -i dc.log
DC_PIP2_LZA_CEC = dc_shell -f script/run_pip2_lza_cec.tcl | tee -i dc.log
DC_PIP2_LZA_NOCEC = dc_shell -f script/run_pip2_lza_nocec.tcl | tee -i dc.log
DC_PIP4_LZD = dc_shell -f script/run_pip4_lzd.tcl | tee -i dc.log
DC_PIP4_LZA_CEC = dc_shell -f script/run_pip4_lza_cec.tcl | tee -i dc.log
DC_PIP4_LZA_NOCEC = dc_shell -f script/run_pip4_lza_nocec.tcl | tee -i dc.log

#-------------------------------------------------------------------------------------------------------------------------------------------#
## RTL simulation compile+run:
rsim_pip2_lzd:
	$(VCS) -f $(RTL_SIM_FILE) +define+PERIOD=2.6

rsim_pip2_lza_cec:
	$(VCS) -f $(RTL_SIM_FILE) +define+PERIOD=10.0 +define+LZA

rsim_pip2_lza_nocec:
	$(VCS) -f $(RTL_SIM_FILE) +define+PERIOD=10.0 +define+LZA +define+NO_CEC

rsim_pip4_lzd:
	$(VCS) -f $(RTL_SIM_FILE) +define+PERIOD=1.8 +define+PIP4

rsim_pip4_lza_cec:
	$(VCS) -f $(RTL_SIM_FILE) +define+PERIOD=10.0 +define+PIP4 +define+LZA

rsim_pip4_lza_nocec:
	$(VCS) -f $(RTL_SIM_FILE) +define+PERIOD=10.0 +define+PIP4 +define+LZA +define+NO_CEC

## verdi gui for RTL simulation
verdi_rtl:
	$(VERDI_RTL)

## clean database
clean:
	rm -rf *vpd *rc verdi* novas* unrSimv* simv* csrc* *.log *key ./waveform/*fsdb *Log *bak *el *report no_trace* partition* dprof* clk* *DB *dir ./work/* *lib *.svf

#-------------------------------------------------------------------------------------------------------------------------------------------#
## Synthesis
dc_pip2_lzd:
	$(DC_PIP2_LZD)

dc_pip2_lza_cec:
	$(DC_PIP2_LZA_CEC)

dc_pip2_lza_nocec:
	$(DC_PIP2_LZA_NOCEC)

dc_pip4_lzd:
	$(DC_PIP4_LZD)

dc_pip4_lza_cec:
	$(DC_PIP4_LZA_CEC)

dc_pip4_lza_nocec:
	$(DC_PIP4_LZA_NOCEC)

## Gate-Level simulation. 2.7 for PIP2_LZD, 2.6 for PIP2_LZA, 2.9 for PIP4_LZD, 2.7 for PIP4_LZA
gsim:
	$(VCS) -f $(GATE_SIM_FILE) +define+GATE_SIM +define+PERIOD=1.7 -v /home/m110/m110061576/process/CBDK_TSMC90GUTM_Arm_f1.0/orig_lib/aci/sc-x/verilog/tsmc090.v

## verdi gui for Gate-Level simulation
verdi_gate:
	$(VERDI_GATE) &

#------------------------------------------------------------------------------------------------------------------------------------------#
## DATA_NUM for test patterns in each test, TEST_NUM for test number
comp_run_random_seed:
	$(VCS) +define+SEED=$(shell date +%N) +define+DATA_NUM=20 +define+TEST_NUM=500
