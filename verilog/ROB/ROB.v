//////////////////////////////////////////////////////////////////////////
//                                                                      //
//   Modulename :  ROB.v                                                //
//                                                                      //
//  Description :  Re-Order Buffer                                      //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps

`define SD #1
`define ROB_size 32
`define ROB_width 5
`define ARF_width 5
`define PRF_width 6

module ROB (
  input clock, reset,
  input                  id_rs_valid_inst_in,
  input [`ARF_width-1:0] id_rs_ARF_num_in,
  input [`PRF_width-1:0] id_rs_PRF_num_in,
  input                  id_rs_is_branch_inst_in, 
  input                  id_rs_is_store_inst_in, 
  input [63:0]           id_rs_PC_plus_4_in,
  input                  id_rs_illegal_in,
  input                  id_rs_halt_in,             
  input [63:0]           ex_NPC_in,
  input                  ex_branch_mispredict_in,
  input                  ex_branch_inst_in,
  input                  ex_store_inst_in,
  input [`ROB_width-1:0] ex_ROB_num_in, //for updating branch and store
  input [`PRF_width-1:0] CDB_tag_in,

  output wor   [`ARF_width-1:0] ROB_ARF_num_out,
  output wor   [`PRF_width-1:0] ROB_PRF_num_out,
  output wor   [63:0]           ROB_PC_plus_4_out,
  output wor   [63:0]           ROB_NPC_out,
  output wor                    ROB_branch_mispredict_out,
  output wor                    ROB_is_store_inst_out,
  output wor                    ROB_is_branch_inst_out,
  output wor                    ROB_commit_out,
  output wor                    ROB_illegal_out,
  output wor                    ROB_halt_out,
  output logic                  ROB_dispatch_disable,
  output logic [`ROB_width-1:0] ROB_head,
  output logic [`ROB_width-1:0] ROB_tail
);
  
  logic [`ROB_size-1:0]  entry_wr_en, entry_rd_en, branch_resolved_en, store_resolved_en;
  logic                  wr_en;
  wor                    valid;

  assign ROB_dispatch_disable = (ROB_head == ROB_tail) & valid & ~ROB_commit_out;

  assign wr_en                = id_rs_valid_inst_in & ~ROB_dispatch_disable;
  assign entry_wr_en          = wr_en ?             1 << ROB_tail : 0;
  assign entry_rd_en          =                     1 << ROB_head;
  assign branch_resolved_en   = ex_branch_inst_in ? 1 << ex_ROB_num_in : 0;
  assign store_resolved_en    = ex_store_inst_in  ? 1 << ex_ROB_num_in : 0;

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
    .done_out(ROB_commit_out),
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
  input [63:0]           id_rs_PC_plus_4_in,  
  input                  id_rs_illegal_in,
  input                  id_rs_halt_in,          
  input [63:0]           ex_NPC_in,
  input                  ex_branch_mispredict_in,
  input                  branch_resolved,
  input                  store_resolved,
  input [`PRF_width-1:0] CDB_tag_in,
  
  output logic [`ARF_width-1:0] ARF_num_out,
  output logic [`PRF_width-1:0] PRF_num_out,
  output logic                  is_branch_inst_out,
  output logic                  is_store_inst_out,
  output logic [63:0]           PC_plus4_out,
  output logic [63:0]           NPC_out,
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
  logic [63:0]           PC_plus_4;
  logic [63:0]           NPC;
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
        if (ex_branch_mispredict_in) begin
          NPC               <= `SD ex_NPC_in;
          branch_mispredict <= `SD ex_branch_mispredict_in;
        end
        done              <= `SD 1;
      end
    end
  end

  always_ff @(posedge clock) begin
    if (reset)
      valid <= `SD 0;
    else 
      if (squash)
        valid <= `SD 0;
      else if (wr_en)
        valid <= `SD 1;
      else if (rd_en)
        valid <= `SD valid_next;
  end

endmodule
