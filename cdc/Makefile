#-------------------------------------------------------------------------------------------------------------------------------------------#
## set basic vcs & verdi option to execute command, do compile/run together, with kdb
VCS                 = vcs -full64 +v2k -kdb -debug_accell+all +neg_tchk -R
#COMP = vcs -kdb -debug_access+all -f filelist.f -l comp.log
#RUN = ./simv -l run.log
VERDI_RTL           = verdi -ssf ./waveform/pulse_sync.fsdb
VERDI_RTL_AFIFO     = verdi -ssf ./waveform/afifo.fsdb
VERDI_GATE          = verdi -ssf ./waveform/pulse_sync_syn.fsdb
VERDI_GATE_AFIFO    = verdi -ssf ./waveform/afifo_syn.fsdb
RTL_SIM_FILE        = ./filelist.f
RTL_SIM_FILE_AFIFO  = ./filelist_afifo.f
GATE_SIM_FILE       = ./filelist_gate.f
GATE_SIM_FILE_AFIFO = ./filelist_afifo_gate.f

DC 			            = dc_shell -f script/run_pulse_sync.tcl | tee -i dc.log
DC_HAND_CNT 		    = dc_shell -f script/run_pulse_sync_hand_cnt.tcl | tee -i dc.log
DC_AFIFO 			      = dc_shell -f script/run_afifo.tcl | tee -i dc.log

#-------------------------------------------------------------------------------------------------------------------------------------------#
# RTL simulation
## Functional mode test
rsim:
	$(VCS) -sverilog -f $(RTL_SIM_FILE) +define+PERIOD_SRC=2.0 +define+PERIOD_DST=3.0 -l run_rtl.log

rsim_hand_cnt:
	$(VCS) -sverilog -f $(RTL_SIM_FILE) +define+PERIOD_SRC=2.0 +define+PERIOD_DST=3.0 +define+HAND_CNT_BASED -l run_rtl.log

rsim_afifo:
	$(VCS) -f $(RTL_SIM_FILE_AFIFO) +define+PERIOD_A=2.0 +define+PERIOD_B=3.0 -l run_rtl.log

# verdi gui
verdi_rtl:
	$(VERDI_RTL) &

verdi_rtl_afifo:
	$(VERDI_RTL_AFIFO) &

# clean database
clean:
	rm -rf *vpd *rc verdi* novas* unrSimv* simv* csrc* *.log *key ./waveform/*fsdb *Log *bak *el *report no_trace* partition* dprof* clk* *DB *dir ./work/* *lib *.svf

#-------------------------------------------------------------------------------------------------------------------------------------------#
# Synthesis
dc:
	$(DC)

dc_hand_cnt:
	$(DC_HAND_CNT)

dc_afifo:
	$(DC_AFIFO)

## Gate-Level simulation
gsim:
	$(VCS) -sverilog -f $(GATE_SIM_FILE) +define+GATE_SIM +define+PERIOD_SRC=2.0 +define+PERIOD_DST=3.0 -v /home/m110/m110061576/process/CBDK_TSMC90GUTM_Arm_f1.0/orig_lib/aci/sc-x/verilog/tsmc090.v -l run_gate.log

#gsim_afifo:
#	$(VCS) -f $(GATE_SIM_FILE_AFIFO) +define+GATE_SIM +define+PERIOD_A=2.0 +define+PERIOD_B=3.0 +optconfigfile+cdc_notiming.cfg -v /home/m110/m110061576/process/CBDK_TSMC90GUTM_Arm_f1.0/orig_lib/aci/sc-x/verilog/tsmc090.v -l run_gate.log

gsim_afifo:
	$(VCS) -f $(GATE_SIM_FILE_AFIFO) +define+GATE_SIM +define+PERIOD_A=2.0 +define+PERIOD_B=3.0 -v /home/m110/m110061576/process/CBDK_TSMC90GUTM_Arm_f1.0/orig_lib/aci/sc-x/verilog/tsmc090.v -l run_gate.log

## verdi gui
verdi_gate:
	$(VERDI_GATE) &

verdi_gate_afifo:
	$(VERDI_GATE_AFIFO) &

#------------------------------------------------------------------------------------------------------------------------------------------#
## DATA_NUM for test patterns in each test, TEST_NUM for test number
comp_run_random_seed:
	$(VCS) +define+SEED=$(shell date +%N) +define+DATA_NUM=20 +define+TEST_NUM=500

