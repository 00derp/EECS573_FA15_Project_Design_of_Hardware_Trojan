`timescale 1ns/100ps


module rs_stage (
    input clock, reset,
    input                  id_rs_srcA_valid_in,
    input                  id_rs_srcB_valid_in,
    input                  id_rs_valid_inst_in,
    input                  id_rs_uncond_branch_in,
    input                  id_rs_cond_branch_in,
    input                  id_rs_rd_mem_in,
    input                  id_rs_wr_mem_in,
    input                  id_rs_ldl_in,
    input                  id_rs_stc_in,
    input                  id_rs_cpuid_in,
    input                  id_rs_illegal_in,
    input                  id_rs_halt_in,
    input [1:0]            id_rs_opa_select_in, 
    input [1:0]            id_rs_opb_select_in,
    input [4:0]            id_rs_opcode_in,
    input [31:0]           id_rs_IR_in, 
    input [15:0]           id_rs_PC_plus_4_in,
    input [15:0]           id_rs_predicted_target_addr_in,
    input [`PRF_width-1:0] id_rs_srcA_PRF_num_in,
    input [`PRF_width-1:0] id_rs_srcB_PRF_num_in,
    input [`ARF_width-1:0] id_rs_ARF_num_in,
    input [`PRF_width-1:0] id_rs_dest_PRF_num_in,
    input [`PRF_width-1:0] ex_CDB_tag_in, 
    input [15:0]           ex_NPC_in,
    input                  ex_MULT_busy_in,
    input                  ex_CDB_arb_stall_in,
    input                  ex_branch_mispredict_in,
    input                  ex_branch_inst_in,
    input                  id_no_free_PRF_in,
    //input                  mem_load_done_in,
    input                  mem_store_done_in,
    input                  mem_stc_done_in,
    input [`ROB_width-1:0] update_ROB_num_in,  
    input                  Dcache_done, 
    input                  mem_inst_dispatch_disable,


    output logic                    RS_full_out,
    output logic                    RS_valid_inst_out,
    output logic                    RS_uncond_branch_out,
    output logic                    RS_cond_branch_out,
    output logic                    RS_rd_mem_out,
    output logic                    RS_wr_mem_out,
    output logic                    RS_ldl_out,
    output logic                    RS_stc_out,
    output logic                    RS_cpuid_out,
    output logic   [1:0]            RS_opa_select_out, 
    output logic   [1:0]            RS_opb_select_out,
    output logic   [4:0]            RS_opcode_out,
    output logic   [31:0]           RS_IR_out,
    output logic   [15:0]           RS_PC_plus_4_out,
    output logic   [15:0]           RS_predicted_target_addr_out,
    output logic   [`PRF_width-1:0] RS_srcA_PRF_num_out,
    output logic   [`PRF_width-1:0] RS_srcB_PRF_num_out,
    output logic   [`PRF_width-1:0] RS_dest_PRF_num_out,
    output logic   [`ROB_width-1:0] RS_ROB_num_out,
    output logic   [`ARF_width-1:0] ROB_ARF_num_out,
    output logic   [`PRF_width-1:0] ROB_PRF_num_out,
    output logic   [15:0]           ROB_PC_plus_4_out,
    output logic   [15:0]           ROB_NPC_out,
    output logic                    ROB_branch_mispredict_out,
    output logic                    ROB_is_store_inst_out,
    output logic                    ROB_is_branch_inst_out,
    output logic                    ROB_commit_out,
    output logic                    ROB_dispatch_disable,
    output logic [`ROB_width-1:0]   ROB_head,
    output logic [`ROB_width-1:0]   ROB_tail,
    output logic                    ROB_illegal_out,
    output logic                    ROB_halt_out,
    output logic                    outstanding_stc_inst

  );
  
  logic is_branch_inst;

  //assign mem_inst_done_in = mem_store_done_in | mem_load_done_in;
  assign dispatch_enable   = ~RS_full_out & id_rs_valid_inst_in & 
                             ~id_no_free_PRF_in & ~ROB_dispatch_disable 
                             & ~mem_inst_dispatch_disable & ~outstanding_stc_inst;

  assign is_branch_inst = id_rs_uncond_branch_in | id_rs_cond_branch_in;

  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset)
      outstanding_stc_inst <= `SD 0;
    else begin
      if (ROB_branch_mispredict_out)
        outstanding_stc_inst <= `SD 0;
      else if (id_rs_stc_in && dispatch_enable)
        outstanding_stc_inst <= `SD 1;
      else if (mem_stc_done_in)
        outstanding_stc_inst <= `SD 0;
    end
  end

  



  RS reservation (
    .clock(clock),
    .reset(reset),
    .ROB_branch_mispredict_in(ROB_branch_mispredict_out),
    .ROB_ROB_num_in(ROB_tail),
    .ex_MULT_busy_in(ex_MULT_busy_in),
    .ex_CDB_arb_stall_in(ex_CDB_arb_stall_in),
    .id_rs_srcA_valid_in(id_rs_srcA_valid_in),
    .id_rs_srcB_valid_in(id_rs_srcB_valid_in),
    .id_rs_valid_inst_in(id_rs_valid_inst_in),
    .id_rs_uncond_branch_in(id_rs_uncond_branch_in),
    .id_rs_cond_branch_in(id_rs_cond_branch_in),
    .id_rs_rd_mem_in(id_rs_rd_mem_in),
    .id_rs_wr_mem_in(id_rs_wr_mem_in),
    .id_rs_ldl_in(id_rs_ldl_in),
    .id_rs_stc_in(id_rs_stc_in),
    .id_rs_cpuid_in(id_rs_cpuid_in),
    .id_rs_opa_select_in(id_rs_opa_select_in),
    .id_rs_opb_select_in(id_rs_opb_select_in),
    .id_rs_opcode_in(id_rs_opcode_in),
    .id_rs_IR_in(id_rs_IR_in),
    .id_rs_PC_plus_4_in(id_rs_PC_plus_4_in),
    .id_rs_predicted_target_addr_in(id_rs_predicted_target_addr_in),
    .id_rs_srcA_PRF_num_in(id_rs_srcA_PRF_num_in),
    .id_rs_srcB_PRF_num_in(id_rs_srcB_PRF_num_in),
    .id_rs_dest_PRF_num_in(id_rs_dest_PRF_num_in),
    .ex_CDB_tag_in(ex_CDB_tag_in),
    .id_no_free_PRF_in(id_no_free_PRF_in),
    .ROB_dispatch_disable_in(ROB_dispatch_disable),
    .mem_inst_dispatch_disable(mem_inst_dispatch_disable),
    .outstanding_stc_inst(outstanding_stc_inst),

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
    .RS_ROB_num_out(RS_ROB_num_out)
    );

  ROB reorder (
    .clock(clock),
    .reset(reset),
    .id_rs_valid_inst_in(id_rs_valid_inst_in),
    .id_rs_ARF_num_in(id_rs_ARF_num_in),
    .id_rs_PRF_num_in(id_rs_dest_PRF_num_in), 
    .id_rs_is_branch_inst_in(is_branch_inst),
    .id_rs_is_store_inst_in(id_rs_wr_mem_in | id_rs_stc_in),
    .id_rs_PC_plus_4_in(id_rs_PC_plus_4_in),
    .id_rs_illegal_in(id_rs_illegal_in),
    .id_rs_halt_in(id_rs_halt_in),
    .ex_NPC_in(ex_NPC_in),
    .ex_branch_mispredict_in(ex_branch_mispredict_in),
    .ex_branch_inst_in(ex_branch_inst_in),
    .CDB_tag_in(ex_CDB_tag_in),
    .RS_full_in(RS_full_out),
    .id_no_free_PRF_in(id_no_free_PRF_in),
    .mem_inst_dispatch_disable(mem_inst_dispatch_disable),
    .mem_store_done_in(mem_store_done_in),
    .update_ROB_num_in(update_ROB_num_in),
    .Dcache_done(Dcache_done),
    .outstanding_stc_inst(outstanding_stc_inst),

    .ROB_ARF_num_out(ROB_ARF_num_out),
    .ROB_PRF_num_out(ROB_PRF_num_out),
    .ROB_PC_plus_4_out(ROB_PC_plus_4_out),
    .ROB_NPC_out(ROB_NPC_out),
    .ROB_branch_mispredict_out(ROB_branch_mispredict_out),
    .ROB_is_store_inst_out(ROB_is_store_inst_out),
    .ROB_is_branch_inst_out(ROB_is_branch_inst_out),
    .ROB_commit_out(ROB_commit_out),
    .ROB_illegal_out(ROB_illegal_out),
    .ROB_halt_out(ROB_halt_out),
    .ROB_dispatch_disable(ROB_dispatch_disable),
    .ROB_head(ROB_head),
    .ROB_tail(ROB_tail)
    );
endmodule



module RS (
    input clock, reset,
    input                  ROB_branch_mispredict_in,
    input [`ROB_width-1:0] ROB_ROB_num_in,
    input                  ex_MULT_busy_in,
    input                  ex_CDB_arb_stall_in,
    input                  id_rs_srcA_valid_in,
    input                  id_rs_srcB_valid_in,
    input                  id_rs_valid_inst_in,
    input                  id_rs_uncond_branch_in,
    input                  id_rs_cond_branch_in,
    input                  id_rs_rd_mem_in,
    input                  id_rs_wr_mem_in,
    input                  id_rs_ldl_in,
    input                  id_rs_stc_in,
    input                  id_rs_cpuid_in,
    input [1:0]            id_rs_opa_select_in, 
    input [1:0]            id_rs_opb_select_in,
    input [4:0]            id_rs_opcode_in,
    input [31:0]           id_rs_IR_in, 
    input [15:0]           id_rs_PC_plus_4_in,
    input [15:0]           id_rs_predicted_target_addr_in,
    input [`PRF_width-1:0] id_rs_srcA_PRF_num_in,
    input [`PRF_width-1:0] id_rs_srcB_PRF_num_in,
    input [`PRF_width-1:0] id_rs_dest_PRF_num_in,
    input [`PRF_width-1:0] ex_CDB_tag_in,
    input                  id_no_free_PRF_in,
    input                  ROB_dispatch_disable_in,
    input                  mem_inst_dispatch_disable,
    input                  outstanding_stc_inst,

    output logic                  RS_full_out,
    output logic                  RS_valid_inst_out,
    output wor                    RS_uncond_branch_out,
    output wor                    RS_cond_branch_out,
    output wor                    RS_rd_mem_out,
    output wor                    RS_wr_mem_out,
    output wor                    RS_ldl_out,
    output wor                    RS_stc_out,
    output wor                    RS_cpuid_out,
    output wor   [1:0]            RS_opa_select_out, 
    output wor   [1:0]            RS_opb_select_out,
    output wor   [4:0]            RS_opcode_out,
    output wor   [31:0]           RS_IR_out,
    output wor   [15:0]           RS_PC_plus_4_out,
    output wor   [15:0]           RS_predicted_target_addr_out,
    output wor   [`PRF_width-1:0] RS_srcA_PRF_num_out,
    output wor   [`PRF_width-1:0] RS_srcB_PRF_num_out,
    output wor   [`PRF_width-1:0] RS_dest_PRF_num_out,
    output wor   [`ROB_width-1:0] RS_ROB_num_out
);

  logic [`RS_size-1:0] free_list, choose_list, issue_list;
  logic [`RS_size-1:0] wr_en, issue_en;
  logic                srcA_valid_in, srcB_valid_in;
  logic                dispatch_enable;
  logic                srcA_match, srcB_match;

  logic                srcA_already_got_CDB, srcB_already_got_CDB;       

  assign dispatch_enable   = ~RS_full_out & id_rs_valid_inst_in & 
                             ~id_no_free_PRF_in & ~ROB_dispatch_disable_in 
                             & ~mem_inst_dispatch_disable & ~outstanding_stc_inst;
  assign choose_list       = free_list | issue_en;
  assign RS_full_out       = choose_list == `RS_size'b0;
  assign RS_valid_inst_out = (issue_list != 0);

  assign srcA_match = id_rs_srcA_PRF_num_in == ex_CDB_tag_in && id_rs_valid_inst_in;
  assign srcB_match = id_rs_srcB_PRF_num_in == ex_CDB_tag_in && id_rs_valid_inst_in;
  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) 
      srcA_already_got_CDB <= `SD 0;
    else begin
      if (dispatch_enable | ROB_branch_mispredict_in)
        srcA_already_got_CDB <= `SD 0;
      else if (srcA_match)
        srcA_already_got_CDB <= `SD 1;
    end

  end      
  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) 
      srcB_already_got_CDB <= `SD 0;
    else begin 
      if (dispatch_enable | ROB_branch_mispredict_in)
        srcB_already_got_CDB <= `SD 0;
      else if (srcB_match)
        srcB_already_got_CDB <= `SD 1;
    end
  end



  //Avoid ship in the dark problem
  assign srcA_valid_in = id_rs_srcA_valid_in || (id_rs_srcA_PRF_num_in == ex_CDB_tag_in) || srcA_already_got_CDB;
  assign srcB_valid_in = id_rs_srcB_valid_in || (id_rs_srcB_PRF_num_in == ex_CDB_tag_in) || srcB_already_got_CDB;
  
  ps #(`RS_size) dispatch_select (
    .req(choose_list),
    .en(dispatch_enable),
    .gnt(wr_en)
  );

  ps #(`RS_size) issue_select (
    .req(issue_list),
    .en(~ex_CDB_arb_stall_in),
    .gnt(issue_en)
  );

  RS_entry RS8 [`RS_size-1:0] (
    .clock(clock),
    .reset(reset),
    .wr_en(wr_en),
    .issue_en(issue_en),
    .branch_mispredict(ROB_branch_mispredict_in),
    .MULT_busy(ex_MULT_busy_in),
    .srcA_valid_in(srcA_valid_in),
    .srcB_valid_in(srcB_valid_in),
    .uncond_branch_in(id_rs_uncond_branch_in),
    .cond_branch_in(id_rs_cond_branch_in),
    .rd_mem_in(id_rs_rd_mem_in),
    .wr_mem_in(id_rs_wr_mem_in),
    .ldl_in(id_rs_ldl_in),
    .stc_in(id_rs_stc_in),
    .cpuid_in(id_rs_cpuid_in),
    .opa_select_in(id_rs_opa_select_in),
    .opb_select_in(id_rs_opb_select_in),
    .opcode_in(id_rs_opcode_in),
    .IR_in(id_rs_IR_in),
    .PC_plus_4_in(id_rs_PC_plus_4_in),
    .predicted_target_addr_in(id_rs_predicted_target_addr_in),
    .srcA_PRF_num_in(id_rs_srcA_PRF_num_in),
    .srcB_PRF_num_in(id_rs_srcB_PRF_num_in),
    .dest_PRF_num_in(id_rs_dest_PRF_num_in),
    .ROB_num_in(ROB_ROB_num_in),
    .CDB_tag_in(ex_CDB_tag_in),

    .issue_out(issue_list),
    .free_out(free_list),
    .uncond_branch_out(RS_uncond_branch_out),
    .cond_branch_out(RS_cond_branch_out),
    .rd_mem_out(RS_rd_mem_out),
    .wr_mem_out(RS_wr_mem_out),
    .ldl_out(RS_ldl_out),
    .stc_out(RS_stc_out),
    .cpuid_out(RS_cpuid_out),
    .opa_select_out(RS_opa_select_out),
    .opb_select_out(RS_opb_select_out),
    .opcode_out(RS_opcode_out),
    .IR_out(RS_IR_out),
    .PC_plus_4_out(RS_PC_plus_4_out),
    .predicted_target_addr_out(RS_predicted_target_addr_out),
    .srcA_PRF_num_out(RS_srcA_PRF_num_out),
    .srcB_PRF_num_out(RS_srcB_PRF_num_out),
    .dest_PRF_num_out(RS_dest_PRF_num_out),
    .ROB_num_out(RS_ROB_num_out)
  );

  

endmodule




module RS_entry (
    input clock, reset, wr_en, issue_en,
    input                  branch_mispredict,
    input                  MULT_busy,
    input                  srcA_valid_in,
    input                  srcB_valid_in,
    input                  uncond_branch_in,
    input                  cond_branch_in,
    input                  rd_mem_in,
    input                  wr_mem_in,
    input                  ldl_in,
    input                  stc_in,
    input                  cpuid_in,
    input [1:0]            opa_select_in, 
    input [1:0]            opb_select_in,
    input [4:0]            opcode_in,
    input [31:0]           IR_in,                     
    input [15:0]           PC_plus_4_in,
    input [15:0]           predicted_target_addr_in,
    input [`PRF_width-1:0] srcA_PRF_num_in,
    input [`PRF_width-1:0] srcB_PRF_num_in,
    input [`PRF_width-1:0] dest_PRF_num_in,
    input [`PRF_width-1:0] CDB_tag_in,
    input [`ROB_width-1:0] ROB_num_in,

    output logic                  issue_out,
    output logic                  free_out,
    output logic                  uncond_branch_out,
    output logic                  cond_branch_out,
    output logic                  rd_mem_out,
    output logic                  wr_mem_out,
    output logic                  ldl_out,
    output logic                  stc_out,
    output logic                  cpuid_out,
    output logic [1:0]            opa_select_out, 
    output logic [1:0]            opb_select_out,
    output logic [4:0]            opcode_out,
    output logic [31:0]           IR_out,
    output logic [15:0]           PC_plus_4_out,
    output logic [15:0]           predicted_target_addr_out,
    output logic [`PRF_width-1:0] srcA_PRF_num_out,
    output logic [`PRF_width-1:0] srcB_PRF_num_out,
    output logic [`PRF_width-1:0] dest_PRF_num_out,
    output logic [`ROB_width-1:0] ROB_num_out
);

  logic                  free;
  logic                  srcA_valid, srcB_valid;
  logic                  uncond_branch;
  logic                  cond_branch;
  logic                  rd_mem;
  logic                  wr_mem;
  logic                  ldl;
  logic                  stc;
  logic                  cpuid;
  logic [1:0]            opa_select, opb_select;
  logic [4:0]            opcode;
  logic [31:0]           IR;
  logic [15:0]           PC_plus_4;
  logic [15:0]           predicted_target_addr;
  logic [`PRF_width-1:0] srcA_PRF_num;
  logic [`PRF_width-1:0] srcB_PRF_num;
  logic [`PRF_width-1:0] dest_PRF_num;
  logic [`ROB_width-1:0] ROB_num;

  logic srcA_PRF_match, srcB_PRF_match;

  assign srcA_PRF_match = srcA_PRF_num == CDB_tag_in;
  assign srcB_PRF_match = srcB_PRF_num == CDB_tag_in;
  
  assign free_out                  = free;
  assign issue_out                 = !(!free && (srcA_valid || srcA_PRF_match)
                                     && (srcB_valid || srcB_PRF_match))? 0 : 
                                     opcode != `ALU_MULQ? 1 :
                                     MULT_busy? 0 : 1;
  assign uncond_branch_out         = issue_en? uncond_branch : 0;  
  assign cond_branch_out           = issue_en? cond_branch : 0;
  assign rd_mem_out                = issue_en? rd_mem : 0;
  assign wr_mem_out                = issue_en? wr_mem : 0;
  assign ldl_out                   = issue_en? ldl : 0;
  assign stc_out                   = issue_en? stc : 0;
  assign cpuid_out                 = issue_en? cpuid : 0;
  assign opa_select_out            = issue_en? opa_select : 0;
  assign opb_select_out            = issue_en? opb_select : 0;
  assign opcode_out                = issue_en? opcode : 0;
  assign IR_out                    = issue_en? IR : 0;
  assign PC_plus_4_out             = issue_en? PC_plus_4 : 0;
  assign predicted_target_addr_out = issue_en? predicted_target_addr : 0;
  assign srcA_PRF_num_out          = issue_en? srcA_PRF_num : 0;
  assign srcB_PRF_num_out          = issue_en? srcB_PRF_num : 0;
  assign dest_PRF_num_out          = issue_en? dest_PRF_num : 0;
  assign ROB_num_out               = issue_en? ROB_num : 0;

  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset)
      srcA_valid <= `SD 0;
    else begin
      if (branch_mispredict)
        srcA_valid <= `SD 0;
      else if (wr_en)
        srcA_valid <= `SD srcA_valid_in;
      else if (srcA_PRF_match)
        srcA_valid <= `SD 1;
    end
  end

  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset)
      srcB_valid <= `SD 0;
    else begin
      if (branch_mispredict)
        srcB_valid <= `SD 0;
      else if (wr_en)
        srcB_valid <= `SD srcB_valid_in;
      else if (srcB_PRF_match)
        srcB_valid <= `SD 1;
    end
  end

  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset)
      free <= `SD 1;
    else begin
      if (branch_mispredict)
        free <= `SD 1;
      else if (wr_en)
        free <= `SD 0;
      else if (issue_en)
        free <= `SD 1;
    end
  end

  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      uncond_branch         <= `SD 0;
      cond_branch           <= `SD 0;
      rd_mem                <= `SD 0;
      wr_mem                <= `SD 0;
      ldl                   <= `SD 0;
      stc                   <= `SD 0;
      cpuid                 <= `SD 0;
      opa_select            <= `SD 0;
      opb_select            <= `SD 0;
      opcode                <= `SD 0;
      IR                    <= `SD 0;
      PC_plus_4             <= `SD 0;
      predicted_target_addr <= `SD 0;
      srcA_PRF_num          <= `SD 0;
      srcB_PRF_num          <= `SD 0;
      dest_PRF_num          <= `SD 0;
      ROB_num               <= `SD 0;
    end
    else begin
      if (branch_mispredict) begin
        uncond_branch         <= `SD 0;
        cond_branch           <= `SD 0;
        rd_mem                <= `SD 0;
        wr_mem                <= `SD 0;
        ldl                   <= `SD 0;
        stc                   <= `SD 0;
        cpuid                 <= `SD 0;
        opa_select            <= `SD 0;
        opb_select            <= `SD 0;
        opcode                <= `SD 0;
        IR                    <= `SD 0;
        PC_plus_4             <= `SD 0;
        predicted_target_addr <= `SD 0;
        srcA_PRF_num          <= `SD 0;
        srcB_PRF_num          <= `SD 0;
        dest_PRF_num          <= `SD 0;
        ROB_num               <= `SD 0;
      end
      else if (wr_en) begin
        uncond_branch         <= `SD uncond_branch_in;
        cond_branch           <= `SD cond_branch_in;
        rd_mem                <= `SD rd_mem_in;
        wr_mem                <= `SD wr_mem_in;
        ldl                   <= `SD ldl_in;
        stc                   <= `SD stc_in;
        cpuid                 <= `SD cpuid_in;
        opa_select            <= `SD opa_select_in;
        opb_select            <= `SD opb_select_in;
        opcode                <= `SD opcode_in;
        IR                    <= `SD IR_in;
        PC_plus_4             <= `SD PC_plus_4_in;
        predicted_target_addr <= `SD predicted_target_addr_in;
        srcA_PRF_num          <= `SD srcA_PRF_num_in;
        srcB_PRF_num          <= `SD srcB_PRF_num_in;
        dest_PRF_num          <= `SD dest_PRF_num_in;
        ROB_num               <= `SD ROB_num_in;
      end
    end
  end
endmodule




/*module ps (req, en, gnt, req_up);
//synopsys template
parameter NUM_BITS = `RS_size;

  input  [NUM_BITS-1:0] req;
  input                 en;

  output [NUM_BITS-1:0] gnt;
  output                req_up;
        
  wire   [NUM_BITS-2:0] req_ups;
  wire   [NUM_BITS-2:0] enables;
        
  assign req_up = req_ups[NUM_BITS-2];
  assign enables[NUM_BITS-2] = en;
        
  genvar i,j;
  generate
    if ( NUM_BITS == 2 )
    begin
      ps2 single (.req(req),.en(en),.gnt(gnt),.req_up(req_up));
    end
    else
    begin
      for(i=0;i<NUM_BITS/2;i=i+1)
      begin : foo
        ps2 base ( .req(req[2*i+1:2*i]),
                   .en(enables[i]),
                   .gnt(gnt[2*i+1:2*i]),
                   .req_up(req_ups[i])
        );
      end

      for(j=NUM_BITS/2;j<=NUM_BITS-2;j=j+1)
      begin : bar
        ps2 top ( .req(req_ups[2*j-NUM_BITS+1:2*j-NUM_BITS]),
                  .en(enables[j]),
                  .gnt(enables[2*j-NUM_BITS+1:2*j-NUM_BITS]),
                  .req_up(req_ups[j])
        );
      end
    end
  endgenerate
endmodule

module ps2(req, en, gnt, req_up);

  input     [1:0] req;
  input           en;
  
  output    [1:0] gnt;
  output          req_up;
  
  assign gnt[1] = en & req[1];
  assign gnt[0] = en & req[0] & !req[1];
  
  assign req_up = req[1] | req[0];

endmodule*/

module ROB (
  input clock, reset,
  input                  id_rs_valid_inst_in,
  input [`ARF_width-1:0] id_rs_ARF_num_in,
  input [`PRF_width-1:0] id_rs_PRF_num_in,
  input                  id_rs_is_branch_inst_in, 
  input                  id_rs_is_store_inst_in, 
  input [15:0]           id_rs_PC_plus_4_in,
  input                  id_rs_illegal_in,
  input                  id_rs_halt_in,             
  input [15:0]           ex_NPC_in,
  input                  ex_branch_mispredict_in,
  input                  ex_branch_inst_in,
  input [`PRF_width-1:0] CDB_tag_in,
  input                  RS_full_in,
  input                  id_no_free_PRF_in,
  input                  mem_inst_dispatch_disable,
  input                  mem_store_done_in,
  input [`ROB_width-1:0] update_ROB_num_in, //for updating branch and store
  input                  Dcache_done,
  input                  outstanding_stc_inst,

  output wor   [`ARF_width-1:0] ROB_ARF_num_out,
  output wor   [`PRF_width-1:0] ROB_PRF_num_out,
  output wor   [15:0]           ROB_PC_plus_4_out,
  output wor   [15:0]           ROB_NPC_out,
  output wor                    ROB_branch_mispredict_out,
  output wor                    ROB_is_store_inst_out,
  output wor                    ROB_is_branch_inst_out,
  output logic                  ROB_commit_out,
  output wor                    ROB_illegal_out,
  output wor                    ROB_halt_out,
  output logic                  ROB_dispatch_disable,
  output logic [`ROB_width-1:0] ROB_head,
  output logic [`ROB_width-1:0] ROB_tail
);
  
  logic [`ROB_size-1:0]  entry_wr_en, entry_rd_en, branch_resolved_en, store_resolved_en;
  logic                  wr_en;
  
  wor                    valid;
  wor ROB_commit;

  assign ROB_commit_out = ~ROB_halt_out ? ROB_commit : Dcache_done ? 1 : 0;

  assign ROB_dispatch_disable = (ROB_head == ROB_tail) & valid & ~ROB_commit_out;

  assign wr_en                = id_rs_valid_inst_in & ~RS_full_in & ~ROB_dispatch_disable 
                                & ~id_no_free_PRF_in & ~mem_inst_dispatch_disable & ~outstanding_stc_inst;
  assign entry_wr_en          = wr_en ?             1 << ROB_tail : 0;
  assign entry_rd_en          =                     1 << ROB_head;
  assign branch_resolved_en   = ex_branch_inst_in ? 1 << update_ROB_num_in : 0;
  assign store_resolved_en    = mem_store_done_in ? 1 << update_ROB_num_in : 0;

  ROB_entry ROB32 [`ROB_size-1:0] (
    .clock(clock),
    .reset(reset),
    .squash(ROB_branch_mispredict_out),
    .wr_en(entry_wr_en),
    .rd_en(entry_rd_en),
    .id_rs_ARF_num_in({`ROB_size{id_rs_ARF_num_in}}),
    .id_rs_PRF_num_in({`ROB_size{id_rs_PRF_num_in}}),
    .id_rs_is_branch_inst_in({`ROB_size{id_rs_is_branch_inst_in}}),
    .id_rs_is_store_inst_in({`ROB_size{id_rs_is_store_inst_in}}),
    .id_rs_PC_plus_4_in({`ROB_size{id_rs_PC_plus_4_in}}),
    .id_rs_illegal_in({`ROB_size{id_rs_illegal_in}}),
    .id_rs_halt_in({`ROB_size{id_rs_halt_in}}),
    .ex_NPC_in({`ROB_size{ex_NPC_in}}),
    .ex_branch_mispredict_in({`ROB_size{ex_branch_mispredict_in}}),
    .branch_resolved(branch_resolved_en),
    .store_resolved(store_resolved_en),
    .CDB_tag_in({`ROB_size{CDB_tag_in}}),


    .ARF_num_out(ROB_ARF_num_out),
    .PRF_num_out(ROB_PRF_num_out),
    .is_store_inst_out(ROB_is_store_inst_out),
    .is_branch_inst_out(ROB_is_branch_inst_out),
    .PC_plus4_out(ROB_PC_plus_4_out),
    .NPC_out(ROB_NPC_out),
    .branch_mispredict_out(ROB_branch_mispredict_out),
    .done_out(ROB_commit),
    .valid_out(valid),
    .illegal_out(ROB_illegal_out),
    .halt_out(ROB_halt_out)
  );

  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin  
    if (reset)
      ROB_head <= `SD 0;
    else begin
      if (ROB_branch_mispredict_out)
        ROB_head <= `SD 0;
      else if (ROB_commit_out)
        ROB_head <= `SD ROB_head + 1'b1;
    end
  end
  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin  
    if (reset)
      ROB_tail <= `SD 0;
    else begin 
      if (ROB_branch_mispredict_out)
        ROB_tail <= `SD 0;
      else if (wr_en)
        ROB_tail <= `SD ROB_tail + 1'b1;
    end
  end


endmodule  

module ROB_entry (
  input clock, reset, squash, wr_en, rd_en,
  input [`ARF_width-1:0] id_rs_ARF_num_in,
  input [`PRF_width-1:0] id_rs_PRF_num_in,
  input                  id_rs_is_branch_inst_in, 
  input                  id_rs_is_store_inst_in,  
  input [15:0]           id_rs_PC_plus_4_in,  
  input                  id_rs_illegal_in,
  input                  id_rs_halt_in,          
  input [15:0]           ex_NPC_in,
  input                  ex_branch_mispredict_in,
  input                  branch_resolved,
  input                  store_resolved,
  input [`PRF_width-1:0] CDB_tag_in,
  
  output logic [`ARF_width-1:0] ARF_num_out,
  output logic [`PRF_width-1:0] PRF_num_out,
  output logic                  is_branch_inst_out,
  output logic                  is_store_inst_out,
  output logic [15:0]           PC_plus4_out,
  output logic [15:0]           NPC_out,
  output logic                  branch_mispredict_out,
  output logic                  done_out,
  output logic                  valid_out,
  output logic                  illegal_out,
  output logic                  halt_out
);
  
  logic [`ARF_width-1:0] ARF_num;
  logic [`PRF_width-1:0] PRF_num;
  logic                  is_branch_inst;
  logic                  is_store_inst;
  logic [15:0]           PC_plus_4;
  logic [15:0]           NPC;
  logic                  branch_mispredict;
  logic                  done;
  logic                  valid;
  logic                  illegal;
  logic                  halt;

  logic  match;
  logic  valid_next;

  assign match = ((PRF_num == CDB_tag_in && !is_branch_inst && !is_store_inst) || 
                  (branch_resolved && is_branch_inst) || 
                  (store_resolved && is_store_inst)); 
  assign valid_next            = (valid && done) ? 0 : valid;

  assign ARF_num_out           = rd_en ? ARF_num : 0;         
  assign PRF_num_out           = rd_en ? PRF_num : 0;
  assign is_branch_inst_out    = rd_en ? is_branch_inst : 0;
  assign is_store_inst_out     = rd_en ? is_store_inst : 0;
  assign PC_plus4_out          = rd_en ? PC_plus_4 : 0;
  assign NPC_out               = rd_en ? NPC : 0;
  assign branch_mispredict_out = rd_en ? branch_mispredict : 0;
  assign done_out              = rd_en ? (done & valid) : 0;
  assign valid_out             = rd_en ? valid : 0;
  assign illegal_out           = rd_en ? illegal : 0;
  assign halt_out              = rd_en ? halt : 0;

  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      ARF_num           <= `SD 0;
      PRF_num           <= `SD 0;
      is_branch_inst    <= `SD 0;
      is_store_inst     <= `SD 0;
      PC_plus_4         <= `SD 0;
      NPC               <= `SD 0;
      branch_mispredict <= `SD 0;
      done              <= `SD 0;
      illegal           <= `SD 0;
      halt              <= `SD 0;
    end
    else begin
      if (squash) begin
        ARF_num           <= `SD 0;
        PRF_num           <= `SD 0;
        is_branch_inst    <= `SD 0;
        is_store_inst     <= `SD 0;
        PC_plus_4         <= `SD 0;
        NPC               <= `SD 0;
        branch_mispredict <= `SD 0;
        done              <= `SD 0;
        illegal           <= `SD 0;
        halt              <= `SD 0;
      end
      else if (wr_en) begin
        ARF_num           <= `SD id_rs_ARF_num_in;
        PRF_num           <= `SD id_rs_PRF_num_in;
        is_branch_inst    <= `SD id_rs_is_branch_inst_in;
        is_store_inst     <= `SD id_rs_is_store_inst_in;
        PC_plus_4         <= `SD id_rs_PC_plus_4_in;
        NPC               <= `SD 0;
        branch_mispredict <= `SD 0;
        done              <= `SD 0;
        illegal           <= `SD id_rs_illegal_in;
        halt              <= `SD id_rs_halt_in;
      end
      else if (match) begin
        if (ex_branch_mispredict_in && is_branch_inst) begin
          NPC               <= `SD ex_NPC_in;
          branch_mispredict <= `SD ex_branch_mispredict_in;
        end
        done              <= `SD 1;
      end
    end
  end
  
  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset)
      valid <= `SD 0;
    else begin
      if (squash)
        valid <= `SD 0;
      else if (wr_en)
        valid <= `SD 1;
      else if (rd_en)
        valid <= `SD valid_next;
    end
  end

endmodule
