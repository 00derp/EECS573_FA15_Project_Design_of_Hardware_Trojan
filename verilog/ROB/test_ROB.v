`timescale 1ns/100ps

parameter CLOCK_PERIOD = 10;
`define ROB_size 32
`define ROB_width 5
`define ARF_width 5
`define PRF_width 6


module testbench();

  logic clock, reset;
  logic                  id_rs_valid_inst_in;
  logic [`ARF_width-1:0] id_rs_ARF_num_in;
  logic [`PRF_width-1:0] id_rs_PRF_num_in;
  logic                  id_rs_is_branch_inst_in; 
  logic                  id_rs_is_store_inst_in;              
  logic [63:0]           ex_NPC_in;
  logic                  ex_branch_mispredict_in;
  logic                  ex_branch_inst_in;
  logic                  ex_store_inst_in;
  logic [`ROB_width-1:0] ex_ROB_num_in; //for updating branch and store
  logic [`PRF_width-1:0] CDB_tag_in;

  logic   [`ARF_width-1:0] ROB_ARF_num_out;
  logic   [`PRF_width-1:0] ROB_PRF_num_out;
  logic   [63:0]           ROB_NPC_out;
  logic                    ROB_branch_mispredict_out;
  logic                    ROB_is_store_inst_out;
  logic                    ROB_is_branch_inst_out;
  logic                    ROB_commit_out;
  logic                    ROB_dispatch_disable;
  logic [`ROB_width-1:0]   ROB_head;
  logic [`ROB_width-1:0]   ROB_tail;


  task func_check;
    input   [`ARF_width-1:0] ROB_ARF_num_out_tb;
    input   [`PRF_width-1:0] ROB_PRF_num_out_tb;
    input   [63:0]           ROB_NPC_out_tb;
    input                    ROB_branch_mispredict_out_tb;
    input                    ROB_is_store_inst_out_tb;
    input                    ROB_is_branch_inst_out_tb;
    input                    ROB_commit_out_tb;
    input                    ROB_dispatch_disable_tb;
    input [`ROB_width-1:0]   ROB_head_tb;
    input [`ROB_width-1:0]   ROB_tail_tb;
    input string             error_message;

    #2;
    if (
      ROB_ARF_num_out_tb                == ROB_ARF_num_out &&
      ROB_PRF_num_out_tb                == ROB_PRF_num_out &&
      ROB_NPC_out_tb                    == ROB_NPC_out &&
      ROB_branch_mispredict_out_tb      == ROB_branch_mispredict_out &&
      ROB_is_store_inst_out_tb          == ROB_is_store_inst_out &&
      ROB_is_branch_inst_out_tb         == ROB_is_branch_inst_out &&
      ROB_commit_out_tb                 == ROB_commit_out &&
      ROB_dispatch_disable_tb           == ROB_dispatch_disable &&
      ROB_head_tb                       == ROB_head &&
      ROB_tail_tb                       == ROB_tail
    )
    ;
    else begin
      $display(error_message);
      $display("@@@Test Failed");
      $finish;
    end
  endtask


  ROB R0(.clock(clock),
         .reset(reset),
         .id_rs_valid_inst_in(id_rs_valid_inst_in),
         .id_rs_ARF_num_in(id_rs_ARF_num_in),
         .id_rs_PRF_num_in(id_rs_PRF_num_in),
         .id_rs_is_branch_inst_in(id_rs_is_branch_inst_in),
         .id_rs_is_store_inst_in(id_rs_is_store_inst_in),
         .ex_NPC_in(ex_NPC_in),
         .ex_branch_mispredict_in(ex_branch_mispredict_in),
         .ex_branch_inst_in(ex_branch_inst_in),
         .ex_store_inst_in(ex_store_inst_in),
         .ex_ROB_num_in(ex_ROB_num_in),
         .CDB_tag_in(CDB_tag_in),

         .ROB_ARF_num_out(ROB_ARF_num_out),
         .ROB_PRF_num_out(ROB_PRF_num_out),
         .ROB_NPC_out(ROB_NPC_out),
         .ROB_branch_mispredict_out(ROB_branch_mispredict_out),
         .ROB_is_store_inst_out(ROB_is_store_inst_out),
         .ROB_is_branch_inst_out(ROB_is_branch_inst_out),
         .ROB_commit_out(ROB_commit_out),
         .ROB_dispatch_disable(ROB_dispatch_disable),
         .ROB_head(ROB_head),
         .ROB_tail(ROB_tail)
    );

  always begin
    #5;
    clock = ~clock;
  end
  
  
  initial begin
    clock = 0;
    @(negedge clock);
    reset = 1;
    id_rs_valid_inst_in      = 0;
    id_rs_ARF_num_in         = 0;
    id_rs_PRF_num_in         = 0;
    id_rs_is_branch_inst_in  = 0;
    id_rs_is_store_inst_in   = 0;
    ex_NPC_in                = 0;
    ex_branch_mispredict_in  = 0;
    ex_branch_inst_in        = 0;
    ex_store_inst_in         = 0;
    ex_ROB_num_in            = 0;
    CDB_tag_in               = 0;
    @(negedge clock);
    reset = 0;
    func_check(0, 0, 0, 0, 0, 0, 0, 0, 0, 0,"@@@Reset Case Failed");
    
    id_rs_valid_inst_in      = 1;
    id_rs_ARF_num_in         = 1 << `ARF_width;
    id_rs_PRF_num_in         = 1 << `PRF_width;
    id_rs_is_branch_inst_in  = 1;
    id_rs_is_store_inst_in   = 1;
    ex_NPC_in                = 1 << 63;
    ex_branch_mispredict_in  = 0;
    ex_branch_inst_in        = 0;
    ex_store_inst_in         = 0;
    ex_ROB_num_in            = 0;
    CDB_tag_in               = 0;
    
    @(negedge clock);
    func_check(0, 0, 0, 0, 1, 1, 0, 0, 0, 1,"@@@Dispatch logic incorrect");
    id_rs_valid_inst_in = 0;
    @(negedge clock);
    func_check(0, 0, 0, 0, 1, 1, 0, 0, 0, 1,"@@@An Invalid instruction is dispatched");
    
    reset = 1;
    @(negedge clock);
    reset = 0;
    id_rs_valid_inst_in      = 1;
    id_rs_is_branch_inst_in  = 0;
    id_rs_is_store_inst_in   = 0;
    ex_NPC_in                = 0;
    ex_branch_mispredict_in  = 0;
    ex_branch_inst_in        = 0;
    ex_store_inst_in         = 0;
    ex_ROB_num_in            = 0;
    CDB_tag_in               = 0;
    
    //Try to full the ROB
    for (int i=0; i<`ROB_size-1; i++) begin
      id_rs_ARF_num_in         = i;
      id_rs_PRF_num_in         = i+1;
      @(negedge clock);
      func_check(0, 1, 0, 0, 0, 0, 0, 0, 0, i+1,"@@@Dispatch/commit logic incorrect");
    end
    //The last entry is treated differently since dispatch_disabled should be 
    //high after the posedge of clock
    id_rs_ARF_num_in = 0;
    id_rs_PRF_num_in = `ROB_size;
    @(negedge clock);
    func_check(0, 1, 0, 0, 0, 0, 0, 1, 0, 0,"@@@Full logic incorrect");
    
    @(negedge clock);
    @(negedge clock);
    @(negedge clock);

    //Dispatch and commit at the same time when full
    CDB_tag_in = 1;
    @(negedge clock);
    func_check(0, 1, 0, 0, 0, 0, 1, 0, 0, 0,"@@@Full logic incorrect");
    
    //The following instruction stays at ROB #0
    //It is for testing squashing logic
    id_rs_ARF_num_in        = 5;
    id_rs_PRF_num_in        = `ROB_size+1;
    id_rs_is_store_inst_in  = 1;
    id_rs_is_branch_inst_in = 1;

    @(negedge clock);
    func_check(1, 2, 0, 0, 0, 0, 0, 1, 1, 1,"@@@Commit logic incorrect");
    //Stop dispatching. Commit all the instructions in ROB
    id_rs_valid_inst_in = 0;
    for (int i=1; i<`ROB_size-1; i++) begin
      CDB_tag_in = i+1;
      @(negedge clock)
      func_check(i, i+1, 0, 0, 0, 0, 1, 0, i, 1,"@@@Commit logic incorrect");
    end

    CDB_tag_in = `ROB_size;
    @(negedge clock);
    //The last entry
    func_check(0, `ROB_size, 0, 0, 0, 0, 1, 0, `ROB_size-1, 1,"@@@Commit logic incorrect");
    
    //For following three lines are for updating ROB #0 only
    ex_NPC_in               = 200;
    ex_branch_inst_in       = 1;
    ex_branch_mispredict_in = 1;
    ///
    
    @(negedge clock);
    func_check(5,`ROB_size+1, 200, 1, 1, 1, 1, 0, 0, 1,"@@@Commit/full logic incorrect");
    @(negedge clock);
    func_check(0, 0, 0, 0, 0, 0, 0, 0, 0, 0,"@@@Squashing");
  

    //Half full the ROB with store instruction
    id_rs_valid_inst_in      = 1;
    id_rs_is_branch_inst_in  = 0;
    id_rs_is_store_inst_in   = 1;
    CDB_tag_in               = 0;
    for (int i=0; i<`ROB_size/2; i++) begin
      id_rs_ARF_num_in         = i+1;
      id_rs_PRF_num_in         = 0;
      @(negedge clock);
      func_check(1, 0, 0, 0, 1, 0, 0, 0, 0, i+1,"@@@Dispatch/commit logic incorrect");
    end

    //Dispatching new instruction while committing store instruction
    id_rs_is_store_inst_in  = 0;
    ex_branch_mispredict_in = 0;
    ex_branch_inst_in       = 0;
    ex_NPC_in               = 0;
    ex_store_inst_in = 1;
    for (int i=0; i<`ROB_size/2; i++) begin
      ex_ROB_num_in    = i;
      id_rs_ARF_num_in = i+`ROB_size/2;
      id_rs_PRF_num_in = i+`ROB_size/2+1;
      @(negedge clock)
      func_check(i+1, 0, 0, 0, 1, 0, 1, 0, i, i+`ROB_size/2+1,"@@@Dispatch/commit logic incorrect");
    end
    id_rs_valid_inst_in = 0;
    //commit the rest of instructions
    for (int i=`ROB_size/2; i<`ROB_size; i++) begin
      CDB_tag_in = i+1;
      @(negedge clock)
      func_check(i, i+1, 0, 0, 0, 0, 1, 0, i, 0,"@@@Dispatch/commit logic incorrect");
    end
    @(negedge clock)

    func_check(1, 0, 0, 0, 1, 0, 0, 0, 0, 0,"@@@Dispatch/commit logic incorrect");

    //The ROB is actually empty, though the information from previous instruction
    //still exists. However, we have a valid bit to handle this situation.
    //We will run the code above again to see if there is conflict.
    id_rs_valid_inst_in      = 1;
    id_rs_is_branch_inst_in  = 0;
    id_rs_is_store_inst_in   = 0;
    ex_NPC_in                = 0;
    ex_branch_mispredict_in  = 0;
    ex_branch_inst_in        = 0;
    ex_store_inst_in         = 0;
    ex_ROB_num_in            = 0;
    CDB_tag_in               = 0;
    
    //Try to full the ROB
    for (int i=0; i<`ROB_size-1; i++) begin
      id_rs_ARF_num_in         = i;
      id_rs_PRF_num_in         = i+1;
      @(negedge clock);
      func_check(0, 1, 0, 0, 0, 0, 0, 0, 0, i+1,"@@@Dispatch/commit logic incorrect");
    end
    //The last entry is treated differently since dispatch_disabled should be 
    //high after the posedge of clock
    id_rs_ARF_num_in = 0;
    id_rs_PRF_num_in = `ROB_size;
    @(negedge clock);
    func_check(0, 1, 0, 0, 0, 0, 0, 1, 0, 0,"@@@Full logic incorrect");
    
    @(negedge clock);
    @(negedge clock);
    @(negedge clock);

    //Dispatch and commit at the same time when full
    CDB_tag_in = 1;
    @(negedge clock);
    func_check(0, 1, 0, 0, 0, 0, 1, 0, 0, 0,"@@@Full logic incorrect");
    
    //The following instruction stays at ROB #0
    //It is for testing squashing logic
    id_rs_ARF_num_in        = 5;
    id_rs_PRF_num_in        = `ROB_size+1;
    id_rs_is_store_inst_in  = 1;
    id_rs_is_branch_inst_in = 1;

    @(negedge clock);
    func_check(1, 2, 0, 0, 0, 0, 0, 1, 1, 1,"@@@Commit logic incorrect");
    //Stop dispatching. Commit all the instructions in ROB
    id_rs_valid_inst_in = 0;
    for (int i=1; i<`ROB_size-1; i++) begin
      CDB_tag_in = i+1;
      @(negedge clock)
      func_check(i, i+1, 0, 0, 0, 0, 1, 0, i, 1,"@@@Commit logic incorrect");
    end

    CDB_tag_in = `ROB_size;
    @(negedge clock);
    //The last entry
    func_check(0, `ROB_size, 0, 0, 0, 0, 1, 0, `ROB_size-1, 1,"@@@Commit logic incorrect");
    
    //For following three lines are for updating ROB #0 only
    ex_NPC_in               = 200;
    ex_branch_inst_in       = 1;
    ex_branch_mispredict_in = 1;
    ///
    
    @(negedge clock);
    func_check(5,`ROB_size+1, 200, 1, 1, 1, 1, 0, 0, 1,"@@@Commit/full logic incorrect");
    @(negedge clock);
    func_check(0, 0, 0, 0, 0, 0, 0, 0, 0, 0,"@@@Squashing");
  

    //Half full the ROB with store instruction
    id_rs_valid_inst_in      = 1;
    id_rs_is_branch_inst_in  = 0;
    id_rs_is_store_inst_in   = 1;
    CDB_tag_in               = 0;
    for (int i=0; i<`ROB_size/2; i++) begin
      id_rs_ARF_num_in         = i+1;
      id_rs_PRF_num_in         = 0;
      @(negedge clock);
      func_check(1, 0, 0, 0, 1, 0, 0, 0, 0, i+1,"@@@Dispatch/commit logic incorrect");
    end

    //Dispatching new instruction while committing store instruction
    id_rs_is_store_inst_in  = 0;
    ex_branch_mispredict_in = 0;
    ex_branch_inst_in       = 0;
    ex_NPC_in               = 0;
    ex_store_inst_in = 1;
    for (int i=0; i<`ROB_size/2; i++) begin
      ex_ROB_num_in    = i;
      id_rs_ARF_num_in = i+`ROB_size/2;
      id_rs_PRF_num_in = i+`ROB_size/2+1;
      @(negedge clock)
      func_check(i+1, 0, 0, 0, 1, 0, 1, 0, i, i+`ROB_size/2+1,"@@@Dispatch/commit logic incorrect");
    end
    id_rs_valid_inst_in = 0;
    //commit the rest of instructions
    for (int i=`ROB_size/2; i<`ROB_size; i++) begin
      CDB_tag_in = i+1;
      @(negedge clock)
      func_check(i, i+1, 0, 0, 0, 0, 1, 0, i, 0,"@@@Dispatch/commit logic incorrect");
    end
    @(negedge clock)

    func_check(1, 0, 0, 0, 1, 0, 0, 0, 0, 0,"@@@Dispatch/commit logic incorrect");
    


    $display("@@@PASSED");
    $finish;
  end
endmodule
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
