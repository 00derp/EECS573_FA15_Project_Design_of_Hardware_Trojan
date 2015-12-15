`timescale 1ns/100ps

parameter CLOCK_PERIOD = 10;
`define ARF_size 32
`define ROB_width 5
`define ARF_width 5
`define PRF_width 6


module testbench();
  logic clock, reset, squash, valid_inst_in;
  logic [`ARF_width-1:0]                srcA_ARF_num_in;
  logic [`ARF_width-1:0]                srcB_ARF_num_in;
  logic [`ARF_width-1:0]                dest_ARF_num_in;
  logic [`PRF_width-1:0]                dest_PRF_num_in;
  logic [32*`PRF_width-1:0]             RRAT_in;

  logic [`PRF_width-1:0]                srcA_PRF_num_out;
  logic [`PRF_width-1:0]                srcB_PRF_num_out;
//  logic [`PRF_width-1:0]                dest_PRF_num_out;

  logic [`ARF_size-1:0][`PRF_width-1:0] mapping_table;                

  task func_check;
    input [`PRF_width-1:0]         srcA_PRF_num_out_tb;
    input [`PRF_width-1:0]         srcB_PRF_num_out_tb;
  //  input [`PRF_width-1:0]         dest_PRF_num_out_tb;
    input string                   error_message;

    #2;
    if (
      srcA_PRF_num_out_tb       == srcA_PRF_num_out &&
      srcB_PRF_num_out_tb       == srcB_PRF_num_out

    );
    else begin
      $display(error_message);
      $display("@@@Test Failed");
      $finish;
    end
  endtask

  RAT R0 (.clock(clock),
          .reset(reset),
          .squash(squash),
          .valid_inst_in(valid_inst_in),
          .srcA_ARF_num_in(srcA_ARF_num_in),
          .srcB_ARF_num_in(srcB_ARF_num_in),
          .dest_ARF_num_in(dest_ARF_num_in),
          .dest_PRF_num_in(dest_PRF_num_in),
          .RRAT_in(RRAT_in),

          .srcA_PRF_num_out(srcA_PRF_num_out),
          .srcB_PRF_num_out(srcB_PRF_num_out)
//          .dest_PRF_num_out(dest_PRF_num_out)
  );

  always begin
    #5;
    clock = ~clock;
  end
  
  
  
  initial begin
    clock = 0;
    @(negedge clock);
    reset              = 1;
    squash             = 0;
    valid_inst_in      = 0;
    srcA_ARF_num_in    = 0;
    srcB_ARF_num_in    = 0;
    dest_ARF_num_in    = 0;
    dest_PRF_num_in    = 0;
    RRAT_in            = 0;

    mapping_table      = {32{0}};
    
    // normally renaming
    @(negedge clock);
    reset              = 0;
    squash             = 0;
    valid_inst_in      = 1;
    for (int i=0; i< 40; i++) begin
      srcA_ARF_num_in            = (i)%31;
      srcB_ARF_num_in            = (i*i*i)%31;
      dest_ARF_num_in            = (i+1)%32;
      dest_PRF_num_in            = (i+10)%32;

      mapping_table[(i+1)%32]    = ((i+10)%32);
      mapping_table[0]           = 0;
      #2

      //$display("%d, srcA_PRF_num_out = %h, srcB_PRF_num_out = %h", i, srcA_PRF_num_out, srcB_PRF_num_out);
      //$display("%d, mapping_table_a = %h, mapping_table_b = %h", i, mapping_table[i%31], mapping_table[(i*i*i)%31]);
      func_check(mapping_table[i%31], mapping_table[(i*i*i)%31], "Fail on renaming.");
      @(negedge clock);
    end

    // squash case
    squash = 1;
    dest_ARF_num_in = 10;
    dest_PRF_num_in = 21;
    RRAT_in = { 6'd39, 6'd6, 6'd41, 6'd51, 6'd17, 6'd63, 6'd10, 6'd44, 6'd41, 6'd13, 6'd58, 6'd43, 6'd50, 6'd59, 6'd35, 6'd6, 6'd60, 6'd2, 6'd20, 6'd56, 6'd27, 6'd40, 6'd39, 6'd13, 6'd54, 6'd26, 6'd46, 6'd35, 6'd51, 6'd31, 6'd9, 6'd0};
    mapping_table = { 6'd39, 6'd6, 6'd41, 6'd51, 6'd17, 6'd63, 6'd10, 6'd44, 6'd41, 6'd13, 6'd58, 6'd43, 6'd50, 6'd59, 6'd35, 6'd6, 6'd60, 6'd2, 6'd20, 6'd56, 6'd27, 6'd40, 6'd39, 6'd13, 6'd54, 6'd26, 6'd46, 6'd35, 6'd51, 6'd31, 6'd9, 6'd0};
    #2
    //$display("srcA_PRF_num_out = %h, srcB_PRF_num_out = %h", srcA_PRF_num_out, srcB_PRF_num_out);
    for (int i = 0; i < 16; i++) begin
      @(negedge clock);
      dest_ARF_num_in = 0;
      srcA_ARF_num_in = i;
      srcB_ARF_num_in = 31-i;
      #2
      //$display("%d, srcA_PRF_num_out = %d, srcB_PRF_num_out = %d", i, srcA_PRF_num_out, srcB_PRF_num_out);
      //$display("%d, mapping_table_a = %d, mapping_table_b = %d", i, mapping_table[i], mapping_table[31-i]);
      func_check(mapping_table[i], mapping_table[31-i], "Fail after squashing.");
    end
    $display("PASSED...");
    $finish;
  end
endmodule