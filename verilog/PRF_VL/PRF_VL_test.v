`timescale 1ns/100ps

module testbench();
    logic                         clock, reset;
    logic                         ROB_mispredict_in;
    logic  [`PRF_size-1:0]        RRAT_PRF_FL_in;
    logic  [`PRF_width-1:0]       ex_wr_idx_in;
    logic  [`PRF_width-1:0]       RAT_rda_idx_in;
    logic  [`PRF_width-1:0]       RAT_rdb_idx_in;
    logic  [`PRF_width-1:0]       RRAT_free_PRF_num_in;

    logic                  rda_valid_out;
    logic                  rdb_valid_out;  



  PRF_VL dut (
    .clock(clock),
    .reset(reset),
    .ROB_mispredict_in(ROB_mispredict_in),
    .RRAT_PRF_FL_in(RRAT_PRF_FL_in),
    .ex_wr_idx_in(ex_wr_idx_in),
    .RAT_rda_idx_in(RAT_rda_idx_in),
    .RAT_rdb_idx_in(RAT_rdb_idx_in),
    .RRAT_free_PRF_num_in(RRAT_free_PRF_num_in),

    .rda_valid_out(rda_valid_out),
    .rdb_valid_out(rdb_valid_out)
    );

  always begin
    #5;
    clock=~clock;
  end
  
  initial begin
  	reset = 1;
  	clock = 0;
    ROB_mispredict_in = 0;
    RRAT_PRF_FL_in = 0;
    ex_wr_idx_in = 0;
    RAT_rda_idx_in = 0;
    RAT_rdb_idx_in = 0;
    RRAT_free_PRF_num_in = 0;

    @(negedge clock);
    reset = 0;
    ex_wr_idx_in = 1;
    @(negedge clock);
    ex_wr_idx_in = 2;
    @(negedge clock);
    RAT_rda_idx_in = 1;
    RAT_rdb_idx_in = 2;
    @(negedge clock);
    ROB_mispredict_in = 1;
    RRAT_PRF_FL_in = 64'hFFFF_FFFF_FFFF_FFFD;
    @(negedge clock);
    ROB_mispredict_in = 0;
    @(negedge clock);
    $finish;
  end
endmodule

