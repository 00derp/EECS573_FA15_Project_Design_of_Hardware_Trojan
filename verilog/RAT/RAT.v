//////////////////////////////////////////////////////////////////////////
//                                                                      //
//   Modulename :  RAT.v                                                //
//                                                                      //
//  Description :  Renaming Table                                       //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

`define SD #1
`define PRF_width 6
`define ARF_width 5
`define ARF_size  32
`define PRF_size 32

 module RAT(
  input clock, reset, squash, valid_inst_in, 
  input [`ARF_width-1:0]                srcA_ARF_num_in,
  input [`ARF_width-1:0]                srcB_ARF_num_in,
  input [`ARF_width-1:0]                dest_ARF_num_in,
  input [`PRF_width-1:0]                dest_PRF_num_in,
  input [`ARF_size-1:0][`PRF_width-1:0] RRAT_in,

  output wor   [`PRF_width-1:0]         srcA_PRF_num_out,
  output wor   [`PRF_width-1:0]         srcB_PRF_num_out,
  output logic                          RAT_req_out
//  output logic [`PRF_width-1:0]         dest_PRF_num_out
  );
  
  logic [`ARF_size-1:0] srcA_entry_rd_en;
  logic [`ARF_size-1:0] srcB_entry_rd_en;
  logic [`ARF_size-1:0] entry_wr_en;
  logic [`ARF_size-1:0][`PRF_width-1:0] entry_PRF_num_in;


//  wor [`PRF_width-1:0] srcA_PRF_num_out;
//  wor [`PRF_width-1:0] srcB_PRF_num_out;

  assign srcA_entry_rd_en = /*valid_inst_in ? */ 1 << srcA_ARF_num_in /* : 0*/;
  assign srcB_entry_rd_en = /*valid_inst_in ? */ 1 << srcB_ARF_num_in /* : 0*/;
  assign entry_wr_en      = (reset) ? 0 :
                            (squash) ? 32'hFFFFFFFF :
                            (!valid_inst_in || dest_ARF_num_in == 5'h1F) ? 0 : 1 << dest_ARF_num_in;
  assign entry_PRF_num_in = squash ? RRAT_in : {32{dest_PRF_num_in}};
  assign RAT_req_out      = valid_inst_in && (dest_ARF_num_in != 5'h1F);

  RAT_entry RAT32 [31:0] (
    .clock(clock),
    .reset(reset),
    .wr_en(entry_wr_en),
    .srcA_rd_en(srcA_entry_rd_en),
    .srcB_rd_en(srcB_entry_rd_en),
    .PRF_num_in(entry_PRF_num_in),

    .srcA_PRF_num_out(srcA_PRF_num_out),
    .srcB_PRF_num_out(srcB_PRF_num_out)
  );

endmodule


module RAT_entry (
  input clock, reset, wr_en, srcA_rd_en, srcB_rd_en,
  input [`PRF_width-1:0]  PRF_num_in,

  output logic [`PRF_width-1:0] srcA_PRF_num_out,
  output logic [`PRF_width-1:0] srcB_PRF_num_out
);

  logic [`PRF_width-1:0] PRF_num;

  assign srcA_PRF_num_out = srcA_rd_en ? PRF_num : 0;
  assign srcB_PRF_num_out = srcB_rd_en ? PRF_num : 0;

  always_ff @(posedge clock) begin
    if (reset)
      PRF_num <= `SD 0;
    else
      if (wr_en)
        PRF_num <= `SD PRF_num_in;
  end
endmodule




/*
  logic [`ARF_size-1:0] [`PRF_width-1:0] PRF_num;

  assign srcA_PRF_num_out = PRF_num[srcA_ARF_num_in];
  assign srcB_PRF_num_out = PRF_num[srcB_ARF_num_in];
  assign dest_PRF_num_out = (reset || squash || !valid_inst_in || dest_ARF_num_in == 5'h1F) ? 0 : dest_PRF_num_in;      // feed this signal back to free list so that free list knows if renaming happens

  always_ff @(posedge clock) begin
    if (reset) begin
      PRF_num <= `SD 0;
    end
    else begin
      if (squash)
        PRF_num <= `SD RRAT_in;
      else if (dest_ARF_num_in != 5'h1F & valid_inst_in)
        PRF_num[dest_ARF_num_in] <= `SD dest_PRF_num_in;
    end
  end
  */
