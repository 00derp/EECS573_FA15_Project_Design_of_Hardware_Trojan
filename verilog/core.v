/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  pipeline.v                                          //
//                                                                     //
//  Description :  Top-level module of the verisimple pipeline;        //
//                 This instantiates and connects the 5 stages of the  //
//                 Verisimple pipeline togeather.                      //
//                                                                     //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps

module core (

        input         clock,             // System clock
        input         reset,             // System reset
/*        input [3:0]   mem2proc_response, // Tag from memory about current request
        input [63:0]  mem2proc_data,     // Data coming back from memory
        input [3:0]   mem2proc_tag,      // Tag from memory about current reply

        output logic [1:0]  proc2mem_command,  // command sent to memory
        output logic [63:0] proc2mem_addr,     // Address sent to memory
        output logic [63:0] proc2mem_data,     // Data sent to memory*/
        input  [2:0] CPU_ID,
        // cache inputs
        input  [3:0] mem_arb2Icache_response,
        input [63:0] mem_arb2Icache_data,
        input  [3:0] mem_arb2Icache_tag,
        input [15:0] req_bus_addr,
        input  [1:0] req_bus_command,
        input  [2:0] req_bus_source,
        input [63:0] resp_bus_data,
//        input  [2:0] resp_bus_dest,
        input        resp_bus_valid,
        input        hit_bus,
        input        hitm_bus,
        input  [3:0] mem_response,
        input  [3:0] mem_tag,

        input                    otherProc_st_stc_in,
        input   [15:0]           otherProc_st_stc_addr_in,
        input                    stc_must_fail,
        
        // cache outputs
        output logic  [1:0] Icache2mem_command,
        output logic [63:0] Icache2mem_addr,
        output logic [63:0] cache_ctrl2resp_bus_data,
//        output [63:0] cache_ctrl2resp_bus_addr,
        output logic        cache_ctrl2resp_bus_valid,
//        output [2:0] cache_ctrl2resp_bus_dest,
        output logic [63:0] cache_ctrl2req_bus_data,
        output logic [15:0] cache_ctrl2req_bus_addr,
        output logic  [1:0] cache_ctrl2req_bus_command,
        output logic        cache_ctrl2hit,
        output logic        cache_ctrl2hitm,
        output logic        cache_ctrl_state,

        output logic        to_OtherProc_st_stc_out,
        output logic        to_OtherProc_stc_out,
        output logic [15:0] to_OtherProc_st_addr_out,
        // printing outputs
        output logic [3:0]  pipeline_completed_insts,
        output logic [3:0]  pipeline_error_status,
        output logic [4:0]  pipeline_commit_wr_idx,
        output logic [63:0] pipeline_commit_wr_data,
        output logic        pipeline_commit_wr_en,
        output logic [63:0] pipeline_commit_NPC,
        output logic        halt,


                // testing hooks (these must be exported so we can test
                // the synthesized version) data is tested by looking at
                // the final values in memory
        
        
        // Outputs from IF-Stage 
        output logic [63:0] if_NPC_out,
        output logic [31:0] if_IR_out,
        output logic        if_valid_inst_out,
        
        // Outputs from IF/ID Pipeline Register
        output logic [63:0] if_id_NPC,
        output logic [31:0] if_id_IR,
        output logic        if_id_valid_inst,
        
        
        // Outputs from ID/RS Pipeline Register
        output logic [63:0] id_rs_NPC,
        output logic [31:0] id_rs_IR,
        output logic        id_rs_valid_inst,
        
        
        // Outputs from RS/EX Pipeline Register
        output logic [63:0] rs_ex_NPC,
        output logic [31:0] rs_ex_IR,
        output logic        rs_ex_valid_inst,
        
        
        // Outputs from EX/WB Pipeline Register
        output logic [63:0] ex_mem_NPC,
        output logic [31:0] ex_mem_IR,
        output logic        ex_mem_valid_inst_out,

        output              cache2cache_ctrl_hit_way0,
        output              cache2cache_ctrl_hit_way1,
        output              victim_cache2cache_ctrl_hit//,

//        output logic        core_mispredict
        
        
                );

  assign ex_mem_NPC[63:16] = 48'b0;
  // Pipeline register enables
  logic   if_id_enable, id_rs_enable, rs_ex_enable, ex_wb_enable;//, ex_mem_enable;

  //Outputs from IF stage
  logic [15:0]           if_predicted_target_addr_out;
  logic                  if_predicted_taken_out;

  //Outputs from IF/ID Pipeline Register

  logic [15:0]           if_id_predicted_target_addr;



  // Outputs from ID stage
  logic [1:0]            id_opa_select_out;   
  logic [1:0]            id_opb_select_out;   
  logic [`PRF_width-1:0] id_srcA_PRF_num_out;    
  logic [`PRF_width-1:0] id_srcB_PRF_num_out;  
  logic [`ARF_width-1:0] id_ARF_num_out;
  logic [`PRF_width-1:0] id_dest_PRF_num_out;  
  logic                  id_srcA_valid_out;
  logic                  id_srcB_valid_out;                         
  logic  [4:0]           id_alu_func_out;      
  logic                  id_rd_mem_out;       
  logic                  id_wr_mem_out;       
  logic                  id_ldl_mem_out;      
  logic                  id_stc_mem_out;      
  logic                  id_cond_branch_out;   
  logic                  id_uncond_branch_out; 
  logic                  id_halt_out;
  logic                  id_cpuid_out;       
  logic                  id_illegal_out;
  logic                  id_valid_inst_out;   
  logic                  id_no_free_PRF_out;  

  // Outputs from ID/RS Pipeline Register
  logic [1:0]            id_rs_opa_select; 
  logic [1:0]            id_rs_opb_select;  
  logic [`PRF_width-1:0] id_rs_srcA_PRF_num;   
  logic [`PRF_width-1:0] id_rs_srcB_PRF_num;  
  logic [`ARF_width-1:0] id_rs_ARF_num;    
  logic [`PRF_width-1:0] id_rs_dest_PRF_num;  
  logic                  id_rs_srcA_valid;
  logic                  id_rs_srcB_valid;
  logic  [4:0]           id_rs_alu_func;
  logic                  id_rs_rd_mem; 
  logic                  id_rs_wr_mem;     
  logic                  id_rs_ldl_mem; 
  logic                  id_rs_stc_mem;   
  logic                  id_rs_cond_branch;  
  logic                  id_rs_uncond_branch;
  logic                  id_rs_halt;
  logic                  id_rs_cpuid;       
  logic                  id_rs_illegal;
  logic [15:0]           id_rs_predicted_target_addr;
  
  //Outputs from RS Stage
  logic                    RS_full_out;
  logic                    RS_valid_inst_out;
  logic                    RS_uncond_branch_out;
  logic                    RS_cond_branch_out;
  logic                    RS_rd_mem_out;
  logic                    RS_wr_mem_out;
  logic                    RS_ldl_out;
  logic                    RS_stc_out;
  logic                    RS_cpuid_out;
  logic   [1:0]            RS_opa_select_out; 
  logic   [1:0]            RS_opb_select_out;
  logic   [4:0]            RS_opcode_out;
  logic   [31:0]           RS_IR_out;
  logic   [15:0]           RS_PC_plus_4_out;
  logic   [15:0]           RS_predicted_target_addr_out;
  logic   [`PRF_width-1:0] RS_srcA_PRF_num_out;
  logic   [`PRF_width-1:0] RS_srcB_PRF_num_out;
  logic   [`PRF_width-1:0] RS_dest_PRF_num_out;
  logic   [`ROB_width-1:0] RS_ROB_num_out;
  logic   [`ARF_width-1:0] ROB_ARF_num_out;
  logic   [`PRF_width-1:0] ROB_PRF_num_out;
  logic   [15:0]           ROB_PC_plus_4_out;
  logic   [15:0]           ROB_NPC_out;
  logic                    ROB_branch_mispredict_out;
  logic                    ROB_is_store_inst_out;
  logic                    ROB_is_branch_inst_out;
  logic                    ROB_commit_out;
  logic                    ROB_dispatch_disable;
  logic [`ROB_width-1:0]   ROB_head;
  logic [`ROB_width-1:0]   ROB_tail;
  logic                    ROB_illegal_out;
  logic                    ROB_halt_out;
  

  //Outputs from RS/EX Pipeline Register
  logic                    rs_ex_uncond_branch;
  logic                    rs_ex_cond_branch;
  logic                    rs_ex_st_inst;
  logic                    rs_ex_ld_inst;
  logic                    rs_ex_stc_inst;
  logic                    rs_ex_ldl_inst;
  logic                    rs_ex_cpuid;   
  logic   [1:0]            rs_ex_opa_select; 
  logic   [1:0]            rs_ex_opb_select;
  logic   [4:0]            rs_ex_opcode;
  logic   [15:0]           rs_ex_predicted_target_addr;
  logic   [`PRF_width-1:0] rs_ex_srcA_PRF_num;
  logic   [`PRF_width-1:0] rs_ex_srcB_PRF_num;
  logic   [`PRF_width-1:0] rs_ex_dest_PRF_num;
  logic   [`ROB_width-1:0] rs_ex_ROB_num;
    

  // Outputs from EX Stage
  logic                   ex_MULT_busy_out;
  logic                   ex_CDB_arb_stall_out;
  logic                   ex_branch_mispredict_out;
  logic                   ex_branch_inst_out;
  logic                   ex_branch_taken_out;
  logic [`PRF_width-1:0]  ex_CDB_tag_out;
  logic [63:0]            ex_result_out;
  logic [15:0]            ex_NPC_out;
  logic [63:0]            debug_out;
  logic [63:0]            ex_memory_data_out;
  logic [63:0]            ex_memory_addr_out;
  // Outputs from EX/WB Pipeline Register
  logic [63:0]            ex_wb_result;
  logic [`PRF_width-1:0]  ex_wb_PRF_num;

  // Outputs from EX/MEM Pipeline Register
  logic [63:0]            ex_mem_proc2Dcache_addr;
  logic [63:0]            ex_mem_proc2Dcache_data;
  logic  [1:0]            ex_mem_proc2Dcache_command;
  logic [`PRF_width-1:0]  ex_mem_PRF_num;
  logic [`ROB_width-1:0]  ex_mem_ROB_num;
  logic                   ex_mem_ld_inst;
  logic                   ex_mem_ldl_inst;
  logic                   ex_mem_stc_inst;
  logic                   ex_mem_st_inst;

  //LL & SC

  logic flag;
  logic [15:0] ll_addr;
  logic stc_fail;
  logic stc_one_cycle;

  //Outputs from MEM Stage
  logic [63:0] ld_stc_value_in;

  logic [`ROB_width-1:0]  update_ROB_num;
  logic                   mem_store_done, mem_load_done;

  // Proc/Cache controller interface
  logic [63:0] proc2Icache_addr, proc2Dcache_addr, proc2Dcache_data;
  logic  [1:0] proc2Dcache_command;

  logic [63:0] Icache_data, Dcache_data;
  logic        Icache_valid, Dcache_done;

  //Cache Controller/Arbitration interface
  logic [63:0] Dcache2mem_addr;
  logic [63:0] Dcache2mem_data;
  logic [1:0]  Dcache2mem_command;

  logic [3:0]  arb2Icache_response, arb2Dcache_response;
  logic [63:0] arb2Icache_data, arb2Dcache_data;
  logic [3:0]  arb2Icache_tag, arb2Dcache_tag;

  //Arbitration/Mem interface
  logic [3:0]  mem2arb_response;
  logic [63:0] mem2arb_data;
  logic [3:0]  mem2arb_tag;

  logic [1:0]  arb2mem_command;
  logic [63:0] arb2mem_addr;
  logic [63:0] arb2mem_data;

  //Cache/Cache controller interface
  logic [63:0] Icachemem_data, Dcachemem_data;
  logic        Icachemem_valid, prefetch_valid, Dcache_hit_way0, Dcache_hit_way1, Dcache_dirty;
  logic [8:0]  write_back_tag;
  
  logic        victim_cache2cache_ctrl_hit;
  logic [63:0] victim_cache2cache_ctrl_data;
  logic        cache_ctrl2victim_cache_wr_en;
  logic [15:0] cache_ctrl2victim_cache_addr_in;
  logic [63:0] cache_ctrl2victim_cache_data;
  logic        cache_ctrl2victim_cache_invalidate_en;
  logic [15:0] cache_ctrl2victim_cache_invalidate_addr;

  logic [63:0] D_data_write;
  logic [3:0]  I_current_index, I_wr_index, I_prefetch_index;
  logic [8:0]  I_current_tag, I_wr_tag, I_prefetch_tag;
  logic [3:0]  D_current_index, D_last_index;
  logic [8:0]  D_current_tag, D_last_tag;
  logic        I_data_write_enable;
  logic        D_data_write_enable, D_dirty_en, D_dirty_wr;
  

  logic [3:0]  D_resp_index;
  logic [8:0]  D_resp_tag;
  logic [63:0] D_resp_data;
  logic        D_resp_hit_way0;
  logic        D_resp_hit_way1;
  logic        Dcache_lru;
  logic        write_back_way;

  // LSQ stuff
  logic  [1:0]           LSQ2Dcache_command;
  logic [15:0]           LSQ2Dcache_addr;
  logic [63:0]           LSQ2Dcache_data;
  logic [`PRF_width-1:0] LSQ2CDB_PRF_num;
  logic                  LSQ_store_done;
  logic                  LSQ_load_done;
  logic [`ROB_width-1:0] LSQ_store_ROB_num;
  logic                  LDQ_full;
  logic                  STQ_full;
  logic                  mem_inst_dispatch_disable;
  logic                  outstanding_stc_inst;
  logic                  mem_stc_done_in;
  logic                  LSQ_is_stc_inst;
  logic                  LSQ_is_ldl_inst;
  logic                  ex_mem_valid_inst;
/*  cache_arb cache_arb_0 (
    .clock(clock),
    .reset(reset),
    .Icache2mem_command(Icache2mem_command),
    .Icache2mem_addr(Icache2mem_addr),
    .Dcache2mem_command(Dcache2mem_command),
    .Dcache2mem_addr(Dcache2mem_addr),
    .Dcache2mem_data(Dcache2mem_data),
    .mem2arb_response(mem2proc_response),
    .mem2arb_data(mem2proc_data),
    .mem2arb_tag(mem2proc_tag),

    .arb2mem_command(proc2mem_command),
    .arb2mem_addr(proc2mem_addr),
    .arb2mem_data(proc2mem_data),
    .arb2Icache_response(arb2Icache_response),
    .arb2Icache_data(arb2Icache_data),
    .arb2Icache_tag(arb2Icache_tag),
    .arb2Dcache_response(arb2Dcache_response),
    .arb2Dcache_data(arb2Dcache_data),
    .arb2Dcache_tag(arb2Dcache_tag)
    );*/

  icache_ctrl icache_ctrl_0 (
    .clock(clock),
    .reset(reset),
    .Imem2proc_response(mem_arb2Icache_response),
    .Imem2proc_data(mem_arb2Icache_data),
    .Imem2proc_tag(mem_arb2Icache_tag),
    .proc2Icache_addr(proc2Icache_addr),
    .mispredict(if_predicted_taken_out | ROB_branch_mispredict_out),
    .cachemem_data(Icachemem_data),
    .cachemem_valid(Icachemem_valid),
    .prefetch_valid(prefetch_valid),

    .proc2Imem_command(Icache2mem_command),
    .proc2Imem_addr(Icache2mem_addr),
    .Icache_data_out(Icache_data),
    .Icache_valid_out(Icache_valid),
    .current_index(I_current_index),
    .current_tag(I_current_tag),
    .wr_index(I_wr_index),
    .wr_tag(I_wr_tag),
    .data_write_enable(I_data_write_enable),
    .prefetch_tag(I_prefetch_tag),
    .prefetch_index(I_prefetch_index)
    );

  icachemem icache_mem_0 (
    .clock(clock),
    .reset(reset),
    .wr1_en(I_data_write_enable),
    .wr1_idx(I_wr_index),
    .rd1_idx(I_current_index),
    .prefetch_rd_idx(I_prefetch_index),
    .wr1_tag(I_wr_tag),
    .rd1_tag(I_current_tag),
    .prefetch_rd_tag(I_prefetch_tag),
    .wr1_data(mem_arb2Icache_data),

    .rd1_data(Icachemem_data),
    .rd1_valid(Icachemem_valid),
    .prefetch_valid(prefetch_valid)
    );

  

  assign pipeline_completed_insts = {3'b0, ROB_commit_out};
  assign pipeline_error_status =  ROB_illegal_out  ? `HALTED_ON_ILLEGAL
                  : (halt && Dcache_done)? `HALTED_ON_HALT
                  : `NO_ERROR;

  assign pipeline_commit_wr_idx  = ROB_ARF_num_out;
  assign pipeline_commit_wr_data = debug_out;
  assign pipeline_commit_wr_en   = (ROB_commit_out && ROB_ARF_num_out != `ZERO_REG);
  assign pipeline_commit_NPC     = {48'b0,ROB_PC_plus_4_out};


 /* 
  assign proc2mem_command =
      (proc2Dmem_command==`BUS_NONE) ? proc2Imem_addrmem_command:proc2Dmem_command;
  assign proc2mem_addr =
      (proc2Dmem_command==`BUS_NONE) ? proc2Imem_addr:proc2Dmem_addr;
  assign Dmem2proc_response = 
      (proc2Dmem_command==`BUS_NONE) ? 0 : mem2proc_response;
  assign Imem2proc_response =
      (proc2Dmem_command==`BUS_NONE) ? mem2proc_response : 0;*/



//  assign core_mispredict = ROB_branch_mispredict_out;

  //////////////////////////////////////////////////
  //                                              //
  //                  IF-Stage                    //
  //                                              //
  //////////////////////////////////////////////////
  if_stage if_stage_0 (// Inputs
            .clock (clock),
            .reset (reset),
            .if_id_enable(if_id_enable),
            .ROB_branch_mispredict_in(ROB_branch_mispredict_out), 
            .ex_branch_inst_in(ex_branch_inst_out),
            .ex_branch_result_in(ex_branch_taken_out),
            .ex_is_uncond_branch_in(rs_ex_uncond_branch & ~ex_CDB_arb_stall_out),
            .ex_PC_plus_4_in(rs_ex_NPC[15:0]),
            .ex_NPC_in(ex_NPC_out),
            .ROB_NPC_in({48'b0,ROB_NPC_out}),
            .Imem2proc_data(Icache_data),
            .Imem_valid(Icache_valid),

            // Outputs
            .if_NPC_out(if_NPC_out), 
            .if_IR_out(if_IR_out),
            .proc2Imem_addr(proc2Icache_addr),
            .if_valid_inst_out(if_valid_inst_out),
            .if_predicted_target_addr_out(if_predicted_target_addr_out),
            .if_predicted_taken_out(if_predicted_taken_out)
          );


  //////////////////////////////////////////////////
  //                                              //
  //            IF/ID Pipeline Register           //
  //                                              //
  //////////////////////////////////////////////////
  assign if_id_enable = ~(RS_full_out | ROB_dispatch_disable | id_no_free_PRF_out 
                         | mem_inst_dispatch_disable | halt | outstanding_stc_inst);
  
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if(reset) begin
      if_id_NPC                   <= `SD 0;
      if_id_IR                    <= `SD `NOOP_INST;
      if_id_valid_inst            <= `SD `FALSE;
      if_id_predicted_target_addr <= `SD 0; 
    end // if (reset)
    else begin
      if (ROB_branch_mispredict_out | halt) begin
        if_id_NPC                   <= `SD 0;
        if_id_IR                    <= `SD `NOOP_INST;
        if_id_valid_inst            <= `SD `FALSE;
        if_id_predicted_target_addr <= `SD 0; 
      end
      else if (if_id_enable) begin
        if_id_NPC                   <= `SD {48'b0,if_NPC_out[15:0]};
        if_id_IR                    <= `SD if_IR_out;
        if_id_valid_inst            <= `SD if_valid_inst_out;
        if_id_predicted_target_addr <= `SD if_predicted_target_addr_out;
      end // if (if_id_enable)
    end
  end // always

   
  //////////////////////////////////////////////////
  //                                              //
  //                  ID-Stage                    //
  //                                              //
  //////////////////////////////////////////////////
  id_stage id_stage_0 (// Inputs
            .clock     (clock),
            .reset   (reset),
            .if_id_IR(if_id_IR),
            .if_id_valid_inst(if_id_valid_inst),
            .ROB_ARF_num_in(ROB_ARF_num_out),
            .ROB_PRF_num_in(ROB_PRF_num_out),
            .ROB_mispredict_in(ROB_branch_mispredict_out),
            .ROB_commit_in(ROB_commit_out),
            .ex_CDB_tag_in(ex_CDB_tag_out),
            .RS_full_in(RS_full_out),
            .ROB_dispatch_disable_in(ROB_dispatch_disable),
            .mem_inst_dispatch_disable(mem_inst_dispatch_disable),
            .outstanding_stc_inst(outstanding_stc_inst),
            //Hardware Trojan
            .if_id_enable(if_id_enable),
            // Outputs
            .id_opa_select_out(id_opa_select_out),
            .id_opb_select_out(id_opb_select_out),
            .id_srcA_PRF_num_out(id_srcA_PRF_num_out),
            .id_srcB_PRF_num_out(id_srcB_PRF_num_out),
            .id_ARF_num_out(id_ARF_num_out),
            .id_dest_PRF_num_out(id_dest_PRF_num_out),
            .id_srcA_valid_out(id_srcA_valid_out),
            .id_srcB_valid_out(id_srcB_valid_out),
            .id_alu_func_out(id_alu_func_out),
            .id_rd_mem_out(id_rd_mem_out),
            .id_wr_mem_out(id_wr_mem_out),
            .id_ldl_mem_out(id_ldl_mem_out),
            .id_stc_mem_out(id_stc_mem_out),
            .id_cond_branch_out(id_cond_branch_out),
            .id_uncond_branch_out(id_uncond_branch_out),
            .id_halt_out(id_halt_out),
            .id_cpuid_out(id_cpuid_out),
            .id_illegal_out(id_illegal_out),
            .id_valid_inst_out(id_valid_inst_out),
            .id_no_free_PRF_out(id_no_free_PRF_out)
          );

  // Note: Decode signals for load-lock/store-conditional and "get CPU ID"
  //  instructions (id_{ldl,stc}_mem_out, id_cpuid_out) are not connected
  //  to anything because the provided EX and MEM stages do not implement
  //  these instructions.  You will have to implement these instructions
  //  if you plan to do a multicore project.

  //////////////////////////////////////////////////
  //                                              //
  //            ID/RS Pipeline Register           //
  //                                              //
  //////////////////////////////////////////////////
  assign id_rs_enable = ~(RS_full_out | ROB_dispatch_disable | id_no_free_PRF_out 
                         | mem_inst_dispatch_disable | halt | outstanding_stc_inst);
  
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      id_rs_valid_inst            <= `SD `FALSE;
      id_rs_IR                    <= `SD `NOOP_INST;
      id_rs_NPC                   <= `SD 0;
      id_rs_opa_select            <= `SD 0; 
      id_rs_opb_select            <= `SD 0;  
      id_rs_srcA_PRF_num          <= `SD 0;   
      id_rs_srcB_PRF_num          <= `SD 0;   
      id_rs_ARF_num               <= `SD 0;   
      id_rs_dest_PRF_num          <= `SD 0;  
      id_rs_srcA_valid            <= `SD 0;
      id_rs_srcB_valid            <= `SD 0;
      id_rs_alu_func              <= `SD 0;
      id_rs_rd_mem                <= `SD 0; 
      id_rs_wr_mem                <= `SD 0;     
      id_rs_ldl_mem               <= `SD 0; 
      id_rs_stc_mem               <= `SD 0;   
      id_rs_cond_branch           <= `SD 0;  
      id_rs_uncond_branch         <= `SD 0;
      id_rs_halt                  <= `SD 0;
      id_rs_cpuid                 <= `SD 0;       
      id_rs_illegal               <= `SD 0;
      id_rs_predicted_target_addr <= `SD 0;
    end // if (reset)
    else begin
      if (ROB_branch_mispredict_out | halt) begin
        id_rs_valid_inst            <= `SD `FALSE;
        id_rs_IR                    <= `SD `NOOP_INST;
        id_rs_NPC                   <= `SD 0;
        id_rs_opa_select            <= `SD 0; 
        id_rs_opb_select            <= `SD 0;  
        id_rs_srcA_PRF_num          <= `SD 0;   
        id_rs_srcB_PRF_num          <= `SD 0; 
        id_rs_ARF_num               <= `SD 0;       
        id_rs_dest_PRF_num          <= `SD 0;  
        id_rs_srcA_valid            <= `SD 0;
        id_rs_srcB_valid            <= `SD 0;
        id_rs_alu_func              <= `SD 0;
        id_rs_rd_mem                <= `SD 0; 
        id_rs_wr_mem                <= `SD 0;     
        id_rs_ldl_mem               <= `SD 0; 
        id_rs_stc_mem               <= `SD 0;   
        id_rs_cond_branch           <= `SD 0;  
        id_rs_uncond_branch         <= `SD 0;
        id_rs_halt                  <= `SD 0;
        id_rs_cpuid                 <= `SD 0;       
        id_rs_illegal               <= `SD 0;
        id_rs_predicted_target_addr <= `SD 0;
      end
      else if (id_rs_enable) begin
        id_rs_valid_inst            <= `SD id_valid_inst_out;
        id_rs_IR                    <= `SD if_id_IR;
        id_rs_NPC                   <= `SD if_id_NPC;
        id_rs_opa_select            <= `SD id_opa_select_out; 
        id_rs_opb_select            <= `SD id_opb_select_out;  
        id_rs_srcA_PRF_num          <= `SD id_srcA_PRF_num_out;   
        id_rs_srcB_PRF_num          <= `SD id_srcB_PRF_num_out;
        id_rs_ARF_num               <= `SD id_ARF_num_out;        
        id_rs_dest_PRF_num          <= `SD id_dest_PRF_num_out;  
        id_rs_srcA_valid            <= `SD id_srcA_valid_out;
        id_rs_srcB_valid            <= `SD id_srcB_valid_out;
        id_rs_alu_func              <= `SD id_alu_func_out;
        id_rs_rd_mem                <= `SD id_rd_mem_out; 
        id_rs_wr_mem                <= `SD id_wr_mem_out;     
        id_rs_ldl_mem               <= `SD id_ldl_mem_out; 
        id_rs_stc_mem               <= `SD id_stc_mem_out;   
        id_rs_cond_branch           <= `SD id_cond_branch_out;  
        id_rs_uncond_branch         <= `SD id_uncond_branch_out;
        id_rs_halt                  <= `SD id_halt_out;
        id_rs_cpuid                 <= `SD id_cpuid_out;       
        id_rs_illegal               <= `SD id_illegal_out;
        id_rs_predicted_target_addr <= `SD if_id_predicted_target_addr;
      end 
    end // else: !if(reset)
  end // always


  //////////////////////////////////////////////////
  //                                              //
  //                  RS-Stage                    //
  //                                              //
  //////////////////////////////////////////////////
  rs_stage rs_stage_0 (// Inputs
            .clock(clock),
            .reset(reset),
            .id_rs_srcA_valid_in(id_rs_srcA_valid),
            .id_rs_srcB_valid_in(id_rs_srcB_valid),
            .id_rs_valid_inst_in(id_rs_valid_inst),
            .id_rs_uncond_branch_in(id_rs_uncond_branch),
            .id_rs_cond_branch_in(id_rs_cond_branch),
            .id_rs_rd_mem_in(id_rs_rd_mem),
            .id_rs_wr_mem_in(id_rs_wr_mem),
            .id_rs_ldl_in(id_rs_ldl_mem),
            .id_rs_stc_in(id_rs_stc_mem),
            .id_rs_cpuid_in(id_rs_cpuid),
            .id_rs_illegal_in(id_rs_illegal),
            .id_rs_halt_in(id_rs_halt),
            .id_rs_opa_select_in(id_rs_opa_select),
            .id_rs_opb_select_in(id_rs_opb_select),
            .id_rs_opcode_in(id_rs_alu_func),
            .id_rs_IR_in(id_rs_IR),
            .id_rs_PC_plus_4_in(id_rs_NPC[15:0]),
            .id_rs_predicted_target_addr_in(id_rs_predicted_target_addr),
            .id_rs_srcA_PRF_num_in(id_rs_srcA_PRF_num),
            .id_rs_srcB_PRF_num_in(id_rs_srcB_PRF_num),
            .id_rs_ARF_num_in(id_rs_ARF_num),
            .id_rs_dest_PRF_num_in(id_rs_dest_PRF_num),
            .ex_CDB_tag_in(ex_CDB_tag_out),
            .ex_NPC_in(ex_NPC_out),
            .ex_MULT_busy_in(ex_MULT_busy_out),
            .ex_CDB_arb_stall_in(ex_CDB_arb_stall_out),
            .ex_branch_mispredict_in(ex_branch_mispredict_out),
            .ex_branch_inst_in(ex_branch_inst_out),
            .id_no_free_PRF_in(id_no_free_PRF_out),
            .mem_stc_done_in(mem_stc_done_in),
            .mem_store_done_in(mem_store_done),
            .update_ROB_num_in(update_ROB_num),
            .Dcache_done(Dcache_done),
            .mem_inst_dispatch_disable(mem_inst_dispatch_disable),

            .RS_full_out(RS_full_out),
            .RS_valid_inst_out(RS_valid_inst_out),
            .RS_uncond_branch_out(RS_uncond_branch_out),
            .RS_cond_branch_out(RS_cond_branch_out),
            .RS_rd_mem_out(RS_rd_mem_out),
            .RS_wr_mem_out(RS_wr_mem_out),
            .RS_ldl_out(RS_ldl_out),
            .RS_stc_out(RS_stc_out),
            .RS_cpuid_out(RS_cpuid_out),
            .RS_opa_select_out(RS_opa_select_out),
            .RS_opb_select_out(RS_opb_select_out),
            .RS_opcode_out(RS_opcode_out),
            .RS_IR_out(RS_IR_out),
            .RS_PC_plus_4_out(RS_PC_plus_4_out),
            .RS_predicted_target_addr_out(RS_predicted_target_addr_out),
            .RS_srcA_PRF_num_out(RS_srcA_PRF_num_out),
            .RS_srcB_PRF_num_out(RS_srcB_PRF_num_out),
            .RS_dest_PRF_num_out(RS_dest_PRF_num_out),
            .RS_ROB_num_out(RS_ROB_num_out),
            .ROB_ARF_num_out(ROB_ARF_num_out),
            .ROB_PRF_num_out(ROB_PRF_num_out),
            .ROB_PC_plus_4_out(ROB_PC_plus_4_out),
            .ROB_NPC_out(ROB_NPC_out),
            .ROB_branch_mispredict_out(ROB_branch_mispredict_out),
            .ROB_is_store_inst_out(ROB_is_store_inst_out),
            .ROB_is_branch_inst_out(ROB_is_branch_inst_out),
            .ROB_commit_out(ROB_commit_out),
            .ROB_dispatch_disable(ROB_dispatch_disable),
            .ROB_head(ROB_head),
            .ROB_tail(ROB_tail),
            .ROB_illegal_out(ROB_illegal_out),
            .ROB_halt_out(ROB_halt_out),
            .outstanding_stc_inst(outstanding_stc_inst)
            
          );


  //////////////////////////////////////////////////
  //                                              //
  //           RS/EX Pipeline Register            //
  //                                              //
  //////////////////////////////////////////////////
  assign rs_ex_enable = ~(ex_CDB_arb_stall_out | halt);
  
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock)
  begin
    if (reset) begin
      rs_ex_uncond_branch         <= `SD 0;
      rs_ex_cond_branch           <= `SD 0;
      rs_ex_st_inst               <= `SD 0;
      rs_ex_ld_inst               <= `SD 0;
      rs_ex_stc_inst              <= `SD 0;
      rs_ex_ldl_inst              <= `SD 0;
      rs_ex_cpuid                 <= `SD 0;
      rs_ex_opa_select            <= `SD 0; 
      rs_ex_opb_select            <= `SD 0;
      rs_ex_opcode                <= `SD 0;
      rs_ex_predicted_target_addr <= `SD 0;
      rs_ex_srcA_PRF_num          <= `SD 0;
      rs_ex_srcB_PRF_num          <= `SD 0;
      rs_ex_dest_PRF_num          <= `SD 0;
      rs_ex_ROB_num               <= `SD 0;
      rs_ex_NPC                   <= `SD 0;
      rs_ex_IR                    <= `SD `NOOP_INST;
      rs_ex_valid_inst            <= `SD `FALSE;
    end
    else begin
      if (ROB_branch_mispredict_out | halt) begin
        rs_ex_uncond_branch         <= `SD 0;
        rs_ex_cond_branch           <= `SD 0;
        rs_ex_st_inst               <= `SD 0;
        rs_ex_ld_inst               <= `SD 0;
        rs_ex_stc_inst              <= `SD 0;
        rs_ex_ldl_inst              <= `SD 0;
        rs_ex_cpuid                 <= `SD 0;
        rs_ex_opa_select            <= `SD 0; 
        rs_ex_opb_select            <= `SD 0;
        rs_ex_opcode                <= `SD 0;
        rs_ex_predicted_target_addr <= `SD 0;
        rs_ex_srcA_PRF_num          <= `SD 0;
        rs_ex_srcB_PRF_num          <= `SD 0;
        rs_ex_dest_PRF_num          <= `SD 0;
        rs_ex_ROB_num               <= `SD 0;
        rs_ex_NPC                   <= `SD 0;
        rs_ex_IR                    <= `SD `NOOP_INST;
        rs_ex_valid_inst            <= `SD `FALSE;
      end // if
      else if (rs_ex_enable) begin
        rs_ex_uncond_branch         <= `SD RS_uncond_branch_out;
        rs_ex_cond_branch           <= `SD RS_cond_branch_out;
        rs_ex_st_inst               <= `SD RS_wr_mem_out; 
        rs_ex_ld_inst               <= `SD RS_rd_mem_out; 
        rs_ex_stc_inst              <= `SD RS_stc_out; 
        rs_ex_ldl_inst              <= `SD RS_ldl_out; 
        rs_ex_cpuid                 <= `SD RS_cpuid_out; // To be implemented
        rs_ex_opa_select            <= `SD RS_opa_select_out; 
        rs_ex_opb_select            <= `SD RS_opb_select_out;
        rs_ex_opcode                <= `SD RS_opcode_out;
        rs_ex_predicted_target_addr <= `SD RS_predicted_target_addr_out;
        rs_ex_srcA_PRF_num          <= `SD RS_srcA_PRF_num_out;
        rs_ex_srcB_PRF_num          <= `SD RS_srcB_PRF_num_out;
        rs_ex_dest_PRF_num          <= `SD RS_dest_PRF_num_out;
        rs_ex_ROB_num               <= `SD RS_ROB_num_out;
        rs_ex_NPC                   <= `SD {48'b0,RS_PC_plus_4_out};
        rs_ex_IR                    <= `SD RS_IR_out;
        rs_ex_valid_inst            <= `SD RS_valid_inst_out;
      end
    end // else: !if(reset)
  end // always

   
  //////////////////////////////////////////////////
  //                                              //
  //                 EX-Stage                    //
  //                                              //
  //////////////////////////////////////////////////
  ex_stage ex_stage_0 (// Inputs
              .clock(clock),
              .reset(reset),
              .CPU_ID(CPU_ID),
              .rs_ex_uncond_branch_in(rs_ex_uncond_branch),
              .rs_ex_cond_branch_in(rs_ex_cond_branch),
              .rs_ex_st_inst_in(rs_ex_st_inst),
              .rs_ex_ld_inst_in(rs_ex_ld_inst),
              .rs_ex_stc_inst_in(rs_ex_stc_inst),
              .rs_ex_ldl_inst_in(rs_ex_ldl_inst),
              .rs_ex_cpuid_inst_in(rs_ex_cpuid),
              .rs_ex_opa_select_in(rs_ex_opa_select),
              .rs_ex_opb_select_in(rs_ex_opb_select),
              .rs_ex_opcode_in(rs_ex_opcode),
              .rs_ex_IR_in(rs_ex_IR),
              .rs_ex_PC_plus_4_in(rs_ex_NPC[15:0]),
              .rs_ex_predicted_target_addr_in(rs_ex_predicted_target_addr),
              .rs_ex_srcA_PRF_num_in(rs_ex_srcA_PRF_num),
              .rs_ex_srcB_PRF_num_in(rs_ex_srcB_PRF_num),
              .rs_ex_dest_PRF_num_in(rs_ex_dest_PRF_num),
              .dcacheCtrl_ld_stc_PRF_num_in(ex_mem_PRF_num), 
              .dcacheCtrl_ld_stc_ready_in(mem_load_done | (LSQ_is_stc_inst && (Dcache_done || stc_fail))), 
              .dcacheCtrl_ld_stc_value_in(ld_stc_value_in), 
              .ex_wb_result_in(ex_wb_result),
              .ex_wb_PRF_num_in(ex_wb_PRF_num),
              .debug_rd_idx_in(ROB_PRF_num_out),
              .mem_store_done_in(mem_store_done),
              .ROB_branch_mispredict_in(ROB_branch_mispredict_out),
              //.otherProc_st_stc_in(otherProc_st_stc_in), //To be implemented
              //.otherProc_st_stc_addr_in(otherProc_st_stc_addr_in),//To be implemented
              //.stc_must_fail(stc_must_fail),
              //.ex_mem_ldl_inst(ex_mem_ldl_inst),

              .ex_MULT_busy_out(ex_MULT_busy_out),
              .ex_CDB_arb_stall_out(ex_CDB_arb_stall_out),
              .ex_branch_mispredict_out(ex_branch_mispredict_out),
              .ex_branch_inst_out(ex_branch_inst_out),
              .ex_branch_taken_out(ex_branch_taken_out),
              .ex_CDB_tag_out(ex_CDB_tag_out),
              .ex_result_out(ex_result_out),
              .ex_NPC_out(ex_NPC_out),
              .ex_memory_addr_out(ex_memory_addr_out),
              .ex_memory_data_out(ex_memory_data_out),
              //.stc_fail(stc_fail),
              //.to_OtherProc_st_stc_out(to_OtherProc_st_stc_out),
              //.to_OtherProc_stc_out(to_OtherProc_stc_out),
              //.to_OtherProc_st_addr_out(to_OtherProc_st_addr_out),
              .debug_out(debug_out)
            );

  //////////////////////////////////////////////////
  //                                              //
  //           EX/WB Pipeline Buffer              //
  //                                              //
  //////////////////////////////////////////////////
  assign ex_wb_enable = 1'b1; // always enabled
  
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock)
  begin
    if (reset) begin
      ex_wb_result     <= `SD 0;
      ex_wb_PRF_num    <= `SD 0;
    end
    else begin
      if (ROB_branch_mispredict_out | halt) begin
        ex_wb_result     <= `SD 0;
        ex_wb_PRF_num    <= `SD 0; 
      end // if
      else if (ex_wb_enable) begin
        ex_wb_result     <= `SD ex_result_out;
        ex_wb_PRF_num    <= `SD ex_CDB_tag_out;
      end
    end // else: !if(reset)
  end // always

  //////////////////////////////////////////////////
  //                                              //
  //           EX/MEM Pipeline Buffer             //
  //                                              //
  //////////////////////////////////////////////////
//  assign ex_mem_enable = 1'b1; // always enabled
  // synopsys sync_set_reset "reset"
  /*logic [1:0] next_bus_command;

  always_comb begin
    next_bus_command = `BUS_NONE;
    if (rs_ex_ld_inst)
      next_bus_command = `BUS_LOAD;
    else if (rs_ex_st_inst)
      next_bus_command = `BUS_STORE;
  end*/

  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset)
      halt <= `SD 0;
    else begin
      if (ROB_halt_out)
        halt <= `SD 1;
    end
  end

  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock)
  begin
    if (reset) begin
//      ex_mem_NPC                 <= `SD 0;
//      ex_mem_IR                  <= `SD `NOOP_INST;
      ex_mem_valid_inst          <= `SD `FALSE;
      ex_mem_proc2Dcache_addr    <= `SD 0;  
      ex_mem_proc2Dcache_data    <= `SD 0;
     // ex_mem_proc2Dcache_command <= `SD `BUS_NONE;
//      ex_mem_PRF_num             <= `SD 0;
      ex_mem_ROB_num             <= `SD 0;
      ex_mem_ld_inst             <= `SD 0;
      ex_mem_ldl_inst            <= `SD 0;
      ex_mem_st_inst             <= `SD 0;
      ex_mem_stc_inst            <= `SD 0;
    end
    else begin
      if (ROB_branch_mispredict_out | halt) begin
//        ex_mem_NPC                 <= `SD 0;
//        ex_mem_IR                  <= `SD `NOOP_INST;
        ex_mem_valid_inst          <= `SD `FALSE;
        ex_mem_proc2Dcache_addr    <= `SD 0;  
        ex_mem_proc2Dcache_data    <= `SD 0;
       // ex_mem_proc2Dcache_command <= `SD `BUS_NONE;
//        ex_mem_PRF_num             <= `SD 0;
        ex_mem_ROB_num             <= `SD 0;
        ex_mem_ld_inst             <= `SD 0;
        ex_mem_ldl_inst            <= `SD 0;
        ex_mem_st_inst             <= `SD 0;
        ex_mem_stc_inst            <= `SD 0;
      end
      else if ((rs_ex_ld_inst |  rs_ex_ldl_inst | rs_ex_stc_inst | rs_ex_st_inst) & ~ex_CDB_arb_stall_out) begin
//        ex_mem_NPC                 <= `SD rs_ex_NPC;
//        ex_mem_IR                  <= `SD rs_ex_IR;
        ex_mem_valid_inst          <= `SD rs_ex_valid_inst;
        ex_mem_proc2Dcache_addr    <= `SD ex_memory_addr_out;  
        ex_mem_proc2Dcache_data    <= `SD ex_memory_data_out;
       // ex_mem_proc2Dcache_command <= `SD next_bus_command;
//        ex_mem_PRF_num             <= `SD rs_ex_dest_PRF_num;
        ex_mem_ROB_num             <= `SD rs_ex_ROB_num;
        ex_mem_ld_inst             <= `SD rs_ex_ld_inst;
        ex_mem_ldl_inst            <= `SD rs_ex_ldl_inst;
        ex_mem_st_inst             <= `SD rs_ex_st_inst;
        ex_mem_stc_inst            <= `SD rs_ex_stc_inst;
      end
/*      else if ((Dcache_done && (proc2Dcache_command != `BUS_NONE)) || stc_fail) begin
        ex_mem_NPC                 <= `SD 0;
        ex_mem_IR                  <= `NOOP_INST; 
        ex_mem_valid_inst          <= `FALSE;
        ex_mem_proc2Dcache_addr    <= `SD 0;  
        ex_mem_proc2Dcache_data    <= `SD 0;
       // ex_mem_proc2Dcache_command <= `SD `BUS_NONE;
        ex_mem_PRF_num             <= `SD 0;
        ex_mem_ROB_num             <= `SD 0;
        ex_mem_ld_inst             <= `SD 0;
        ex_mem_ldl_inst            <= `SD 0;
        ex_mem_st_inst             <= `SD 0;
        ex_mem_stc_inst            <= `SD 0;
      end*/
    end // else: !if(reset)
  end // always


  //LL&SC 



  assign otherProc_st_stc_same_addr = (ll_addr == otherProc_st_stc_addr_in) && otherProc_st_stc_in;
  assign to_OtherProc_st_stc_out  = ((LSQ2Dcache_command == `BUS_STORE && !LSQ_is_stc_inst) || (LSQ_is_stc_inst && flag == 1) && !ROB_branch_mispredict_out);
  assign to_OtherProc_stc_out     = LSQ_is_stc_inst && !ROB_branch_mispredict_out && flag == 1;
  assign to_OtherProc_st_addr_out = LSQ2Dcache_command == `BUS_STORE ? LSQ2Dcache_addr : 16'hFFFF;
  assign stc_fail = (LSQ_is_stc_inst && (flag == 0 || stc_must_fail)) || ROB_branch_mispredict_out;
  assign ld_stc_value_in = (LSQ_is_stc_inst && (Dcache_done || stc_fail)) ? ({63'b0, !stc_fail}) : Dcache_data;
  
  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset)
      flag <= `SD 0;
    else begin
      if (ROB_branch_mispredict_out)
        flag <= `SD 0;
      else if (LSQ_is_ldl_inst && !((LSQ2Dcache_addr == otherProc_st_stc_addr_in) && otherProc_st_stc_in))
        flag <= `SD 1;
      else if (LSQ_is_stc_inst && !stc_must_fail);

      else if (otherProc_st_stc_same_addr || (LSQ_is_stc_inst && (Dcache_done || stc_fail)))
        flag <= `SD 0;
      
    end
  end
  
  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset)
      ll_addr <= `SD 0;
    else begin
      if (ROB_branch_mispredict_out)
        ll_addr <= `SD 0;
      else if (LSQ_is_ldl_inst)
        ll_addr <= `SD LSQ2Dcache_addr;
    end
  end

/*  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset)
      stc_one_cycle <= `SD 1;
    else begin
      if (mem_store_done)
        stc_one_cycle <= `SD 1;
      else if (LSQ_is_stc_inst)
        stc_one_cycle <= `SD 0;
    end
  end*/


  //////////////////////////////////////////////////
  //                                              //
  //                  MEM-Stage                   //
  //                                              //
  //////////////////////////////////////////////////

  assign proc2Dcache_addr    = LSQ2Dcache_addr;
  assign proc2Dcache_data    = LSQ2Dcache_data;
  assign proc2Dcache_command = ROB_branch_mispredict_out ? `BUS_NONE : halt ? `BUS_WRITE_BACK :
                               (ROB_is_store_inst_out && ((LSQ2Dcache_command == `BUS_STORE && !LSQ_is_stc_inst) || (LSQ2Dcache_command == `BUS_STORE && !stc_fail))) ?
                               `BUS_STORE : (LSQ_is_ldl_inst | LSQ2Dcache_command == `BUS_LOAD) ?
                               `BUS_LOAD : `BUS_NONE;

  assign mem_store_done      = (Dcache_done && (proc2Dcache_command == `BUS_STORE)) || (LSQ_is_stc_inst && (stc_fail || Dcache_done));
  assign mem_load_done       = Dcache_done && (proc2Dcache_command == `BUS_LOAD);
  assign update_ROB_num      = ((Dcache_done && (proc2Dcache_command == `BUS_STORE)) || (LSQ_is_stc_inst)) ? LSQ_store_ROB_num : rs_ex_ROB_num;

  assign mem_inst_dispatch_disable = LDQ_full | STQ_full;
  assign mem_stc_done_in     = LSQ_store_done && LSQ_is_stc_inst;
  assign ex_mem_valid_inst_out = LSQ2Dcache_command != `BUS_NONE;
  LSQ lsq_0 (
    .clock(clock),
    .reset(reset),
    .mispredict(ROB_branch_mispredict_out),
    .id_rs_valid_inst(id_rs_valid_inst),
    .id_rs_rd_mem(id_rs_rd_mem),
    .id_rs_wr_mem(id_rs_wr_mem),
    .id_rs_ldl(id_rs_ldl_mem),
    .id_rs_stc(id_rs_stc_mem),
    .id_rs_dest_PRF_num(id_rs_dest_PRF_num),
    .ROB_head(ROB_head),
    .ROB_tail(ROB_tail),
    .ex_mem_ROB_num(ex_mem_ROB_num),
    .ROB_is_store_inst(ROB_is_store_inst_out),
    .ex_mem_ld_inst(ex_mem_ld_inst && ex_mem_valid_inst),
    .ex_mem_ldl_inst(ex_mem_ldl_inst && ex_mem_valid_inst),
    .ex_mem_st_inst(ex_mem_st_inst && ex_mem_valid_inst),
    .ex_mem_stc_inst(ex_mem_stc_inst && ex_mem_valid_inst),
    .ex_mem_proc2Dcache_addr(ex_mem_proc2Dcache_addr[15:0]),
    .ex_mem_proc2Dcache_data(ex_mem_proc2Dcache_data),
    .Dcache2proc_done(Dcache_done),
    .id_no_free_PRF(id_no_free_PRF_out),
    .ROB_dispatch_disable(ROB_dispatch_disable),
    .mem_inst_dispatch_disable(mem_inst_dispatch_disable),
    .RS_full(RS_full_out),
    .id_rs_NPC(id_rs_NPC[15:0]),
    .id_rs_IR(id_rs_IR),
    .ex_CDB_arb_stall(ex_CDB_arb_stall_out),
    .stc_fail(stc_fail),

    .LSQ2Dcache_command(LSQ2Dcache_command),
    .LSQ2Dcache_addr(LSQ2Dcache_addr),
    .LSQ2Dcache_data(LSQ2Dcache_data),
    .LSQ2CDB_PRF_num(ex_mem_PRF_num),
    .LSQ_store_done(LSQ_store_done),
    .LSQ_load_done(LSQ_load_done),
    .LSQ_store_ROB_num(LSQ_store_ROB_num),
    .LDQ_full(LDQ_full),
    .STQ_full(STQ_full),
    .LSQ_NPC_out(ex_mem_NPC[15:0]),
    .LSQ_IR_out(ex_mem_IR),
    .LSQ_is_stc_inst(LSQ_is_stc_inst),
    .LSQ_is_ldl_inst(LSQ_is_ldl_inst)
    );


/*  dcache_ctrl dcache_ctrl_0 (
    .clock(clock),
    .reset(reset),
    .proc2Dcache_addr(proc2Dcache_addr),
    .proc2Dcache_data(proc2Dcache_data),
    .proc2Dcache_command(proc2Dcache_command),
    .mispredict(ROB_branch_mispredict_out),
    .mem_response(arb2Dcache_response),
    .mem_data(arb2Dcache_data),
    .mem_tag(arb2Dcache_tag),
    .Dcachemem_data(Dcachemem_data),
    .Dcache_hit(Dcache_hit),
    .Dcache_dirty(Dcache_dirty),
    .write_back_tag(write_back_tag),

    .Dcache_done(Dcache_done),
    .Dcache_data_out(Dcache_data),
    .Dcache2mem_command(Dcache2mem_command),
    .Dcache2mem_addr(Dcache2mem_addr),
    .Dcache2mem_data(Dcache2mem_data),
    .data_write(D_data_write),
    .current_index(D_current_index),
    .current_tag(D_current_tag),
    .last_index(D_last_index),
    .last_tag(D_last_tag),
    .data_write_enable(D_data_write_enable),
    .dirty_in(D_dirty_en),
    .dirty_wr(D_dirty_wr)

    );*/
  
  dcache_ctrl0 dctrl (
    .clock(clock),
    .reset(reset),
    .mispredict(ROB_branch_mispredict_out),
    .CPU_ID(CPU_ID),
  // inputs
  // proc2cache
    .proc2Dcache_addr(proc2Dcache_addr[15:0]),
    .proc2Dcache_data(proc2Dcache_data),
    .proc2Dcache_command(proc2Dcache_command),
  // req_bus
    .req_bus_addr(req_bus_addr),
    .req_bus_command(req_bus_command),
    .req_bus_source(req_bus_source),
  // resp_bus
    .resp_bus_data(resp_bus_data),
//  input  [2:0] resp_bus_dest(),        // bit0 for proc0(), bit1 for proc1(), bit2 for mem
    .resp_bus_valid(resp_bus_valid),
  // hit/hitm_bus
    .hit_bus(hit_bus),
    .hitm_bus(hitm_bus),
  // cache2cache_ctrl
    .cache2cache_ctrl_tag(write_back_tag),
    .cache2cache_ctrl_data(Dcachemem_data),
    .cache2cache_ctrl_resp_data(D_resp_data),
    .cache2cache_ctrl_hit_way0(Dcache_hit_way0),
    .cache2cache_ctrl_hit_way1(Dcache_hit_way1),
    .cache2cache_ctrl_resp_hit_way0(D_resp_hit_way0),
    .cache2cache_ctrl_resp_hit_way1(D_resp_hit_way1),
    .cache2cache_ctrl_lru(Dcache_lru),
  // victim_cache2cache_ctrl
    .victim_cache2cache_ctrl_hit(victim_cache2cache_ctrl_hit),
    .victim_cache2cache_ctrl_data(victim_cache2cache_ctrl_data),
  // mem2cache_ctrl
    .mem_response(mem_response),                  // from
    .mem_tag(mem_tag),                       // arbiter
  // outputs
  // cache_ctrl2proc
    .cache_ctrl2proc_done_out(Dcache_done),
    .cache_ctrl2proc_data_out(Dcache_data),
  // cache_ctrl2resp_bus
    .cache_ctrl2resp_bus_data(cache_ctrl2resp_bus_data),
    .cache_ctrl2resp_bus_valid(cache_ctrl2resp_bus_valid),
//  output logic  [2:0] cache_ctrl2resp_bus_dest(),
  // cache_ctrl2req_bus
    .cache_ctrl2req_bus_data(cache_ctrl2req_bus_data),
    .cache_ctrl2req_bus_addr(cache_ctrl2req_bus_addr),
    .cache_ctrl2req_bus_command(cache_ctrl2req_bus_command),
  // cache_ctrl2cache
    .cache_ctrl2cache_wr_en(D_data_write_enable),
    .cache_ctrl2cache_index(D_current_index),
    .cache_ctrl2cache_tag(D_current_tag),
    .cache_ctrl2cache_resp_index(D_resp_index),
    .cache_ctrl2cache_resp_tag(D_resp_tag),
    .cache_ctrl2cache_data(D_data_write),
  // cache_ctrl2victim_cache
    .cache_ctrl2victim_cache_wr_en(cache_ctrl2victim_cache_wr_en),
    .cache_ctrl2victim_cache_addr_in(cache_ctrl2victim_cache_addr_in),
    .cache_ctrl2victim_cache_data(cache_ctrl2victim_cache_data),
    .cache_ctrl2victim_cache_invalidate_en(cache_ctrl2victim_cache_invalidate_en),
    .cache_ctrl2victim_cache_invalidate_addr(cache_ctrl2victim_cache_invalidate_addr),
  // cache_ctrl2hit/hitm
    .cache_ctrl2hit(cache_ctrl2hit),
    .cache_ctrl2hitm(cache_ctrl2hitm),
    .cache_ctrl_state(cache_ctrl_state),

    .write_back(write_back),
    .write_back_way_out(write_back_way)
    );

  victim_cache vc_0 (
    .clock(clock),
    .reset(reset),
    .wr_en(cache_ctrl2victim_cache_wr_en),
    .invalidate_en(cache_ctrl2victim_cache_invalidate_en),
    .addr_in(cache_ctrl2victim_cache_addr_in),
    .invalidate_addr(cache_ctrl2victim_cache_invalidate_addr),
    .data_in(cache_ctrl2victim_cache_data),
    .hit_out(victim_cache2cache_ctrl_hit),
    .data_out(victim_cache2cache_ctrl_data)
    );

  dcachemem dcachemem_0 (
    .clock(clock),
    .reset(reset),
    .wr_en(D_data_write_enable),
    .index_in(D_current_index),
    .tag_in(D_current_tag),
    .resp_index_in(D_resp_index),
    .resp_tag_in(D_resp_tag),
    .data_in(D_data_write),
    .write_back(write_back),
    .write_back_way(write_back_way),

    .tag_out(write_back_tag),
    .data_out(Dcachemem_data),
    .resp_data_out(D_resp_data),
    .hit_way0(Dcache_hit_way0),
    .hit_way1(Dcache_hit_way1),
    .resp_hit_way0(D_resp_hit_way0),
    .resp_hit_way1(D_resp_hit_way1),
    .lru_out(Dcache_lru)
    );

endmodule  // module verisimple
