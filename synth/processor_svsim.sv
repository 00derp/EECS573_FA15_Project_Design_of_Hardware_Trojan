`ifndef SYNTHESIS

//
// This is an automatically generated file from 
// dc_shell Version K-2015.06 -- May 28, 2015
//

// For simulation only. Do not modify.

module processor_svsim(
        input         clock,                     input         reset,                     input [3:0]   mem2proc_response,         input [63:0]  mem2proc_data,             input [3:0]   mem2proc_tag,      
        output logic [1:0]  proc2mem_command,          output logic [63:0] proc2mem_addr,             output logic [63:0] proc2mem_data,     
                        output logic [3:0]  core0_pipeline_completed_insts,
        output logic [3:0]  core0_pipeline_error_status,
        output logic [4:0]  core0_pipeline_commit_wr_idx,
        output logic [63:0] core0_pipeline_commit_wr_data,
        output logic        core0_pipeline_commit_wr_en,
        output logic [63:0] core0_pipeline_commit_NPC,
        output logic        core0_halt,
                output logic [63:0] core0_if_NPC_out,
        output logic [31:0] core0_if_IR_out,
        output logic        core0_if_valid_inst_out,
        
                output logic [63:0] core0_if_id_NPC,
        output logic [31:0] core0_if_id_IR,
        output logic        core0_if_id_valid_inst,
        
        
                output logic [63:0] core0_id_rs_NPC,
        output logic [31:0] core0_id_rs_IR,
        output logic        core0_id_rs_valid_inst,
        
        
                output logic [63:0] core0_rs_ex_NPC,
        output logic [31:0] core0_rs_ex_IR,
        output logic        core0_rs_ex_valid_inst,
        
        
                output logic [63:0] core0_ex_mem_NPC,
        output logic [31:0] core0_ex_mem_IR,
        output logic        core0_ex_mem_valid_inst,

                        output logic [3:0]  core1_pipeline_completed_insts,
        output logic [3:0]  core1_pipeline_error_status,
        output logic [4:0]  core1_pipeline_commit_wr_idx,
        output logic [63:0] core1_pipeline_commit_wr_data,
        output logic        core1_pipeline_commit_wr_en,
        output logic [63:0] core1_pipeline_commit_NPC,
        output logic        core1_halt,
                output logic [63:0] core1_if_NPC_out,
        output logic [31:0] core1_if_IR_out,
        output logic        core1_if_valid_inst_out,
        
                output logic [63:0] core1_if_id_NPC,
        output logic [31:0] core1_if_id_IR,
        output logic        core1_if_id_valid_inst,
        
        
                output logic [63:0] core1_id_rs_NPC,
        output logic [31:0] core1_id_rs_IR,
        output logic        core1_id_rs_valid_inst,
        
        
                output logic [63:0] core1_rs_ex_NPC,
        output logic [31:0] core1_rs_ex_IR,
        output logic        core1_rs_ex_valid_inst,
        
        
                output logic [63:0] core1_ex_mem_NPC,
        output logic [31:0] core1_ex_mem_IR,
        output logic        core1_ex_mem_valid_inst,

        output [1:0]        cache_ctrl02req_bus_command,
        output [1:0]        cache_ctrl12req_bus_command,
        output              cache_ctrl0_state,
        output              cache_ctrl1_state,
        
        output              core0_cache2cache_ctrl_hit_way0,
        output              core0_cache2cache_ctrl_hit_way1,
        output              core0_victim_cache2cache_ctrl_hit,
        output              core1_cache2cache_ctrl_hit_way0,
        output              core1_cache2cache_ctrl_hit_way1,
        output              core1_victim_cache2cache_ctrl_hit


  
  );

    

  processor processor( {>>{ clock }}, {>>{ reset }}, {>>{ mem2proc_response }}, 
        {>>{ mem2proc_data }}, {>>{ mem2proc_tag }}, {>>{ proc2mem_command }}, 
        {>>{ proc2mem_addr }}, {>>{ proc2mem_data }}, 
        {>>{ core0_pipeline_completed_insts }}, 
        {>>{ core0_pipeline_error_status }}, 
        {>>{ core0_pipeline_commit_wr_idx }}, 
        {>>{ core0_pipeline_commit_wr_data }}, 
        {>>{ core0_pipeline_commit_wr_en }}, {>>{ core0_pipeline_commit_NPC }}, 
        {>>{ core0_halt }}, {>>{ core0_if_NPC_out }}, {>>{ core0_if_IR_out }}, 
        {>>{ core0_if_valid_inst_out }}, {>>{ core0_if_id_NPC }}, 
        {>>{ core0_if_id_IR }}, {>>{ core0_if_id_valid_inst }}, 
        {>>{ core0_id_rs_NPC }}, {>>{ core0_id_rs_IR }}, 
        {>>{ core0_id_rs_valid_inst }}, {>>{ core0_rs_ex_NPC }}, 
        {>>{ core0_rs_ex_IR }}, {>>{ core0_rs_ex_valid_inst }}, 
        {>>{ core0_ex_mem_NPC }}, {>>{ core0_ex_mem_IR }}, 
        {>>{ core0_ex_mem_valid_inst }}, 
        {>>{ core1_pipeline_completed_insts }}, 
        {>>{ core1_pipeline_error_status }}, 
        {>>{ core1_pipeline_commit_wr_idx }}, 
        {>>{ core1_pipeline_commit_wr_data }}, 
        {>>{ core1_pipeline_commit_wr_en }}, {>>{ core1_pipeline_commit_NPC }}, 
        {>>{ core1_halt }}, {>>{ core1_if_NPC_out }}, {>>{ core1_if_IR_out }}, 
        {>>{ core1_if_valid_inst_out }}, {>>{ core1_if_id_NPC }}, 
        {>>{ core1_if_id_IR }}, {>>{ core1_if_id_valid_inst }}, 
        {>>{ core1_id_rs_NPC }}, {>>{ core1_id_rs_IR }}, 
        {>>{ core1_id_rs_valid_inst }}, {>>{ core1_rs_ex_NPC }}, 
        {>>{ core1_rs_ex_IR }}, {>>{ core1_rs_ex_valid_inst }}, 
        {>>{ core1_ex_mem_NPC }}, {>>{ core1_ex_mem_IR }}, 
        {>>{ core1_ex_mem_valid_inst }}, {>>{ cache_ctrl02req_bus_command }}, 
        {>>{ cache_ctrl12req_bus_command }}, {>>{ cache_ctrl0_state }}, 
        {>>{ cache_ctrl1_state }}, {>>{ core0_cache2cache_ctrl_hit_way0 }}, 
        {>>{ core0_cache2cache_ctrl_hit_way1 }}, 
        {>>{ core0_victim_cache2cache_ctrl_hit }}, 
        {>>{ core1_cache2cache_ctrl_hit_way0 }}, 
        {>>{ core1_cache2cache_ctrl_hit_way1 }}, 
        {>>{ core1_victim_cache2cache_ctrl_hit }} );
endmodule
`endif
