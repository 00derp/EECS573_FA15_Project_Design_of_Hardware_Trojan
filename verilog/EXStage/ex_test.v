`timescale 1ns/100ps

module testbench();

    logic                    clock, reset;
    logic                    rs_ex_uncond_branch_in;
    logic                    rs_ex_cond_branch_in;
    logic                    rs_ex_st_inst_in;
    logic                    rs_ex_ld_inst_in;
    logic                    rs_ex_stc_inst_in;
    logic                    rs_ex_ldl_inst_in;
    logic   [1:0]            rs_ex_opa_select_in; 
    logic   [1:0]            rs_ex_opb_select_in;
    logic   [4:0]            rs_ex_opcode_in;
    logic   [31:0]           rs_ex_IR_in;
    logic   [63:0]           rs_ex_PC_plus_4_in;
    logic   [63:0]           rs_ex_predicted_target_addr_in;
    logic   [`PRF_width-1:0] rs_ex_srcA_PRF_num_in;
    logic   [`PRF_width-1:0] rs_ex_srcB_PRF_num_in;
    logic   [`PRF_width-1:0] rs_ex_dest_PRF_num_in;
    logic   [`ROB_width-1:0] rs_ex_ROB_num_in;
    logic   [`PRF_width-1:0] dcacheCtrl_ld_PRF_num_in;
    logic                    dcacheCtrl_ld_ready_in;
    logic   [63:0]           dcacheCtrl_ld_value_in;
    logic   [63:0]           ex_wb_result_in;
    logic   [`PRF_width-1:0] ex_wb_PRF_num_in;
    logic   [`PRF_width-1:0] debug_rd_idx_in;

    logic                   ex_MULT_busy_out;
    logic                   ex_CDB_arb_stall_out;
    logic                   ex_branch_mispredict_out;
    logic                   ex_branch_inst_out;
    logic                   ex_branch_taken_out;
    logic                   ex_store_inst_out;
    logic [`PRF_width-1:0]  ex_CDB_tag_out;
    logic [`ROB_width-1:0]  ex_ROB_number_out;
    logic [63:0]            ex_result_out;
    logic [63:0]            ex_NPC_out;
    logic [63:0]            debug_out;

    ex_stage dut (
      .clock(clock),
      .reset(reset),
      .rs_ex_uncond_branch_in(rs_ex_uncond_branch_in),
      .rs_ex_cond_branch_in(rs_ex_cond_branch_in),
      .rs_ex_st_inst_in(rs_ex_st_inst_in),
      .rs_ex_ld_inst_in(rs_ex_ld_inst_in),
      .rs_ex_stc_inst_in(rs_ex_stc_inst_in),
      .rs_ex_ldl_inst_in(rs_ex_ldl_inst_in),
      .rs_ex_opa_select_in(rs_ex_opa_select_in), 
      .rs_ex_opb_select_in(rs_ex_opb_select_in),
      .rs_ex_opcode_in(rs_ex_opcode_in),
      .rs_ex_IR_in(rs_ex_IR_in),
      .rs_ex_PC_plus_4_in(rs_ex_PC_plus_4_in),
      .rs_ex_predicted_target_addr_in(rs_ex_predicted_target_addr_in),
      .rs_ex_srcA_PRF_num_in(rs_ex_srcA_PRF_num_in),
      .rs_ex_srcB_PRF_num_in(rs_ex_srcB_PRF_num_in),
      .rs_ex_dest_PRF_num_in(rs_ex_dest_PRF_num_in),
      .rs_ex_ROB_num_in(rs_ex_ROB_num_in),
      .dcacheCtrl_ld_PRF_num_in(dcacheCtrl_ld_PRF_num_in),
      .dcacheCtrl_ld_ready_in(dcacheCtrl_ld_ready_in),
      .dcacheCtrl_ld_value_in(dcacheCtrl_ld_value_in),
      .ex_wb_result_in(ex_wb_result_in),
      .ex_wb_PRF_num_in(ex_wb_PRF_num_in),
      .debug_rd_idx_in(debug_rd_idx_in),

      .ex_MULT_busy_out(ex_MULT_busy_out),
      .ex_CDB_arb_stall_out(ex_CDB_arb_stall_out),
      .ex_branch_mispredict_out(ex_branch_mispredict_out),
      .ex_branch_inst_out(ex_branch_inst_out),
      .ex_branch_taken_out(ex_branch_taken_out),
      .ex_store_inst_out(ex_store_inst_out),
      .ex_CDB_tag_out(ex_CDB_tag_out),
      .ex_ROB_number_out(ex_ROB_number_out),
      .ex_result_out(ex_result_out),
      .ex_NPC_out(ex_NPC_out),
      .debug_out(debug_out) 
    );
  


  task check_correct;
    input                   ex_MULT_busy_out_tb;
    input                   ex_CDB_arb_stall_out_tb;
    input                   ex_branch_mispredict_out_tb;
    input                   ex_branch_inst_out_tb;
    input                   ex_store_inst_out_tb;
    input [`PRF_width-1:0]  ex_CDB_tag_out_tb;
    input [`ROB_width-1:0]  ex_ROB_number_out_tb;
    input [63:0]            ex_result_out_tb;
    input [63:0]            ex_NPC_out_tb;
    input                   ex_branch_taken_out_tb;
    input string            error_message;
    #2;
    if (
        ex_MULT_busy_out_tb         == ex_MULT_busy_out &&
        ex_CDB_arb_stall_out_tb     == ex_CDB_arb_stall_out &&
        ex_branch_mispredict_out_tb == ex_branch_mispredict_out &&
        ex_branch_inst_out_tb       == ex_branch_inst_out &&
        ex_store_inst_out_tb        == ex_store_inst_out &&
        ex_CDB_tag_out              == ex_CDB_tag_out &&
        ex_ROB_number_out           == ex_ROB_number_out &&
        ex_result_out_tb            == ex_result_out &&
        ex_NPC_out_tb               == ex_NPC_out &&
        ex_branch_taken_out_tb      == ex_branch_taken_out
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
    clock = 0; 
    reset = 1;
    rs_ex_uncond_branch_in = 0;
    rs_ex_cond_branch_in = 0;
    rs_ex_st_inst_in = 0;
    rs_ex_ld_inst_in = 0;
    rs_ex_stc_inst_in = 0;
    rs_ex_ldl_inst_in = 0;
    rs_ex_opa_select_in = 0; 
    rs_ex_opb_select_in = 0;
    rs_ex_opcode_in = 0;
    rs_ex_IR_in = 0;
    rs_ex_PC_plus_4_in = 0;
    rs_ex_predicted_target_addr_in = 0;
    rs_ex_srcA_PRF_num_in = 0;
    rs_ex_srcB_PRF_num_in = 0;
    rs_ex_dest_PRF_num_in = 0;
    rs_ex_ROB_num_in = 0;
    dcacheCtrl_ld_PRF_num_in = 0;
    dcacheCtrl_ld_ready_in = 0;
    dcacheCtrl_ld_value_in = 0;
    ex_wb_result_in = 0;
    ex_wb_PRF_num_in = 0;
    debug_rd_idx_in = 0;

    @(negedge clock);
    reset = 0;
    for (int i=0; i<`PRF_size; i++) begin
      ex_wb_result_in = i;
      ex_wb_PRF_num_in = i;
      @(negedge clock);
    end

    ex_wb_result_in  = 0;
    ex_wb_PRF_num_in = 0;

    for (int i=0; i<`PRF_size; i++) begin
      rs_ex_dest_PRF_num_in = i;
      rs_ex_srcA_PRF_num_in = i;
      rs_ex_srcB_PRF_num_in = i;
      check_correct(0, 0, 0, 0, 0, i, 0, 2*i, 0, 0, "PRF incorrect");
      @(negedge clock);
    end

    for (int i=0; i<`PRF_size; i++) begin
      ex_wb_result_in       = 2*i;
      ex_wb_PRF_num_in      = i;
      rs_ex_dest_PRF_num_in = i;
      rs_ex_srcA_PRF_num_in = i;
      rs_ex_srcB_PRF_num_in = i;
      check_correct(0, 0, 0, 0, 0, i, 0, 4*i, 0, 0, "PRF Internal forwarding incorrect");
      @(negedge clock);
    end
    ex_wb_result_in = 0;
    ex_wb_PRF_num_in = 0;

    //arbitration
    rs_ex_opcode_in = `ALU_MULQ;
    rs_ex_srcA_PRF_num_in = 2;
    rs_ex_srcB_PRF_num_in = 3;
    rs_ex_dest_PRF_num_in = 9;
    @(negedge clock)
    rs_ex_opcode_in = 0;
    for (int i=0; i<`MULT_WIDTH-1; i++)
      @(negedge clock);

    rs_ex_uncond_branch_in         = 1;
    rs_ex_opcode_in                = `ALU_AND;
    rs_ex_opa_select_in            = `ALU_OPA_IS_NOT3;
    rs_ex_opb_select_in            = `ALU_OPB_IS_REGB;
    rs_ex_predicted_target_addr_in = 0;
    rs_ex_PC_plus_4_in             = 8;
    rs_ex_srcB_PRF_num_in          = `PRF_size-1;
    rs_ex_ROB_num_in               = 2;
    rs_ex_dest_PRF_num_in          = 26;

    dcacheCtrl_ld_value_in                = 25;
    dcacheCtrl_ld_ready_in                = 1;
    dcacheCtrl_ld_PRF_num_in              = 30;

    check_correct(1,1,0,0,0,30,0,25,0,1,"Load does not have priority over Mult");
    @(negedge clock);
    dcacheCtrl_ld_ready_in = 0;
    check_correct(1,1,0,0,0,9,0,24,0,1,"Mult buffer incorrect");
    @(negedge clock);
    check_correct(0,0,1,1,0,26,2,8,124,1,"Branch incorrect");
    @(negedge clock);
    rs_ex_uncond_branch_in         = 0;
    rs_ex_cond_branch_in           = 1;
    rs_ex_opcode_in                = `ALU_ADDQ;
    rs_ex_opa_select_in            = `ALU_OPA_IS_NPC;
    rs_ex_opb_select_in            = `ALU_OPB_IS_BR_DISP;
    rs_ex_predicted_target_addr_in = 8;
    rs_ex_PC_plus_4_in             = 8;
    rs_ex_srcA_PRF_num_in          = `PRF_size-1;
    rs_ex_ROB_num_in               = 4;
    rs_ex_dest_PRF_num_in          = 9;
    rs_ex_IR_in[28:26]             = 2'b01;
    check_correct(0,0,0,1,0,9,4,8,8,0,"Branch incorrect");
    @(negedge clock);
    rs_ex_cond_branch_in = 0;
    rs_ex_st_inst_in = 1;
    rs_ex_ROB_num_in = 2;
    check_correct(0,0,0,0,1,9,2,8,0,0,"Store incorrect");
    @(negedge clock)
    $finish;
  end

endmodule
/*
        ex_MULT_busy_out_tb         == ex_MULT_busy_out &&
        ex_CDB_arb_stall_out_tb     == ex_CDB_arb_stall_out &&
        ex_branch_mispredict_out_tb == ex_branch_mispredict_out &&
        ex_branch_inst_out_tb       == ex_branch_inst_out &&
        ex_store_inst_out_tb        == ex_store_inst_out &&
        ex_CDB_tag_out              == ex_CDB_tag_out &&
        ex_ROB_number_out           == ex_ROB_number_out &&
        ex_result_out_tb            == ex_result_out &&
        ex_NPC_out_tb               == ex_NPC_out */