//////////////////////////////////////////////////////////////////////////
//                                                                      //
//   Modulename :  RRAT.v                                               //
//                                                                      //
//  Description :  Retirement RAT                                       //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps
`define PRF_size  64
`define ARF_width 5
`define PRF_width 6
`define RS_size 8

module RRAT(
  input                             clock, reset,
  input        [`ARF_width-1:0]     ROB_ARF_num_in,
  input        [`PRF_width-1:0]     ROB_PRF_num_in,
  input                             ROB_commit_in,

  output logic [`PRF_size-1:0]      RRAT_PRF_FL_out,
  output logic [32*`PRF_width-1:0]  RRAT_copy_out,
  output logic [`PRF_width-1:0]     RRAT_free_PRF_num_out
);
  logic [`PRF_size-1:0] FL_free_en;
  logic [`PRF_size-1:0] FL_wr_en;
  logic [31:0]          RRAT_wr_en;
  
  wor [`PRF_width-1:0] free_PRF_num;

  assign FL_free_en            = ROB_commit_in? 1 << free_PRF_num : 0;
  assign FL_wr_en              = ROB_commit_in? 1 << ROB_PRF_num_in : 0;
  assign RRAT_wr_en            = ROB_commit_in? 1 << ROB_ARF_num_in : 0;
  assign RRAT_free_PRF_num_out = ROB_commit_in? free_PRF_num : 0;

  RRAT_entry RRAT32 [31:0] (
    .clock(clock),
    .reset(reset),
    .wr_en(RRAT_wr_en),
    .ROB_PRF_num_in({32{ROB_PRF_num_in}}),
    
    .PRF_num_out(RRAT_copy_out),
    .RRAT_free_PRF_num_out(free_PRF_num)
  );

  RRAT_FL_entry FL [`PRF_size-1:0] (
    .clock(clock),
    .reset(reset),
    .free_en(FL_free_en),
    .wr_en(FL_wr_en),

    .free_out(RRAT_PRF_FL_out)
  );
endmodule

module RRAT_entry(
  input clock, reset,
  input wr_en,
  input [`PRF_width-1:0] ROB_PRF_num_in,
  
  output logic [`PRF_width-1:0] PRF_num_out,
  output logic [`PRF_width-1:0] RRAT_free_PRF_num_out
);
  logic [`PRF_width-1:0] PRF_num;

  assign RRAT_free_PRF_num_out = wr_en ? PRF_num:0;
  assign PRF_num_out           = wr_en ? ROB_PRF_num_in : PRF_num;

  //synopsys sync_set_reset "reset"
  always_ff @ (posedge clock) begin
    if (reset)
      PRF_num <= `SD 0;
    else
      if (wr_en)
        PRF_num <= `SD ROB_PRF_num_in;
  end

endmodule

module RRAT_FL_entry(
  input clock, reset,
  input free_en,
  input wr_en,

  output logic free_out
);

  logic free;
  assign free_out = wr_en? 0 : 
                    free_en ? 1 : free;
//synopsys sync_set_reset "reset"
  always_ff @ (posedge clock) begin
    if (reset)
      free <= `SD 1;
    else
      if (wr_en)
         free <= `SD 0;
      else if (free_en)
         free <= `SD 1;
  end
endmodule

