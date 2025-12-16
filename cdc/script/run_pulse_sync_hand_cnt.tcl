source .synopsys_dc.setup

define_design_lib WORK -path ./work
set PERIOD_SRC 2.0
set PERIOD_DST 3.0

#set BASE_UNIT 0.1
#set PERIOD_SRC_TICK [expr int($PERIOD_SRC / $BASE_UNIT + 0.5)]
#set PERIOD_DST_TICK [expr int($PERIOD_DST / $BASE_UNIT + 0.5)]

set PERIOD_SRC_TICK 2
set PERIOD_DST_TICK 3
set DEFINE_STR "HAND_CNT_BASED PERIOD_SRC=$PERIOD_SRC_TICK PERIOD_DST=$PERIOD_DST_TICK"

# /* Read Verilog files */
analyze ./rtl -autoread -format verilog -define "$DEFINE_STR"
analyze -format sverilog ./rtl/pulse_sync_src.sv -define "$DEFINE_STR"
elaborate pulse_sync

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
set_dont_touch_network [get_clocks {clk_*}]
set_dont_touch_network [get_ports rst_n]

# /* Compile */
set compile_new_boolean_structure 
set_structure false 
compile -map_effort medium
check_design 

# /* Write out report */
report_area > ./report/pulse_sync_hand_cnt_syn.report
report_timing -path full -delay max >> ./report/pulse_sync_hand_cnt_syn.report
report_power >> ./report/pulse_sync_hand_cnt_syn.report

# /* Write out netlist */
write -format verilog -hierarchy -output ./mapped/pulse_sync_syn.v

# /* Write out SDF */
write_sdf -version 1.0 -context verilog -load_delay cell ./mapped/pulse_sync_syn.sdf

