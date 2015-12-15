/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  if_stage.v                                          //
//                                                                     //
//  Description :  instruction fetch (IF) stage of the pipeline;       // 
//                 fetch instruction, compute next PC location, and    //
//                 send them down the pipeline.                        //
//                                                                     //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps
`define PHT_size 64
`define HISTORY_width 6
`define ADDR_width 6
`define BHT_size 64
`define NUM_SETS 32
`define SET_INDEX 5

module if_stage(
				  input         clock,                      // system clock
				  input         reset,                      // system reset
				  input         if_id_enable,          
													       
				  input         ROB_branch_mispredict_in,     
          input         ex_branch_inst_in,
          input         ex_branch_result_in,
          input         ex_is_uncond_branch_in,  
          input  [15:0] ex_PC_plus_4_in,
          input  [15:0] ex_NPC_in,
				  input  [63:0] ROB_NPC_in,           // target pc: use if take_branch is TRUE
				  input  [63:0] Imem2proc_data,		        // Data coming back from instruction-memory
				  input         Imem_valid,

				  output logic [63:0] proc2Imem_addr,		// Address sent to Instruction memory
				  output logic [63:0] if_NPC_out,			// PC of instruction after fetched (PC+4).
				  output logic [31:0] if_IR_out,			// fetched instruction out
				  output logic        if_valid_inst_out,	    // when low, instruction is garbage
          output logic [15:0] if_predicted_target_addr_out,
          output logic        if_predicted_taken_out
               );

	logic    [63:0] PC_reg;               // PC we are currently fetching
//	logic           ready_for_valid;

	logic   [63:0] PC_plus_4;
	logic   [63:0] next_PC;
	logic          PC_enable;
//	logic          next_ready_for_valid;

	assign proc2Imem_addr = {PC_reg[63:3], 3'b0};

	// this mux is because the Imem gives us 64 bits not 32 bits
	assign if_IR_out = PC_reg[2] ? Imem2proc_data[63:32] : Imem2proc_data[31:0];

	// default next PC value
	assign PC_plus_4 = PC_reg + 4;

	// next PC is target_pc if there is a taken branch or
	// the next sequential PC (PC+4) if no branch
	// (halting is handled with the enable PC_enable;
	//assign next_PC = ROB_branch_mispredict_in ? ROB_NPC_in : PC_plus_4;

	// The take-branch signal must override stalling (otherwise it may be lost)
	assign PC_enable=(if_valid_inst_out & if_id_enable )| ROB_branch_mispredict_in;

	// Pass PC+4 down pipeline w/instruction
	assign if_NPC_out = PC_plus_4;

	assign if_valid_inst_out = Imem_valid; //ready_for_valid & ;


  //For branch predictions
  logic        hit, uncond_branch, branch_prediction;
  logic [15:0] predicted_PC;

  BP branch_predictor (
    .clock(clock),
    .reset(reset),
    .if_valid_inst(if_valid_inst_out),
    .if_instruction_in(PC_plus_4),
    .ex_PC_plus_4_in({48'b0,ex_PC_plus_4_in}),
    .ex_branch_result_in(ex_branch_result_in),
    .ex_branch_resolved_in(ex_branch_inst_in & ~ex_is_uncond_branch_in),

    .branch_prediction_out(branch_prediction)
    );

  BTB branch_target_buffer (
    .clock(clock),
    .reset(reset),
    .if_valid_inst(if_valid_inst_out),
    .if_PC_plus_4_in(PC_plus_4[15:0]),
    .ex_PC_plus_4_in(ex_PC_plus_4_in),
    .ex_target_PC_in(ex_NPC_in),
    .ex_branch_inst_in(ex_branch_inst_in),
    .ex_is_uncond_branch_in(ex_is_uncond_branch_in),

    .hit(hit),
    .uncond_branch(uncond_branch),
    .predicted_PC(predicted_PC)
    );

  assign if_predicted_target_addr_out = next_PC;
  assign if_predicted_taken_out = branch_prediction & hit;

  always_comb begin
    next_PC = PC_plus_4;
    if (ROB_branch_mispredict_in)
      next_PC = ROB_NPC_in;
    else if (hit && ((branch_prediction == 1) || uncond_branch))
      next_PC = {48'b0,predicted_PC};
  end

	// synopsys sync_set_reset "reset"
	always_ff @(posedge clock)
	begin
		if(reset)
			PC_reg <= `SD 0;       // initial PC value is 0
		else begin
			if(PC_enable)
				PC_reg <= `SD next_PC; // transition to next PC
		end
	end  // always

	// This FF controls the stall signal that artificially forces
	// fetch to stall until the previous instruction has completed
	// synopsys sync_set_reset "reset"
/*	always_ff @(posedge clock)
	begin
		if (reset)
			ready_for_valid <= `SD 1;  // must start with something
		else
			ready_for_valid <= `SD next_ready_for_valid;
	end*/
  
endmodule  // module if_stage

module BTB (
  input        clock, reset,
  input        if_valid_inst,
  input [15:0] if_PC_plus_4_in,
  input [15:0] ex_PC_plus_4_in, //for updating
  input [15:0] ex_target_PC_in, //for updating
  input        ex_branch_inst_in,
  input        ex_is_uncond_branch_in,

  output wor        hit,
  output wor        uncond_branch,
  output wor [15:0] predicted_PC
  );

  logic [`NUM_SETS-1:0] rd_enable, wr_enable;

  assign rd_enable = if_valid_inst ? 1 << if_PC_plus_4_in[`SET_INDEX-1:0] : 0;
  assign wr_enable = ex_branch_inst_in ? 1 << ex_PC_plus_4_in[`SET_INDEX-1:0] : 0;

  BTB_entry BTB_32 [`NUM_SETS-1:0](
    .clock(clock),
    .reset(reset),
    .rd_enable(rd_enable),
    .rd_tag(if_PC_plus_4_in[15:`SET_INDEX]),
    .wr_enable(wr_enable),
    .is_uncond_branch(ex_is_uncond_branch_in),
    .update_tag(ex_PC_plus_4_in[15:`SET_INDEX]),
    .update_target_PC(ex_target_PC_in),

    .hit(hit),
    .uncond_branch(uncond_branch),
    .predicted_PC(predicted_PC)
    );
endmodule

module BTB_entry(
  input                   clock, reset,
  input                   rd_enable,
  input [15-`SET_INDEX:0] rd_tag,
  input                   wr_enable,
  input                   is_uncond_branch,
  input [15-`SET_INDEX:0] update_tag,
  input [15:0]            update_target_PC,

  output logic        hit,
  output logic        uncond_branch,
  output logic [15:0] predicted_PC
  );

  logic LRU_bit, next_LRU_bit;

  logic [1:0] valid, next_valid;
  logic [1:0] uncond, next_uncond;

  logic [1:0] [15:0]            branch_target_addr;
  logic [1:0] [15-`SET_INDEX:0] tag;

  logic wr_idx;

  always_comb begin
    next_LRU_bit  = LRU_bit;
    next_valid    = valid;
    next_uncond   = uncond;
    hit           = 0;
    uncond_branch = 0;
    predicted_PC  = 0;
    wr_idx        = 0;

    if (rd_enable) begin
      if ((rd_tag == tag[0]) && valid[0]) begin
        hit           = 1;
        uncond_branch = uncond[0];
        next_LRU_bit  = 1;
        predicted_PC  = branch_target_addr[0];
      end
      else if ((rd_tag == tag[1]) && valid[1]) begin
        hit           = 1;
        uncond_branch = uncond[1];
        next_LRU_bit  = 0;
        predicted_PC  = branch_target_addr[1];
      end
    end

    if (wr_enable) begin
      if (update_tag == tag[0])
        wr_idx = 0;
      else if (update_tag == tag[1])
        wr_idx = 1;
      else
        wr_idx = LRU_bit;

      if (wr_idx == 0) begin
        next_valid[0]          = 1;
        next_uncond[0]         = is_uncond_branch;
        next_LRU_bit           = 1;
      end
      else begin
        next_valid[1]          = 1;
        next_uncond[1]         = is_uncond_branch;
        next_LRU_bit           = 0;
      end
    end
  end

  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset)
      LRU_bit <= `SD 0;
    else begin
      if (wr_enable | rd_enable)
        LRU_bit <= `SD next_LRU_bit;
    end
  end

  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      valid  <= `SD 0;
      uncond <= `SD 0;
    end
    else begin
      if (wr_enable) begin
        valid  <= `SD next_valid;
        uncond <= `SD next_uncond;
      end
    end
  end

  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      branch_target_addr <= `SD 0;
      tag                <= `SD 0;
    end
    else begin 
      if (wr_enable) begin
        branch_target_addr[wr_idx] <= `SD update_target_PC;
        tag[wr_idx]                <= `SD update_tag;
      end
    end
  end
endmodule



module BP(
  input                   clock, reset,
  input                   if_valid_inst,
  input [63:0]            if_instruction_in,
  input [63:0]            ex_PC_plus_4_in,
  input                   ex_branch_result_in,
  input                   ex_branch_resolved_in, //////////// signal that this current result is for a branch.

  output wor              branch_prediction_out
);
  logic [`BHT_size-1:0]      BHT_wr_enable;
  logic [`BHT_size-1:0]      BHT_rd_enable;
  logic [`PHT_size-1:0]      PHT_wr_enable;
  logic [`PHT_size-1:0]      PHT_rd_enable;
  wor   [`HISTORY_width-1:0] PHT_rd_index;
  wor   [`HISTORY_width-1:0] PHT_wr_index;

  assign BHT_wr_enable = ex_branch_resolved_in ? 1 << (ex_PC_plus_4_in[`ADDR_width-1:0]):0;
  assign BHT_rd_enable = if_valid_inst ? 1 << (if_instruction_in[`ADDR_width-1:0]) : 0;

  assign PHT_rd_enable = 1 << PHT_rd_index;
  assign PHT_wr_enable = ex_branch_resolved_in ? 1 << PHT_wr_index : 0;  

BHT_entry BHT_table [`BHT_size-1:0](
  .clock(clock),
  .reset(reset),
  .wr_en(BHT_wr_enable),
  .rd_en(BHT_rd_enable),
  .branch_result(ex_branch_result_in),
   
  .PHT_rd_history(PHT_rd_index),
  .PHT_wr_history(PHT_wr_index)
);

PHT_entry PHT_table [`PHT_size-1:0](
  .clock(clock),
  .reset(reset),
  .branch_result(ex_branch_result_in),
  .wr_en(PHT_wr_enable),
  .rd_en(PHT_rd_enable),

  .prediction_out(branch_prediction_out)
);

endmodule

module BHT_entry(
  input                             clock, reset,                 
  input                             wr_en,
  input                             rd_en,
  input                             branch_result,

  output logic [`HISTORY_width-1:0] PHT_rd_history,
  output logic [`HISTORY_width-1:0] PHT_wr_history
);
  logic [`HISTORY_width-1:0] next_history;
  logic [`HISTORY_width-1:0] history;
  
  assign next_history   = {history[`HISTORY_width-2:0], branch_result};
  assign PHT_rd_history = rd_en ? history : 0;
  assign PHT_wr_history = wr_en ? history : 0;

  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset)
      history <= `SD 0;
    else begin
      if(wr_en)
        history <= `SD next_history;
    end
  end
endmodule

module PHT_entry(
  input                    clock, reset,
  input                    branch_result,
  input                    wr_en,
  input                    rd_en,

  output logic             prediction_out
);

logic [1:0] prediction;
logic [1:0] next_prediction;
//assign prediction_out = rd_en ? branch_result : prediction[1];
assign prediction_out = rd_en ? prediction[1] : 0;

always_comb
  case (prediction)
    2'b00: next_prediction = branch_result? 2'b01:2'b00;
    2'b01: next_prediction = branch_result? 2'b10:2'b00;
    2'b10: next_prediction = branch_result? 2'b11:2'b01;
    2'b11: next_prediction = branch_result? 2'b11:2'b10;
  endcase

//synopsys sync_set_reset "reset"
always_ff @(posedge clock) begin
  if (reset)
     prediction <= `SD 2'b10;
  else begin
    if (wr_en)
      prediction <= `SD next_prediction;
  end
end
endmodule
