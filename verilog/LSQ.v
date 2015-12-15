/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  LSQ.v                                               //
//                                                                     //
//  Description :  Split Load Queue and Store Queue modules            //
//                 and LSQ module                                      //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps


// dependency status
`define INDEP      2'b00
`define UNKNOWN    2'b01
`define DEP        2'b10

`define STQ_SIZE   4
`define STQ_WIDTH  2
`define LDQ_SIZE   4
`define LDQ_WIDTH  2

module LSQ(
  input clock, reset,
  input mispredict,
  input id_rs_valid_inst,
  input id_rs_rd_mem,
  input id_rs_wr_mem,
  input id_rs_ldl,
  input id_rs_stc,
  input [`PRF_width-1:0] id_rs_dest_PRF_num,
  input [`ROB_width-1:0] ROB_head,
  input [`ROB_width-1:0] ROB_tail,
  input [`ROB_width-1:0] ex_mem_ROB_num,
  input                  ROB_is_store_inst,
  input                  ex_mem_ld_inst,
  input                  ex_mem_ldl_inst,
  input                  ex_mem_st_inst,
  input                  ex_mem_stc_inst,
  input [15:0]           ex_mem_proc2Dcache_addr,
  input [63:0]           ex_mem_proc2Dcache_data,
  input                  Dcache2proc_done,
  input                  id_no_free_PRF,
  input                  ROB_dispatch_disable,
  input                  mem_inst_dispatch_disable,
  input                  RS_full,
  input [15:0]           id_rs_NPC,
  input [31:0]           id_rs_IR,
  input                  ex_CDB_arb_stall,
  input                  stc_fail,

  output logic [1:0]     LSQ2Dcache_command,
  output logic [15:0]    LSQ2Dcache_addr,
  output logic [63:0]    LSQ2Dcache_data,
  output logic [`PRF_width-1:0] LSQ2CDB_PRF_num,
  output logic           LSQ_store_done,
  output logic           LSQ_load_done,
  output logic [`ROB_width-1:0] LSQ_store_ROB_num,
  output logic           LDQ_full,
  output logic           STQ_full,
  output logic [15:0]    LSQ_NPC_out,
  output logic [31:0]    LSQ_IR_out,
  output logic           LSQ_is_stc_inst,
  output logic           LSQ_is_ldl_inst
  );
  
  logic [`STQ_SIZE-1:0] STQ_valid;
  logic [`STQ_SIZE-1:0] STQ_addr_valid;
  logic [`STQ_SIZE-1:0][15:0] STQ_addr;
  logic [`STQ_SIZE-1:0] STQ_resolved_addr_entry_index;
  logic [`STQ_SIZE-1:0] STQ_commit_entry_index;
  logic [1:0] LDQ2Dcache_command, STQ2Dcache_command;
  logic [15:0] LDQ2Dcache_addr, STQ2Dcache_addr;
  logic [63:0] STQ2Dcache_data;
  logic [`PRF_width-1:0] LDQ_CDB_PRF_num, STQ_CDB_PRF_num;
  // debug
  logic [15:0] LDQ_NPC_out, STQ_NPC_out;
  logic [31:0] LDQ_IR_out, STQ_IR_out;

  logic LSQ2LDQ_done, LSQ2STQ_done;
  
  logic request_priority; // 0 for LDQ and 1 for STQ
  logic load_miss;
  logic LDQ_is_ldl_inst, STQ_is_stc_inst;

  assign LSQ2Dcache_data = STQ2Dcache_data;
  assign LSQ_store_done = LSQ2STQ_done;
  assign LSQ_load_done  = LSQ2LDQ_done;
  assign LSQ2CDB_PRF_num = load_miss ? LDQ_CDB_PRF_num :
                           STQ2Dcache_command != `BUS_NONE ? STQ_CDB_PRF_num : 
                           LDQ2Dcache_command != `BUS_NONE ? LDQ_CDB_PRF_num : 0;
  assign LSQ_is_stc_inst = load_miss ? 0 :
                           STQ2Dcache_command != `BUS_NONE ? STQ_is_stc_inst : 
                           LDQ2Dcache_command != `BUS_NONE ? 0 : 0;
  assign LSQ_is_ldl_inst = load_miss ? LDQ_is_ldl_inst : 
                           STQ2Dcache_command != `BUS_NONE ? 0 :
                           LDQ2Dcache_command != `BUS_NONE ? LDQ_is_ldl_inst : 0;
  // debug
  assign LSQ_NPC_out = load_miss ? LDQ_NPC_out :
                       (LSQ2Dcache_command == `BUS_LOAD) ? LDQ_NPC_out :
                       (LSQ2Dcache_command == `BUS_STORE) ? STQ_NPC_out : 0;
  assign LSQ_IR_out  = load_miss ? LDQ_IR_out : 
                       (LSQ2Dcache_command == `BUS_LOAD) ? LDQ_IR_out :
                       (LSQ2Dcache_command == `BUS_STORE) ? STQ_IR_out : 0;
  
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      load_miss <= `SD 0;
    end
    else begin
      if (mispredict) begin
        load_miss <= `SD 0;
      end
      else if (LSQ2Dcache_command == `BUS_LOAD && !Dcache2proc_done) begin
        load_miss <= `SD 1'b1;
      end
      else if (Dcache2proc_done) begin
        load_miss <= `SD 0;
      end 
    end
  end

/*  always_ff @(posedge clock) begin
    if (reset) begin
      request_priority <= `SD 0;
   end
    else begin
      if (LDQ2Dcache_command != `BUS_NONE && STQ2Dcache_command != `BUS_NONE && Dcache2proc_done) begin
        request_priority <= `SD !request_priority;
      end
    end
  end*/

  always_comb begin
/*    if (LDQ2Dcache_command != `BUS_NONE && STQ2Dcache_command != `BUS_NONE) begin
      LSQ2Dcache_command = request_priority ? STQ2Dcache_command : LDQ2Dcache_command;
      LSQ2Dcache_addr    = request_priority ? STQ2Dcache_addr    : LDDQ2Dcache_addr; 
      LSQ2LDQ_done        = !request_priority && Dcache2proc_done;
      LSQ2STQ_done        = request_priority && Dcache2proc_done;
    end*/
    if (load_miss) begin
      LSQ2Dcache_command   = LDQ2Dcache_command;
      LSQ2Dcache_addr      = LDQ2Dcache_addr;
      LSQ2LDQ_done         = Dcache2proc_done;
      LSQ2STQ_done         = 0;
    end
    else if (STQ2Dcache_command != `BUS_NONE) begin
      LSQ2Dcache_command   = STQ2Dcache_command;
      LSQ2Dcache_addr      = STQ2Dcache_addr;
      LSQ2LDQ_done         = 0;
      LSQ2STQ_done         = (STQ_is_stc_inst && (Dcache2proc_done || stc_fail)) || (!STQ_is_stc_inst && Dcache2proc_done);
    end
    else if (LDQ2Dcache_command != `BUS_NONE) begin
      LSQ2Dcache_command   = LDQ2Dcache_command;
      LSQ2Dcache_addr      = LDQ2Dcache_addr;
      LSQ2LDQ_done         = Dcache2proc_done;
      LSQ2STQ_done         = 0;
    end
    else begin
      LSQ2Dcache_command  = `BUS_NONE;
      LSQ2Dcache_addr     = 0;
      LSQ2LDQ_done        = 0;
      LSQ2STQ_done        = 0;
    end
  end

  LDQ LDQ_0(
    .clock(clock), 
    .reset(reset),
    .mispredict(mispredict),
    .id_rs_valid_inst(id_rs_valid_inst),
    .id_rs_rd_mem(id_rs_rd_mem),
    .id_rs_ldl(id_rs_ldl),
    .id_rs_dest_PRF_num(id_rs_dest_PRF_num),
    .ROB_tail(ROB_tail),
    .ex_mem_ROB_num(ex_mem_ROB_num),
    .ex_mem_ld_inst(ex_mem_ld_inst),
    .ex_mem_ldl_inst(ex_mem_ldl_inst),
    .STQ_valid(STQ_valid),
    .STQ_addr_valid(STQ_addr_valid),
    .STQ_addr(STQ_addr),
    .STQ_resolved_addr_entry_index(STQ_resolved_addr_entry_index),
    .STQ_commit_entry_index(STQ_commit_entry_index),
    .ex_mem_proc2Dcache_addr(ex_mem_proc2Dcache_addr),
    .Dcache2proc_done(LSQ2LDQ_done),
    .id_no_free_PRF(id_no_free_PRF),
    .ROB_dispatch_disable(ROB_dispatch_disable),
    .mem_inst_dispatch_disable(mem_inst_dispatch_disable),
    .RS_full(RS_full),
    .id_rs_NPC(id_rs_NPC),
    .id_rs_IR(id_rs_IR),
    .ex_CDB_arb_stall(ex_CDB_arb_stall),

    .LDQ2Dcache_command(LDQ2Dcache_command),
    .LDDQ2Dcache_addr(LDQ2Dcache_addr),
    .LDQ_CDB_PRF_num(LDQ_CDB_PRF_num),
    .LDQ_is_ldl_inst(LDQ_is_ldl_inst),
    .LDQ_full(LDQ_full),
    .LDQ_NPC_out(LDQ_NPC_out),
    .LDQ_IR_out(LDQ_IR_out)
    );

  STQ STQ_0(
    .clock(clock),
    .reset(reset),
    .mispredict(mispredict),
    .id_rs_valid_inst(id_rs_valid_inst),
    .id_rs_wr_mem(id_rs_wr_mem),
    .id_rs_stc(id_rs_stc),
    .id_rs_dest_PRF_num(id_rs_dest_PRF_num),
    .ROB_head(ROB_head),
    .ROB_tail(ROB_tail),
    .ROB_is_store_inst(ROB_is_store_inst),
    .ex_mem_ROB_num(ex_mem_ROB_num),
    .ex_mem_st_inst(ex_mem_st_inst),
    .ex_mem_stc_inst(ex_mem_stc_inst),
    .ex_mem_proc2Dcache_addr(ex_mem_proc2Dcache_addr),
    .ex_mem_proc2Dcache_data(ex_mem_proc2Dcache_data),
    .id_no_free_PRF(id_no_free_PRF),
    .ROB_dispatch_disable(ROB_dispatch_disable),
    .mem_inst_dispatch_disable(mem_inst_dispatch_disable),
    .Dcache2proc_done(LSQ2STQ_done),
    .RS_full(RS_full),
    .id_rs_NPC(id_rs_NPC),
    .id_rs_IR(id_rs_IR),
    .ex_CDB_arb_stall(ex_CDB_arb_stall),
    .stc_fail(stc_fail),

    .STQ2Dcache_addr(STQ2Dcache_addr),
    .STQ2Dcache_data(STQ2Dcache_data),
    .STQ2Dcache_command(STQ2Dcache_command),
    .STQ_valid(STQ_valid),
    .STQ_addr_valid(STQ_addr_valid),
    .STQ_addr(STQ_addr),
    .STQ_full(STQ_full),
    .STQ_resolved_addr_entry_index(STQ_resolved_addr_entry_index),
    .STQ_commit_entry_index(STQ_commit_entry_index),
    .STQ_head_ROB_num(LSQ_store_ROB_num),
    .STQ_CDB_PRF_num(STQ_CDB_PRF_num),
    .STQ_is_stc_inst(STQ_is_stc_inst),
    .STQ_NPC_out(STQ_NPC_out),
    .STQ_IR_out(STQ_IR_out)
    );

endmodule


module LDQ(
  input                   clock, reset,
  input                   mispredict,
  input                   id_rs_valid_inst,
  input                   id_rs_rd_mem,
  input                   id_rs_ldl,
  input [`PRF_width-1:0]  id_rs_dest_PRF_num,
  input [`ROB_width-1:0]  ROB_tail,
  input [`ROB_width-1:0]  ex_mem_ROB_num,
  input                   ex_mem_ld_inst,
  input                   ex_mem_ldl_inst,
  input [`STQ_SIZE-1:0] STQ_valid,
  input [`STQ_SIZE-1:0] STQ_addr_valid,
  input [`STQ_SIZE-1:0][15:0] STQ_addr,
  input [`STQ_SIZE-1:0] STQ_resolved_addr_entry_index,          // one hot
  input [`STQ_SIZE-1:0] STQ_commit_entry_index,                 // one hot
  input [15:0] ex_mem_proc2Dcache_addr,
  input        Dcache2proc_done,
  input        id_no_free_PRF,
  input        ROB_dispatch_disable,
  input        mem_inst_dispatch_disable,
  input        RS_full,
  input [15:0] id_rs_NPC,
  input [31:0] id_rs_IR,
  input        ex_CDB_arb_stall,

  output logic [1:0] LDQ2Dcache_command,
  output logic [15:0] LDDQ2Dcache_addr,
  output logic [`PRF_width-1:0] LDQ_CDB_PRF_num,
  output logic LDQ_full,
  output logic LDQ_is_ldl_inst,
  // debug
  output logic [15:0] LDQ_NPC_out,
  output logic [31:0] LDQ_IR_out
  );
  
  // entry fields
  logic [`LDQ_SIZE-1:0]                       LDQ_valid;
  logic [`LDQ_SIZE-1:0][`STQ_SIZE-1:0][1:0]   LDQ_dep;
  logic [`LDQ_SIZE-1:0][15:0]                 LDQ_addr;
  logic [`LDQ_SIZE-1:0]                       LDQ_addr_valid;
  logic [`LDQ_SIZE-1:0]                       LDQ_ldl_inst;
  logic [`LDQ_SIZE-1:0][`PRF_width-1:0]       LDQ_dest_PRF_num;
  logic [`LDQ_SIZE-1:0][`ROB_width-1:0]       LDQ_ROB_num;
  // debug
  logic [`LDQ_SIZE-1:0][15:0]                 LDQ_NPC;
  logic [`LDQ_SIZE-1:0][31:0]                 LDQ_IR;
  
  // internal signals
  logic                                       alloc_en;
  logic [`LDQ_WIDTH:0]                        issue_ptr;               // MSB is valid bit
  logic [`LDQ_SIZE-1:0]                       ready_list;
  logic [`LDQ_SIZE-1:0]                       entry_to_issue_index;    // one-hot
  logic [`LDQ_SIZE-1:0]                       next_free_entry_index;   // one-hot

  assign LDQ_full = LDQ_valid == {`LDQ_SIZE{1'b1}};
  assign alloc_en = !LDQ_full && !RS_full && id_rs_valid_inst && !id_no_free_PRF && !ROB_dispatch_disable &&
                    !mem_inst_dispatch_disable && id_rs_rd_mem && !mispredict;
  assign LDQ2Dcache_command = (issue_ptr[2] && LDQ_valid[issue_ptr[1:0]]) ? `BUS_LOAD : 
                              (entry_to_issue_index != 0) ? `BUS_LOAD : `BUS_NONE;
  


  // debug
  always_comb begin
    LDQ_NPC_out = 0;
    LDQ_IR_out = 0;
    if (!issue_ptr[2]) begin
      for (int i = 0; i < `LDQ_SIZE; i++) begin
        if (entry_to_issue_index[i]) begin
          LDQ_NPC_out = LDQ_NPC[i];
          LDQ_IR_out  = LDQ_IR[i];
        end
      end
    end
    else if (LDQ_valid[issue_ptr[1:0]]) begin
      LDQ_NPC_out = LDQ_NPC[issue_ptr[1:0]];
      LDQ_IR_out  = LDQ_IR[issue_ptr[1:0]];
    end
  end

  always_comb begin
    LDQ_is_ldl_inst = 0;
    if (issue_ptr[2]) begin
      LDQ_is_ldl_inst = LDQ_ldl_inst[issue_ptr[1:0]];
    end
    else begin
      for (int i = 0; i < `LDQ_SIZE; i++) begin
        if (entry_to_issue_index[i]) begin
          LDQ_is_ldl_inst = LDQ_ldl_inst[i];
        end
      end
    end
  end

  always_comb begin
    LDQ_CDB_PRF_num = 0;
    if (Dcache2proc_done) begin
      if (issue_ptr[2]) begin
        LDQ_CDB_PRF_num = LDQ_dest_PRF_num[issue_ptr[1:0]];
      end
      else begin
        for (int i = 0; i < `LDQ_SIZE; i++) begin
          if (entry_to_issue_index[i]) begin
            LDQ_CDB_PRF_num = LDQ_dest_PRF_num[i];
          end
        end
      end
    end
  end

  always_comb begin
    LDDQ2Dcache_addr = 0;
    if (issue_ptr[2]) begin
      LDDQ2Dcache_addr = {LDQ_addr[issue_ptr[1:0]][15:3], 3'b0};
    end
    else begin
      for (int i = 0; i < `LDQ_SIZE; i++) begin
        if (entry_to_issue_index[i]) begin
          LDDQ2Dcache_addr = {LDQ_addr[i][15:3], 3'b0};
        end
      end
    end
  end

  always_comb begin
    for (int i = 0; i < `LDQ_SIZE; i++) begin
      ready_list[i] = LDQ_valid[i] && LDQ_addr_valid[i] && (LDQ_dep[i] == {`STQ_SIZE{2'b00}});
    end
  end

  wand_sel alloc_ps (~LDQ_valid, next_free_entry_index);
  wand_sel issue_ps (ready_list, entry_to_issue_index);

  // issue_ptr logic
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      issue_ptr <= `SD 0;
    end
    else begin
      if (mispredict) begin
        issue_ptr <= `SD 0;
      end
      else if (!issue_ptr[2]) begin
        if (LDQ2Dcache_command == `BUS_LOAD && !Dcache2proc_done) begin
          issue_ptr[2] <= `SD 1'b1;
          for (int i = 0; i < `LDQ_SIZE; i++) begin
            if (entry_to_issue_index[i]) begin
              issue_ptr[1:0] <= `SD i;
            end
          end
        end
      end
      else begin
        if (Dcache2proc_done) begin
          issue_ptr[2] <= `SD 1'b0;
        end
      end
    end
  end


  // LDQ_valid, ROB_num & dest_PRF logic
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      LDQ_valid <= `SD 0;
      LDQ_ROB_num <= `SD 0;
      LDQ_dest_PRF_num <= `SD 0;
      LDQ_NPC <= `SD 0;
      LDQ_IR <= `SD 0;
    end
    else begin
      if (mispredict) begin
        LDQ_valid <= `SD 0;
        LDQ_dest_PRF_num <= `SD 0;
        LDQ_ROB_num <= `SD 0;
      end
      else begin
        // allocate a new entry when a load inst is dispatched
        if (alloc_en) begin
          for (int i = 0; i < `LDQ_SIZE; i++) begin
            if (next_free_entry_index[i]) begin
              LDQ_valid[i] <= `SD 1'b1;
              LDQ_ROB_num[i] <= `SD ROB_tail;
              LDQ_dest_PRF_num[i] <= `SD id_rs_dest_PRF_num;
              LDQ_NPC[i] <= `SD id_rs_NPC;
              LDQ_IR[i] <= `SD id_rs_IR;
            end
          end
        end
        // de-allocate a living entry when a load is done
        if (!issue_ptr[2] && Dcache2proc_done) begin                       // be careful when changing LDQ size!!!!
          for (int i = 0; i < `LDQ_SIZE; i++) begin
            if (entry_to_issue_index[i]) begin
              LDQ_valid[i] <= `SD 1'b0;
            end
          end
        end
        else if (issue_ptr[2] && Dcache2proc_done && LDQ_valid[issue_ptr[1:0]]) begin
          LDQ_valid[issue_ptr[1:0]] <= `SD 1'b0;
        end
      end
    end
  end

  // LDQ_addr, LDQ_addr_valid && ldl logic
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      LDQ_addr_valid <= `SD {`LDQ_SIZE{1'b0}};
      LDQ_addr <= `SD {`LDQ_SIZE{64'b0}};
      LDQ_ldl_inst <= `SD 0;
    end
    else begin
      if (mispredict) begin
        LDQ_addr_valid <= `SD 0;
        LDQ_addr <= `SD 0;
        LDQ_ldl_inst <= `SD 0;
      end
      else begin
        if (alloc_en) begin
          for (int i = 0; i < `LDQ_SIZE; i++) begin
            if (next_free_entry_index[i]) begin
              LDQ_addr_valid[i] <= `SD 1'b0;
            end
          end
        end
        // update addr when inst issued
        if ((ex_mem_ldl_inst || ex_mem_ld_inst) && !ex_CDB_arb_stall) begin
          for (int i = 0; i < `LDQ_SIZE; i++) begin
            if (LDQ_valid[i] && (LDQ_ROB_num[i] == ex_mem_ROB_num)) begin
              LDQ_addr_valid[i] <= `SD 1'b1;
              LDQ_addr[i]       <= `SD ex_mem_proc2Dcache_addr;
              LDQ_ldl_inst[i]   <= `SD ex_mem_ldl_inst;
            end
          end
        end
        // inavlidate addr when de-allocated
        if (!issue_ptr[2] && Dcache2proc_done) begin                       // be careful when changing size!!!!
          for (int i = 0; i < `LDQ_SIZE; i++) begin
            if (entry_to_issue_index[i]) begin
              LDQ_addr_valid[i] <= `SD 1'b0;
            end
          end
        end
        else if (issue_ptr[2] && Dcache2proc_done && LDQ_valid[issue_ptr[1:0]]) begin
          LDQ_addr_valid[issue_ptr[1:0]] <= `SD 1'b0;                      // be careful when changing size!!!!
        end
      end
    end
  end

  // dep logic
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      LDQ_dep <= `SD 0;
    end
    else begin
      if (mispredict) begin
        LDQ_dep <= `SD 0;
      end
      else begin
        // write dep table when a load is dispatched (mark to check dependency later)
        if (alloc_en) begin
          for (int i = 0; i < `LDQ_SIZE; i++) begin
            if (next_free_entry_index[i]) begin
              for (int j = 0; j < `STQ_SIZE; j++) begin
                LDQ_dep[i][j] <= `SD (STQ_valid[j] && !STQ_commit_entry_index[j]) ? 2'b01 : 2'b00;
              end
            end
          end
        end
        // update dep when an unknown addr of a LDQ entry is resolved
        if ((ex_mem_ldl_inst || ex_mem_ld_inst) && !ex_CDB_arb_stall) begin
          for (int i = 0; i < `LDQ_SIZE; i++) begin
            if (LDQ_valid[i] && LDQ_ROB_num[i] == ex_mem_ROB_num) begin
              for (int j = 0; j < `STQ_SIZE; j++) begin
                if (LDQ_dep[i][j] == 2'b01) begin
                  if (ex_mem_proc2Dcache_addr == STQ_addr[j] && STQ_addr_valid[j] && !STQ_commit_entry_index[j]) begin
                    LDQ_dep[i][j] <= `SD 2'b10;
                  end
                  else if ((ex_mem_proc2Dcache_addr != STQ_addr[j] && STQ_addr_valid[j]) || STQ_commit_entry_index[j]) begin
                    LDQ_dep[i][j] <= `SD 2'b00;
                  end
                end
              end
            end
          end
        end
        // update dep when an unknown addr of a STQ entry is resolved
        if (STQ_resolved_addr_entry_index != 0 && !ex_CDB_arb_stall) begin
          for (int i = 0; i < `LDQ_SIZE; i++) begin
            if (LDQ_valid[i] && LDQ_addr_valid[i]) begin
              for (int j = 0; j < `STQ_SIZE; j++) begin
                if (STQ_resolved_addr_entry_index[j] && LDQ_dep[i][j] == 2'b01) begin
                  LDQ_dep[i][j] <= `SD (LDQ_addr[i] == ex_mem_proc2Dcache_addr) ? 2'b10 : 2'b00;
                end
              end
            end
          end
        end
        // update dep when an entry in STQ is de-allocated
        if (STQ_commit_entry_index != 0) begin
          for (int i = 0; i < `LDQ_SIZE; i++) begin
//            if (LDQ_valid[i]) begin
              for (int j = 0; j < `STQ_SIZE; j++) begin
                if (STQ_commit_entry_index[j]) begin
                  LDQ_dep[i][j] <= `SD 2'b00;
                end
              end
//            end
          end
        end
      end
    end
  end


endmodule



module STQ(
  input clock, reset,
  input mispredict,
  input id_rs_valid_inst,
  input id_rs_wr_mem,
  input id_rs_stc,
  input [`PRF_width-1:0] id_rs_dest_PRF_num,
  input [`ROB_width-1:0] ROB_head,
  input [`ROB_width-1:0] ROB_tail,
  input ROB_is_store_inst,
  input [`ROB_width-1:0] ex_mem_ROB_num,
  input ex_mem_st_inst,
  input ex_mem_stc_inst,
  input [15:0] ex_mem_proc2Dcache_addr,
  input [63:0] ex_mem_proc2Dcache_data,
  input id_no_free_PRF,
  input ROB_dispatch_disable,
  input mem_inst_dispatch_disable,
  input Dcache2proc_done,
  input RS_full,
  input [15:0]           id_rs_NPC,
  input [31:0]           id_rs_IR,
  input                  ex_CDB_arb_stall,
  input                  stc_fail,

  
  output logic [15:0] STQ2Dcache_addr,
  output logic [63:0] STQ2Dcache_data,
  output logic [1:0] STQ2Dcache_command,
  output logic [`STQ_SIZE-1:0] STQ_valid,
  output logic [`STQ_SIZE-1:0] STQ_addr_valid,
  output logic [`STQ_SIZE-1:0][15:0] STQ_addr,
  output logic STQ_full,
  output logic [`STQ_SIZE-1:0] STQ_resolved_addr_entry_index,
  output logic [`STQ_SIZE-1:0] STQ_commit_entry_index,
  output logic [`ROB_width-1:0] STQ_head_ROB_num,
  output logic [`PRF_width-1:0] STQ_CDB_PRF_num,
  output logic                  STQ_is_stc_inst,
  // debug
  output logic [15:0] STQ_NPC_out,
  output logic [31:0] STQ_IR_out
  );

  logic [1:0] STQ_head, STQ_tail;
  logic [`STQ_SIZE-1:0][63:0] STQ_data;
  logic [`STQ_SIZE-1:0]       STQ_stc_inst;
  logic [`STQ_SIZE-1:0][`ROB_width-1:0] STQ_ROB_num;
  logic [`STQ_SIZE-1:0][15:0] STQ_NPC;
  logic [`STQ_SIZE-1:0][31:0] STQ_IR;
  logic [`STQ_SIZE-1:0][`PRF_width-1:0] STQ_dest_PRF_num;

  logic alloc_en;
  
  assign STQ_full = (STQ_head == STQ_tail) && STQ_valid[STQ_tail];
  assign alloc_en = id_rs_valid_inst && !STQ_full && !RS_full && !ROB_dispatch_disable && !id_no_free_PRF &&
                    !mem_inst_dispatch_disable && id_rs_wr_mem && !mispredict;
  assign STQ_head_ROB_num = STQ_ROB_num[STQ_head];
  assign STQ2Dcache_command = (STQ_valid[STQ_head] && STQ_addr_valid[STQ_head] && ROB_head == STQ_ROB_num[STQ_head]) ? `BUS_STORE : `BUS_NONE;
  //debug
  assign STQ_NPC_out = STQ_NPC[STQ_head];
  assign STQ_IR_out  = STQ_IR[STQ_head];

  assign STQ2Dcache_addr = STQ_addr[STQ_head];
  assign STQ2Dcache_data = STQ_data[STQ_head];
  assign STQ_CDB_PRF_num = STQ_dest_PRF_num[STQ_head];
  assign STQ_is_stc_inst = STQ_valid[STQ_head] && STQ_addr_valid[STQ_head] && STQ_stc_inst[STQ_head] && ROB_head == STQ_ROB_num[STQ_head];

  always_comb begin
    STQ_commit_entry_index = 0;
    if (STQ_valid[STQ_head] && STQ_addr_valid[STQ_head] && ROB_head == STQ_ROB_num[STQ_head] && (Dcache2proc_done || (STQ_is_stc_inst && stc_fail))) begin
        STQ_commit_entry_index[STQ_head] = 1'b1;
    end
  end

  // STQ_head and valid logic 
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      STQ_valid <= `SD 0;
      STQ_head <= `SD 0;
      STQ_ROB_num <= 0;
      STQ_NPC <= `SD 0;
      STQ_IR <= `SD 0;
      STQ_dest_PRF_num <= `SD 0;
    end
    else begin
      if (mispredict) begin
        STQ_valid <= `SD 0;
        STQ_head <= `SD 0;
        STQ_ROB_num <= 0;
        STQ_NPC <= `SD 0;
        STQ_IR <= `SD 0;
        STQ_dest_PRF_num <= `SD 0;
      end
      
      else begin
        // move STQ_head when the pointed entry is de-allocated
        if (STQ_valid[STQ_head] && STQ_addr_valid[STQ_head] && ROB_head == STQ_ROB_num[STQ_head] && (Dcache2proc_done || (STQ_is_stc_inst && stc_fail))) begin    // modification needed to support stc
          STQ_valid[STQ_head] <= `SD 1'b0;
          STQ_head <= `SD STQ_head + 1'b1;
        end
        // allocate a new entry when dispatched
        if (alloc_en) begin
          STQ_valid[STQ_tail] <= `SD 1'b1;
          STQ_ROB_num[STQ_tail] <= `SD ROB_tail;
          STQ_NPC[STQ_tail] <= `SD id_rs_NPC;
          STQ_IR[STQ_tail] <= `SD id_rs_IR;
          STQ_dest_PRF_num[STQ_tail] <= `SD id_rs_dest_PRF_num;
        end
      end
    end
  end

  // STQ_tail logic
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      STQ_tail <= `SD 0;
    end
    else begin
      if (mispredict) begin
        STQ_tail <= `SD 0;
      end
      // move STQ_tail when a new instruction is dispatched 
      else if (alloc_en) begin
        STQ_tail <= `SD STQ_tail + 1'b1;
      end
    end
  end

  // STQ_addr, STQ_addr_valid, STQ_data, and stc logic when issued
  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      STQ_addr <= `SD 0;
      STQ_addr_valid <= `SD 0;
      STQ_data <= `SD 0;
      STQ_stc_inst <= `SD 0;
    end
    else begin
      if (mispredict) begin
        STQ_addr_valid <= `SD 0;
      end
      else begin
        if (alloc_en) begin
          STQ_addr_valid[STQ_tail] <= `SD 1'b0;
        end
        // update when a store is issued
        if ((ex_mem_st_inst || ex_mem_stc_inst) && !ex_CDB_arb_stall) begin
          for (int j = 0; j < `STQ_SIZE; j++) begin
            if (STQ_valid[j] && (STQ_ROB_num[j] == ex_mem_ROB_num)) begin
              STQ_addr[j] <= `SD ex_mem_proc2Dcache_addr;
              STQ_addr_valid[j] <= `SD 1;
              STQ_data[j] <= `SD ex_mem_proc2Dcache_data;
              STQ_stc_inst[j] <= `SD ex_mem_stc_inst;
            end
          end
        end
        // reset an entry upon de-allocation
        if (STQ_valid[STQ_head] && STQ_addr_valid[STQ_head] && ROB_head == STQ_ROB_num[STQ_head] && (Dcache2proc_done || (STQ_is_stc_inst && stc_fail))) begin
          STQ_addr_valid[STQ_head] <= `SD 0;
        end
      end
    end
  end
  
  // STQ_resolved_addr_entry_index logic
  always_comb begin
    STQ_resolved_addr_entry_index = 0;
    if ((ex_mem_st_inst || ex_mem_stc_inst) && !ex_CDB_arb_stall) begin
      for (int j = 0; j < `STQ_SIZE; j++) begin
        if (STQ_valid[j] && (STQ_ROB_num[j] == ex_mem_ROB_num)) begin
          STQ_resolved_addr_entry_index[j] = 1'b1;
        end
      end
    end
  end


endmodule



/*
   wand_sel - Priority selector module.
   updated for SystemVerilog: 3/18/2015 by szekany
*/
`default_nettype none
module wand_sel (req,gnt);
  // synopsys template
  parameter WIDTH=4;
  input logic  [WIDTH-1:0] req;
  output wand [WIDTH-1:0] gnt;

  logic  [WIDTH-1:0] req_r;
  wand  [WIDTH-1:0] gnt_r;

  //priority selector
  genvar i;
  generate
    for (i = 0; i < WIDTH; i = i + 1)
    begin : reverse
      assign req_r[WIDTH-1-i] = req[i];
      assign gnt[WIDTH-1-i]   = gnt_r[i];
    end

    for (i = 0; i < WIDTH-1 ; i = i + 1)
    begin : steve_is_verilog_genius  // confirmed
      assign gnt_r [WIDTH-1:i] = {{(WIDTH-1-i){~req_r[i]}},req_r[i]};
    end
  endgenerate
  assign gnt_r[WIDTH-1] = req_r[WIDTH-1];

endmodule
`default_nettype wire