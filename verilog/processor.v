/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  processor.v                                         //
//                                                                     //
//  Description :  Top-level module of the processor                   //
//                                                                     //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps

module processor(
        input         clock,             // System clock
        input         reset,             // System reset
        input [3:0]   mem2proc_response, // Tag from memory about current request
        input [63:0]  mem2proc_data,     // Data coming back from memory
        input [3:0]   mem2proc_tag,      // Tag from memory about current reply

        output logic [1:0]  proc2mem_command,  // command sent to memory
        output logic [63:0] proc2mem_addr,     // Address sent to memory
        output logic [63:0] proc2mem_data,     // Data sent to memory*/

        //For core 0
        // debugging outputs
        output logic [3:0]  core0_pipeline_completed_insts,
        output logic [3:0]  core0_pipeline_error_status,
        output logic [4:0]  core0_pipeline_commit_wr_idx,
        output logic [63:0] core0_pipeline_commit_wr_data,
        output logic        core0_pipeline_commit_wr_en,
        output logic [63:0] core0_pipeline_commit_NPC,
        output logic        core0_halt,
        // Outputs from IF-Stage 
        output logic [63:0] core0_if_NPC_out,
        output logic [31:0] core0_if_IR_out,
        output logic        core0_if_valid_inst_out,
        
        // Outputs from IF/ID Pipeline Register
        output logic [63:0] core0_if_id_NPC,
        output logic [31:0] core0_if_id_IR,
        output logic        core0_if_id_valid_inst,
        
        
        // Outputs from ID/RS Pipeline Register
        output logic [63:0] core0_id_rs_NPC,
        output logic [31:0] core0_id_rs_IR,
        output logic        core0_id_rs_valid_inst,
        
        
        // Outputs from RS/EX Pipeline Register
        output logic [63:0] core0_rs_ex_NPC,
        output logic [31:0] core0_rs_ex_IR,
        output logic        core0_rs_ex_valid_inst,
        
        
        // Outputs from EX/MEM Pipeline Register
        output logic [63:0] core0_ex_mem_NPC,
        output logic [31:0] core0_ex_mem_IR,
        output logic        core0_ex_mem_valid_inst,

        //For core 1
        // debugging outputs
        output logic [3:0]  core1_pipeline_completed_insts,
        output logic [3:0]  core1_pipeline_error_status,
        output logic [4:0]  core1_pipeline_commit_wr_idx,
        output logic [63:0] core1_pipeline_commit_wr_data,
        output logic        core1_pipeline_commit_wr_en,
        output logic [63:0] core1_pipeline_commit_NPC,
        output logic        core1_halt,
        // Outputs from IF-Stage 
        output logic [63:0] core1_if_NPC_out,
        output logic [31:0] core1_if_IR_out,
        output logic        core1_if_valid_inst_out,
        
        // Outputs from IF/ID Pipeline Register
        output logic [63:0] core1_if_id_NPC,
        output logic [31:0] core1_if_id_IR,
        output logic        core1_if_id_valid_inst,
        
        
        // Outputs from ID/RS Pipeline Register
        output logic [63:0] core1_id_rs_NPC,
        output logic [31:0] core1_id_rs_IR,
        output logic        core1_id_rs_valid_inst,
        
        
        // Outputs from RS/EX Pipeline Register
        output logic [63:0] core1_rs_ex_NPC,
        output logic [31:0] core1_rs_ex_IR,
        output logic        core1_rs_ex_valid_inst,
        
        
        // Outputs from EX/MEM Pipeline Register
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

  //Interconnection between bus_arbiter and mem_arbiter
  logic  [1:0] bus_arbiter2mem_command;
  logic [15:0] bus_arbiter2mem_addr;
  logic [63:0] bus_arbiter2mem_data;
  
  logic  [3:0] mem_arb2bus_arb_response;


  //Interconnection between icache_ctrl0&1 and mem_arbiter
  logic  [1:0] icache_ctrl02mem_command;
  logic [63:0] icache_ctrl02mem_addr;

  logic  [3:0] mem_arb2icache_ctrl0_response;

  logic  [1:0] icache_ctrl12mem_command;
  logic [63:0] icache_ctrl12mem_addr;
  
  logic  [3:0] mem_arb2icache_ctrl1_response;


  //Interconnection between mem_arbiter and all receiver
  logic  [3:0] mem_arb_tag_out;
  logic [63:0] mem_arb_data_out;

  //Interconnection between dcache_ctrl0&1 and bus_arbiter
  logic cache_ctrl0_state;
  logic cache_ctrl02hit;
  logic cache_ctrl02hitm;
  logic [63:0] cache_ctrl02req_bus_data;
  logic [15:0] cache_ctrl02req_bus_addr;
  logic  [1:0] cache_ctrl02req_bus_command;
  logic [63:0] cache_ctrl02resp_bus_data;
  logic        cache_ctrl02resp_bus_valid;

  logic [3:0]  mem_response2ctrl0;

  logic cache_ctrl1_state;
  logic cache_ctrl12hit;
  logic cache_ctrl12hitm;
  logic [63:0] cache_ctrl12req_bus_data;
  logic [15:0] cache_ctrl12req_bus_addr;
  logic  [1:0] cache_ctrl12req_bus_command;
  logic [63:0] cache_ctrl12resp_bus_data;
  logic        cache_ctrl12resp_bus_valid;

  logic [3:0] mem_response2ctrl1;

  //BUS
  logic [15:0] req_bus_addr;
  logic  [1:0] req_bus_command;
  logic  [2:0] req_bus_source;
  // outputs to resp bus
  logic [63:0] resp_bus_data;
  logic        resp_bus_valid;

  logic [3:0] mem_tag2ctrl;
  logic hit_bus;
  logic hitm_bus;


  logic        stc_must_fail;
  logic        core02core1_st_stc, core12core0_st_stc;
  logic        core02arb_stc, core12arb_stc;
  logic [15:0] core02core1_st_stc_addr, core12core0_st_stc_addr;
  logic        core0_mispredict, core1_mispredict;

  //assign stc_must_fail = (core02arb_stc == 1 && core12arb_stc == 1);
  assign icache_ctrl12mem_command = 0;
  assign cache_ctrl1_state = 0;
  assign cache_ctrl12hit = 0;
  assign cache_ctrl12hitm = 0;
  assign cache_ctrl12req_bus_command = 0;
  assign cache_ctrl12resp_bus_valid = 0;

  mem_arbiter mem_arbiter_0 (
      .clock(clock), 
      .reset(reset),
      // inputs from bus_arbiter
      .bus_arbiter2mem_command(bus_arbiter2mem_command),
      .bus_arbiter2mem_addr(bus_arbiter2mem_addr),
      .bus_arbiter2mem_data(bus_arbiter2mem_data),
      // inputs from icache_ctrl0
      .icache_ctrl02mem_command(icache_ctrl02mem_command),
      .icache_ctrl02mem_addr(icache_ctrl02mem_addr[15:0]),
      // inputs from icache_ctrl1
      .icache_ctrl12mem_command(icache_ctrl12mem_command),
      .icache_ctrl12mem_addr(icache_ctrl12mem_addr[15:0]),
      // inputs from mem
      .mem_data(mem2proc_data),
      .mem_tag(mem2proc_tag),
      .mem_response(mem2proc_response),
      // outputs to bus_arbiter
    //  output logic [63:0] mem_arb2bus_arb_data(),
      .mem_arb2bus_arb_response(mem_arb2bus_arb_response),
    //  output logic  [3:0] mem_arb2bus_arb_tag(),
      // outputs to icache_ctrl0
    //  output logic [63:0] mem_arb2icache_ctrl0_data(),
      .mem_arb2icache_ctrl0_response(mem_arb2icache_ctrl0_response),
      // outputs to icache_ctrl1
    //  output logic [63:0] mem_arb2icache_ctrl1_data(),
      .mem_arb2icache_ctrl1_response(mem_arb2icache_ctrl1_response),
      // tag output
      .mem_arb_tag_out(mem_arb_tag_out),
      .mem_arb_data_out(mem_arb_data_out),
      // outputs to mem
      .mem_arb2mem_data(proc2mem_data),
      .mem_arb2mem_addr(proc2mem_addr),
      .mem_arb2mem_command(proc2mem_command)
    );

  bus_arbiter bus_arbiter_0 (
      .clock(clock),
      .reset(reset),
      // inputs from dcache ctrl0
      .cache_ctrl0_state(cache_ctrl0_state),
      .cache_ctrl02hit(cache_ctrl02hit),
      .cache_ctrl02hitm(cache_ctrl02hitm),
      .cache_ctrl02req_bus_data(cache_ctrl02req_bus_data),
      .cache_ctrl02req_bus_addr(cache_ctrl02req_bus_addr),
      .cache_ctrl02req_bus_command(cache_ctrl02req_bus_command),
      .cache_ctrl02resp_bus_data(cache_ctrl02resp_bus_data),
      .cache_ctrl02resp_bus_valid(cache_ctrl02resp_bus_valid),
      // inputs from dcache ctrl1
      .cache_ctrl1_state(cache_ctrl1_state),
      .cache_ctrl12hit(cache_ctrl12hit),
      .cache_ctrl12hitm(cache_ctrl12hitm),
      .cache_ctrl12req_bus_data(cache_ctrl12req_bus_data),
      .cache_ctrl12req_bus_addr(cache_ctrl12req_bus_addr),
      .cache_ctrl12req_bus_command(cache_ctrl12req_bus_command),
      .cache_ctrl12resp_bus_data(cache_ctrl12resp_bus_data),
      .cache_ctrl12resp_bus_valid(cache_ctrl12resp_bus_valid),
      // inputs from mem
      .mem_response(mem_arb2bus_arb_response),
      .mem_tag(mem_arb_tag_out),
      .mem_data(mem_arb_data_out),
      // mispredict inputs
//      .core0_mispredict(core0_mispredict),
//      .core1_mispredict(core1_mispredict),
      // outputs to req bus
      .req_bus_addr(req_bus_addr),
      .req_bus_command(req_bus_command),
      .req_bus_source(req_bus_source),
      // outputs to resp bus
      .resp_bus_data(resp_bus_data),
      .resp_bus_valid(resp_bus_valid),
      // outputs to dcache ctrl0
      .mem_response2ctrl0(mem_response2ctrl0),
      // outputs to dcache ctrl1
      .mem_response2ctrl1(mem_response2ctrl1),
      
      .mem_tag2ctrl(mem_tag2ctrl),
      // outputs to mem
      .bus_arbiter2mem_command(bus_arbiter2mem_command),
      .bus_arbiter2mem_addr(bus_arbiter2mem_addr),
      .bus_arbiter2mem_data(bus_arbiter2mem_data),
      // outputs to hit/m
      .hit_bus(hit_bus),
      .hitm_bus(hitm_bus)
    );
    

  core core0 (
        .clock(clock),             // System clock
        .reset(reset),             // System reset
        .CPU_ID(3'b001),
        // cache inputs
        .mem_arb2Icache_response(mem_arb2icache_ctrl0_response),
        .mem_arb2Icache_data(mem_arb_data_out),
        .mem_arb2Icache_tag(mem_arb_tag_out),
        .req_bus_addr(req_bus_addr),
        .req_bus_command(req_bus_command),
        .req_bus_source(req_bus_source),
        .resp_bus_data(resp_bus_data),
//        input  [2:0] resp_bus_dest(),
        .resp_bus_valid(resp_bus_valid),
        .hit_bus(hit_bus),
        .hitm_bus(hitm_bus),
        .mem_response(mem_response2ctrl0),
        .mem_tag(mem_tag2ctrl),

        .otherProc_st_stc_in(1'b0),
        .otherProc_st_stc_addr_in(16'b0),
        .stc_must_fail(1'b0),
        // cache outputs
        .Icache2mem_command(icache_ctrl02mem_command),
        .Icache2mem_addr(icache_ctrl02mem_addr),
        .cache_ctrl2resp_bus_data(cache_ctrl02resp_bus_data),
//        output [63:0] cache_ctrl2resp_bus_addr(),
        .cache_ctrl2resp_bus_valid(cache_ctrl02resp_bus_valid),
//        output [2:0] cache_ctrl2resp_bus_dest(),
        .cache_ctrl2req_bus_data(cache_ctrl02req_bus_data),
        .cache_ctrl2req_bus_addr(cache_ctrl02req_bus_addr),
        .cache_ctrl2req_bus_command(cache_ctrl02req_bus_command),
        .cache_ctrl2hit(cache_ctrl02hit),
        .cache_ctrl2hitm(cache_ctrl02hitm),
        .cache_ctrl_state(cache_ctrl0_state),

        .to_OtherProc_st_stc_out(core02core1_st_stc),
        .to_OtherProc_stc_out(core02arb_stc),
        .to_OtherProc_st_addr_out(core02core1_st_stc_addr),
        // printing outputs
        .pipeline_completed_insts(core0_pipeline_completed_insts),
        .pipeline_error_status(core0_pipeline_error_status),
        .pipeline_commit_wr_idx(core0_pipeline_commit_wr_idx),
        .pipeline_commit_wr_data(core0_pipeline_commit_wr_data),
        .pipeline_commit_wr_en(core0_pipeline_commit_wr_en),
        .pipeline_commit_NPC(core0_pipeline_commit_NPC),
        .halt(core0_halt),


                // testing hooks (these must be exported so we can test
                // the synthesized version) data is tested by looking at
                // the final values in memory
        
        
        // Outputs from IF-Stage 
        .if_NPC_out(core0_if_NPC_out),
        .if_IR_out(core0_if_IR_out),
        .if_valid_inst_out(core0_if_valid_inst_out),
        
        // Outputs from IF/ID Pipeline Register
        .if_id_NPC(core0_if_id_NPC),
        .if_id_IR(core0_if_id_IR),
        .if_id_valid_inst(core0_if_id_valid_inst),
        
        
        // Outputs from ID/RS Pipeline Register
        .id_rs_NPC(core0_id_rs_NPC),
        .id_rs_IR(core0_id_rs_IR),
        .id_rs_valid_inst(core0_id_rs_valid_inst),
        
        
        // Outputs from RS/EX Pipeline Register
        .rs_ex_NPC(core0_rs_ex_NPC),
        .rs_ex_IR(core0_rs_ex_IR),
        .rs_ex_valid_inst(core0_rs_ex_valid_inst),
        
        
        // Outputs from EX/WB Pipeline Register
        .ex_mem_NPC(core0_ex_mem_NPC),
        .ex_mem_IR(core0_ex_mem_IR),
        .ex_mem_valid_inst_out(core0_ex_mem_valid_inst),
        
        //.debug_proc2Dcache_command(core0_debug_proc2Dcache_command),
        .cache2cache_ctrl_hit_way0(core0_cache2cache_ctrl_hit_way0),
        .cache2cache_ctrl_hit_way1(core0_cache2cache_ctrl_hit_way1),
        .victim_cache2cache_ctrl_hit(core0_victim_cache2cache_ctrl_hit)//,

//        .core_mispredict(core0_mispredict)

    );



  /*core core1 (
        .clock(clock),             // System clock
        .reset(reset),             // System reset
        .CPU_ID(3'b010),
        // cache inputs
        .mem_arb2Icache_response(mem_arb2icache_ctrl1_response),
        .mem_arb2Icache_data(mem_arb_data_out),
        .mem_arb2Icache_tag(mem_arb_tag_out),
        .req_bus_addr(req_bus_addr),
        .req_bus_command(req_bus_command),
        .req_bus_source(req_bus_source),
        .resp_bus_data(resp_bus_data),
//        input  [2:0] resp_bus_dest(),
        .resp_bus_valid(resp_bus_valid),
        .hit_bus(hit_bus),
        .hitm_bus(hitm_bus),
        .mem_response(mem_response2ctrl1),
        .mem_tag(mem_tag2ctrl),

        .otherProc_st_stc_in(core02core1_st_stc),
        .otherProc_st_stc_addr_in(core02core1_st_stc_addr),
        .stc_must_fail(stc_must_fail),
        // cache outputs
        .Icache2mem_command(icache_ctrl12mem_command),
        .Icache2mem_addr(icache_ctrl12mem_addr),
        .cache_ctrl2resp_bus_data(cache_ctrl12resp_bus_data),
//        output [63:0] cache_ctrl2resp_bus_addr(),
        .cache_ctrl2resp_bus_valid(cache_ctrl12resp_bus_valid),
//        output [2:0] cache_ctrl2resp_bus_dest(),
        .cache_ctrl2req_bus_data(cache_ctrl12req_bus_data),
        .cache_ctrl2req_bus_addr(cache_ctrl12req_bus_addr),
        .cache_ctrl2req_bus_command(cache_ctrl12req_bus_command),
        .cache_ctrl2hit(cache_ctrl12hit),
        .cache_ctrl2hitm(cache_ctrl12hitm),
        .cache_ctrl_state(cache_ctrl1_state),

        .to_OtherProc_st_stc_out(core12core0_st_stc),
        .to_OtherProc_st_addr_out(core12core0_st_stc_addr),
        .to_OtherProc_stc_out(core12arb_stc),
        // printing outputs
        .pipeline_completed_insts(core1_pipeline_completed_insts),
        .pipeline_error_status(core1_pipeline_error_status),
        .pipeline_commit_wr_idx(core1_pipeline_commit_wr_idx),
        .pipeline_commit_wr_data(core1_pipeline_commit_wr_data),
        .pipeline_commit_wr_en(core1_pipeline_commit_wr_en),
        .pipeline_commit_NPC(core1_pipeline_commit_NPC),
        .halt(core1_halt),


                // testing hooks (these must be exported so we can test
                // the synthesized version) data is tested by looking at
                // the final values in memory
        
        
        // Outputs from IF-Stage 
        .if_NPC_out(core1_if_NPC_out),
        .if_IR_out(core1_if_IR_out),
        .if_valid_inst_out(core1_if_valid_inst_out),
        
        // Outputs from IF/ID Pipeline Register
        .if_id_NPC(core1_if_id_NPC),
        .if_id_IR(core1_if_id_IR),
        .if_id_valid_inst(core1_if_id_valid_inst),
        
        
        // Outputs from ID/RS Pipeline Register
        .id_rs_NPC(core1_id_rs_NPC),
        .id_rs_IR(core1_id_rs_IR),
        .id_rs_valid_inst(core1_id_rs_valid_inst),
        
        
        // Outputs from RS/EX Pipeline Register
        .rs_ex_NPC(core1_rs_ex_NPC),
        .rs_ex_IR(core1_rs_ex_IR),
        .rs_ex_valid_inst(core1_rs_ex_valid_inst),
        
        
        // Outputs from EX/WB Pipeline Register
        .ex_mem_NPC(core1_ex_mem_NPC),
        .ex_mem_IR(core1_ex_mem_IR),
        .ex_mem_valid_inst_out(core1_ex_mem_valid_inst),
        
       // .debug_proc2Dcache_command(core1_debug_proc2Dcache_command),
        .cache2cache_ctrl_hit_way0(core1_cache2cache_ctrl_hit_way0),
        .cache2cache_ctrl_hit_way1(core1_cache2cache_ctrl_hit_way1),
        .victim_cache2cache_ctrl_hit(core1_victim_cache2cache_ctrl_hit)//,

//        .core_mispredict(core1_mispredict)
        
    );*/

endmodule
