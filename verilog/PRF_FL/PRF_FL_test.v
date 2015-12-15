`timescale 1ns/100ps


module testbench();


  logic                    clock, reset;
  logic                    RAT_req_in;
  logic                    ROB_mispredict_in;
  logic [`PRF_size-1:0]    RRAT_PRF_FL_in;
  logic [`PRF_width-1:0]   RRAT_free_PRF_num_in;

  logic [`PRF_width-1:0]   rename_dest_PRF_num_out;
  logic                    no_free_PRF_out;

  PRF_FL dut (
      .clock(clock),
      .reset(reset),
      .RAT_req_in(RAT_req_in),
      .ROB_mispredict_in(ROB_mispredict_in),
      .RRAT_PRF_FL_in(RRAT_PRF_FL_in),
      .RRAT_free_PRF_num_in(RRAT_free_PRF_num_in),

      .rename_dest_PRF_num_out(rename_dest_PRF_num_out),
      .no_free_PRF_out(no_free_PRF_out)
  );


  task check_correct;
    input                   rename_dest_PRF_num_out_tb;
    input string            error_message;
    #2;
    if (
        rename_dest_PRF_num_out_tb  == rename_dest_PRF_num_out
        )
      ;
    else begin
      $display(error_message);
      $display("@@@Failed...");
      $finish;
    end
  endtask

  always begin
    #5;
    clock=~clock;
  end
  
  initial begin
  	reset = 1;
  	clock = 0;
    RAT_req_in = 0;
    ROB_mispredict_in = 0;
    RRAT_PRF_FL_in = 0;
    RRAT_free_PRF_num_in = 0;

    @(negedge clock);
    reset = 0;
    RAT_req_in = 1;
    for (int i=0; i<`PRF_size; i++) begin
    //  check_correct(`PRF_size-1-i, "Write incorrect");
      @(negedge clock);
    end

    @(negedge clock);
//    check_correct(0, "Write incorrect");
    @(negedge clock);

    for (int i=0; i<`PRF_size; i++) begin
      RRAT_free_PRF_num_in = i;
 //     check_correct(i, "Free incorrect");
      @(negedge clock);
    end
    @(negedge clock);
    ROB_mispredict_in = 1;
    RRAT_PRF_FL_in = 64'h0000_0000_0000_FFFF;
    @(negedge clock);
    RRAT_free_PRF_num_in = 0;
//    check_correct(15, "Squash incorrect");
    @(negedge clock);
    $finish;
  end
endmodule

