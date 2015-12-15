`timescale 1ns/100ps


module testbench();

  logic                      clock, reset;
  logic [`ARF_width-1:0]     ROB_ARF_num_in;
  logic [`PRF_width-1:0]     ROB_PRF_num_in;
  logic                      ROB_commit_in;

  logic [`PRF_size-1:0]      RRAT_PRF_FL_out;
  logic [32*`PRF_width-1:0]  RRAT_copy_out;
  logic [`PRF_width-1:0]     RRAT_free_PRF_num_out;


  RRAT dut (
    .clock(clock),
    .reset(reset),
    .ROB_ARF_num_in(ROB_ARF_num_in),
    .ROB_PRF_num_in(ROB_PRF_num_in),
    .ROB_commit_in(ROB_commit_in),

    .RRAT_PRF_FL_out(RRAT_PRF_FL_out),
    .RRAT_copy_out(RRAT_copy_out),
    .RRAT_free_PRF_num_out(RRAT_free_PRF_num_out)
    );

  always begin
    #5;
    clock=~clock;
  end
  
  initial begin
  	reset = 1;
  	clock = 0;
    ROB_ARF_num_in = 0;
    ROB_PRF_num_in = 0;
    ROB_commit_in = 0;
    @(negedge clock);
    reset = 0;
    ROB_commit_in = 1;
    ROB_ARF_num_in = 0;
    ROB_PRF_num_in = `PRF_size-1;
    @(negedge clock);
    ROB_commit_in = 0;
    @(negedge clock);
    ROB_commit_in = 1;
    ROB_PRF_num_in = 1;
    @(negedge clock);
    $finish;
  end
endmodule

