/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  PRF_VL.v                                            //
//                                                                     //
//  Description :  This module creates the PRF valid list              // 
//                                                                     //
//                                                                     //
/////////////////////////////////////////////////////////////////////////


`timescale 1ns/100ps


module PRF_VL(
    input                         clock, reset,
    input                         ROB_mispredict_in,
    input  [`PRF_size-1:0]        RRAT_PRF_FL_in,
    input  [`PRF_width-1:0]       ex_wr_idx_in,
    input  [`PRF_width-1:0]       RAT_rda_idx_in,
    input  [`PRF_width-1:0]       RAT_rdb_idx_in,
    input  [`PRF_width-1:0]       RRAT_free_PRF_num_in,

    output logic                  rda_valid_out,
    output logic                  rdb_valid_out   
);
    logic [`PRF_size-1:0]  PRF_free_enable;
    logic [`PRF_size-1:0]  PRF_wr_enable;
    logic [`PRF_size-1:0]  PRF_valid_list;

    assign rda_valid_out   = PRF_valid_list[RAT_rda_idx_in];
    assign rdb_valid_out   = PRF_valid_list[RAT_rdb_idx_in];
    assign PRF_free_enable = ROB_mispredict_in ? RRAT_PRF_FL_in : (1 << RRAT_free_PRF_num_in);
    assign PRF_wr_enable   = (ex_wr_idx_in != 0) ? (1 << ex_wr_idx_in) : 0;

    valid_entry PRF_valid [`PRF_size-1:0](
        .clock(clock),
        .reset(reset),
        .valid_en(PRF_wr_enable),
        .free_en(PRF_free_enable),

        .valid_out(PRF_valid_list)
  );

endmodule

module valid_entry(
  input        clock, reset,
  input        valid_en,
  input        free_en,
  
  output logic valid_out
);

  //synopsys sync_set_reset "reset"
  always_ff @ (posedge clock) begin
    if (reset)
      valid_out <= `SD 0;
    else
      if (free_en)
         valid_out <= `SD 0;
      else if (valid_en)
         valid_out <= `SD 1;
  end
endmodule

