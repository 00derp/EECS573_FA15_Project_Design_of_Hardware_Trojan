# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Mon Mar 9 01:09:44 2015
# Designs open: 1
#   Sim: /afs/umich.edu/user/x/m/xmguo/Documents/470/group5/verilog/RS/dve
# Toplevel windows open: 1
# 	TopLevel.2
#   Wave.1: 32 signals
#   Group count = 2
#   Group Group1 signal count = 32
#   Group Group2 signal count = 48
# End_DVE_Session_Save_Info

# DVE version: H-2013.06-SP1_Full64
# DVE build date: Nov 27 2013 21:25:23


#<Session mode="Full" path="/afs/umich.edu/user/x/m/xmguo/Documents/470/group5/verilog/RS/DVEfiles/session.tcl" type="Debug">

gui_set_loading_session_type Post
gui_continuetime_set

# Close design
if { [gui_sim_state -check active] } {
    gui_sim_terminate
}
gui_close_db -all
gui_expr_clear_all

# Close all windows
gui_close_window -type Console
gui_close_window -type Wave
gui_close_window -type Source
gui_close_window -type Schematic
gui_close_window -type Data
gui_close_window -type DriverLoad
gui_close_window -type List
gui_close_window -type Memory
gui_close_window -type HSPane
gui_close_window -type DLPane
gui_close_window -type Assertion
gui_close_window -type CovHier
gui_close_window -type CoverageTable
gui_close_window -type CoverageMap
gui_close_window -type CovDetail
gui_close_window -type Local
gui_close_window -type Stack
gui_close_window -type Watch
gui_close_window -type Group
gui_close_window -type Transaction



# Application preferences
gui_set_pref_value -key app_default_font -value {Helvetica,10,-1,5,50,0,0,0,0,0}
gui_src_preferences -tabstop 8 -maxbits 24 -windownumber 1
#<WindowLayout>

# DVE top-level session


# Create and position top-level window: TopLevel.2

if {![gui_exist_window -window TopLevel.2]} {
    set TopLevel.2 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.2 TopLevel.2
}
gui_show_window -window ${TopLevel.2} -show_state normal -rect {{12 132} {2435 1408}}

# ToolBar settings
gui_set_toolbar_attributes -toolbar {TimeOperations} -dock_state top
gui_set_toolbar_attributes -toolbar {TimeOperations} -offset 0
gui_show_toolbar -toolbar {TimeOperations}
gui_hide_toolbar -toolbar {&File}
gui_set_toolbar_attributes -toolbar {&Edit} -dock_state top
gui_set_toolbar_attributes -toolbar {&Edit} -offset 0
gui_show_toolbar -toolbar {&Edit}
gui_hide_toolbar -toolbar {CopyPaste}
gui_set_toolbar_attributes -toolbar {&Trace} -dock_state top
gui_set_toolbar_attributes -toolbar {&Trace} -offset 0
gui_show_toolbar -toolbar {&Trace}
gui_hide_toolbar -toolbar {TraceInstance}
gui_hide_toolbar -toolbar {BackTrace}
gui_set_toolbar_attributes -toolbar {&Scope} -dock_state top
gui_set_toolbar_attributes -toolbar {&Scope} -offset 0
gui_show_toolbar -toolbar {&Scope}
gui_set_toolbar_attributes -toolbar {&Window} -dock_state top
gui_set_toolbar_attributes -toolbar {&Window} -offset 0
gui_show_toolbar -toolbar {&Window}
gui_set_toolbar_attributes -toolbar {Signal} -dock_state top
gui_set_toolbar_attributes -toolbar {Signal} -offset 0
gui_show_toolbar -toolbar {Signal}
gui_set_toolbar_attributes -toolbar {Zoom} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom} -offset 0
gui_show_toolbar -toolbar {Zoom}
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -offset 0
gui_show_toolbar -toolbar {Zoom And Pan History}
gui_set_toolbar_attributes -toolbar {Grid} -dock_state top
gui_set_toolbar_attributes -toolbar {Grid} -offset 0
gui_show_toolbar -toolbar {Grid}
gui_set_toolbar_attributes -toolbar {Simulator} -dock_state top
gui_set_toolbar_attributes -toolbar {Simulator} -offset 0
gui_show_toolbar -toolbar {Simulator}
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -dock_state top
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -offset 0
gui_show_toolbar -toolbar {Interactive Rewind}
gui_set_toolbar_attributes -toolbar {Testbench} -dock_state top
gui_set_toolbar_attributes -toolbar {Testbench} -offset 0
gui_show_toolbar -toolbar {Testbench}

# End ToolBar settings

# Docked window settings
gui_sync_global -id ${TopLevel.2} -option true

# MDI window settings
set Wave.1 [gui_create_window -type {Wave}  -parent ${TopLevel.2}]
gui_show_window -window ${Wave.1} -show_state maximized
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 703} {child_wave_right 1715} {child_wave_colname 349} {child_wave_colvalue 350} {child_wave_col1 0} {child_wave_col2 1}}

# End MDI window settings

gui_set_env TOPLEVELS::TARGET_FRAME(Source) none
gui_set_env TOPLEVELS::TARGET_FRAME(Schematic) none
gui_set_env TOPLEVELS::TARGET_FRAME(PathSchematic) none
gui_set_env TOPLEVELS::TARGET_FRAME(Wave) none
gui_set_env TOPLEVELS::TARGET_FRAME(List) none
gui_set_env TOPLEVELS::TARGET_FRAME(Memory) none
gui_set_env TOPLEVELS::TARGET_FRAME(DriverLoad) none
gui_update_statusbar_target_frame ${TopLevel.2}

#</WindowLayout>

#<Database>

# DVE Open design session: 

if { [llength [lindex [gui_get_db -design Sim] 0]] == 0 } {
gui_set_env SIMSETUP::SIMARGS {{-ucligui +vc +memcbk}}
gui_set_env SIMSETUP::SIMEXE {/afs/umich.edu/user/x/m/xmguo/Documents/470/group5/verilog/RS/dve}
gui_set_env SIMSETUP::ALLOW_POLL {0}
if { ![gui_is_db_opened -db {/afs/umich.edu/user/x/m/xmguo/Documents/470/group5/verilog/RS/dve}] } {
gui_sim_run Ucli -exe dve -args {-ucligui +vc +memcbk} -dir /afs/umich.edu/user/x/m/xmguo/Documents/470/group5/verilog/RS -nosource
}
}
if { ![gui_sim_state -check active] } {error "Simulator did not start correctly" error}
gui_set_precision 100ps
gui_set_time_units 100ps
#</Database>

# DVE Global setting session: 


# Global: Breakpoints

# Global: Bus

# Global: Expressions

# Global: Signal Time Shift

# Global: Signal Compare

# Global: Signal Groups
gui_load_child_values {testbench.dut}
gui_load_child_values {testbench}


set _session_group_3 Group1
gui_sg_create "$_session_group_3"
set Group1 "$_session_group_3"

gui_sg_addsignal -group "$_session_group_3" { testbench.clock testbench.reset testbench.ROB_branch_mispredict_in testbench.ex_CDB_arb_stall_in testbench.ex_MULT_busy_in testbench.id_rs_srcA_valid_in testbench.id_rs_srcB_valid_in testbench.id_rs_valid_inst_in testbench.id_rs_uncond_branch_in testbench.id_rs_cond_branch_in testbench.id_rs_opa_select_in testbench.id_rs_opb_select_in testbench.id_rs_opcode_in testbench.id_rs_IR_in testbench.id_rs_PC_plus_4_in testbench.id_rs_predicted_target_addr_in testbench.id_rs_srcA_PRF_num_in testbench.id_rs_srcB_PRF_num_in testbench.id_rs_dest_PRF_num_in testbench.ex_CDB_tag_in testbench.RS_full_out testbench.RS_uncond_branch_out testbench.RS_cond_branch_out testbench.RS_opa_select_out testbench.RS_opb_select_out testbench.RS_opcode_out testbench.RS_IR_out testbench.RS_PC_plus_4_out testbench.RS_predicted_target_addr_out testbench.RS_srcA_PRF_num_out testbench.RS_srcB_PRF_num_out testbench.RS_dest_PRF_num_out }

set _session_group_4 Group2
gui_sg_create "$_session_group_4"
set Group2 "$_session_group_4"

gui_sg_addsignal -group "$_session_group_4" { testbench.dut.clock testbench.dut.reset testbench.dut.ROB_branch_mispredict_in testbench.dut.ROB_ROB_num_in testbench.dut.ex_MULT_busy_in testbench.dut.ex_CDB_arb_stall_in testbench.dut.id_rs_srcA_valid_in testbench.dut.id_rs_srcB_valid_in testbench.dut.id_rs_valid_inst_in testbench.dut.id_rs_uncond_branch_in testbench.dut.id_rs_cond_branch_in testbench.dut.id_rs_cpuid_in testbench.dut.id_rs_illegal_in testbench.dut.id_rs_halt_in testbench.dut.id_rs_opa_select_in testbench.dut.id_rs_opb_select_in testbench.dut.id_rs_opcode_in testbench.dut.id_rs_IR_in testbench.dut.id_rs_PC_plus_4_in testbench.dut.id_rs_predicted_target_addr_in testbench.dut.id_rs_srcA_PRF_num_in testbench.dut.id_rs_srcB_PRF_num_in testbench.dut.id_rs_dest_PRF_num_in testbench.dut.ex_CDB_tag_in testbench.dut.RS_full_out testbench.dut.RS_valid_inst_out testbench.dut.RS_uncond_branch_out testbench.dut.RS_cond_branch_out testbench.dut.RS_cpuid_out testbench.dut.RS_illegal_out testbench.dut.RS_halt_out testbench.dut.RS_opa_select_out testbench.dut.RS_opb_select_out testbench.dut.RS_opcode_out testbench.dut.RS_IR_out testbench.dut.RS_PC_plus_4_out testbench.dut.RS_predicted_target_addr_out testbench.dut.RS_srcA_PRF_num_out testbench.dut.RS_srcB_PRF_num_out testbench.dut.RS_dest_PRF_num_out testbench.dut.RS_ROB_num_out testbench.dut.free_list testbench.dut.choose_list testbench.dut.issue_list testbench.dut.wr_en testbench.dut.issue_en testbench.dut.srcA_valid_in testbench.dut.srcB_valid_in }

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 199



# Save global setting...

# Wave/List view global setting
gui_cov_show_value -switch false

# Close all empty TopLevel windows
foreach __top [gui_ekki_get_window_ids -type TopLevel] {
    if { [llength [gui_ekki_get_window_ids -parent $__top]] == 0} {
        gui_close_window -window $__top
    }
}
gui_set_loading_session_type noSession
# DVE View/pane content session: 


# View 'Wave.1'
gui_wv_sync -id ${Wave.1} -switch false
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 0 565
gui_list_add_group -id ${Wave.1} -after {New Group} {Group1}
gui_seek_criteria -id ${Wave.1} {Any Edge}



gui_set_env TOGGLE::DEFAULT_WAVE_WINDOW ${Wave.1}
gui_set_pref_value -category Wave -key exclusiveSG -value $groupExD
gui_list_set_height -id Wave -height $origWaveHeight
if {$origGroupCreationState} {
	gui_list_create_group_when_add -wave -enable
}
if { $groupExD } {
 gui_msg_report -code DVWW028
}
gui_list_set_filter -id ${Wave.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {Parameter 1} {All 1} {Aggregate 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Wave.1} -text {*}
gui_list_set_insertion_bar  -id ${Wave.1} -group Group1  -position in

gui_marker_move -id ${Wave.1} {C1} 199
gui_view_scroll -id ${Wave.1} -vertical -set 0
gui_show_grid -id ${Wave.1} -enable false
# Restore toplevel window zorder
# The toplevel window could be closed if it has no view/pane
if {[gui_exist_window -window ${TopLevel.2}]} {
	gui_set_active_window -window ${TopLevel.2}
	gui_set_active_window -window ${Wave.1}
}
#</Session>

