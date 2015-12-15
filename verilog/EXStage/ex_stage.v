module ex_stage (
    input                    clock, reset,
    input                    rs_ex_uncond_branch_in,
    input                    rs_ex_cond_branch_in,
    input                    rs_ex_st_inst_in,
    input                    rs_ex_ld_inst_in,
    input                    rs_ex_stc_inst_in,
    input                    rs_ex_ldl_inst_in,
    input   [1:0]            rs_ex_opa_select_in, 
    input   [1:0]            rs_ex_opb_select_in,
    input   [4:0]            rs_ex_opcode_in,
    input   [31:0]           rs_ex_IR_in,
    input   [63:0]           rs_ex_PC_plus_4_in,
    input   [63:0]           rs_ex_predicted_target_addr_in,
    input   [`PRF_width-1:0] rs_ex_srcA_PRF_num_in,
    input   [`PRF_width-1:0] rs_ex_srcB_PRF_num_in,
    input   [`PRF_width-1:0] rs_ex_dest_PRF_num_in,
    input   [`ROB_width-1:0] rs_ex_ROB_num_in,
    input   [`PRF_width-1:0] dcacheCtrl_ld_PRF_num_in,
    input                    dcacheCtrl_ld_ready_in,
    input   [63:0]           dcacheCtrl_ld_value_in,
    input   [63:0]           ex_wb_result_in,
    input   [`PRF_width-1:0] ex_wb_PRF_num_in,
    input   [`PRF_width-1:0] debug_rd_idx_in,

    output logic                   ex_MULT_busy_out,
    output logic                   ex_CDB_arb_stall_out,
    output logic                   ex_branch_mispredict_out,
    output logic                   ex_branch_inst_out,
    output logic                   ex_branch_taken_out,
    output logic                   ex_store_inst_out,
    output logic [`PRF_width-1:0]  ex_CDB_tag_out,
    output logic [`ROB_width-1:0]  ex_ROB_number_out,
    output logic [63:0]            ex_result_out,
    output logic [63:0]            ex_NPC_out,
    output logic [63:0]            debug_out 

);

  logic [63:0] srcA_value, srcB_value;

  PRF regfile (.ex_wb_wr_idx_in(ex_wb_PRF_num_in),
               .ex_wb_wr_data_in(ex_wb_result_in),
               .clock(clock),
               .rs_ex_rda_idx_in(rs_ex_srcA_PRF_num_in),
               .rs_ex_rdb_idx_in(rs_ex_srcB_PRF_num_in),
               .debug_rd_idx_in(debug_rd_idx_in),

               .rda_out(srcA_value),
               .rdb_out(srcB_value),
               .debug_out(debug_out)
               );



  //For internal wires
  logic  [63:0] opa_mux_out, opb_mux_out, alu_result, MULT_product;
  logic         brcond_result, taken_branch;
  logic         MULT_inst, MULT_ready_togo, MULT_done;

  //For internal D flip flops
  logic                  mult_busy;
  logic [`PRF_width-1:0] MULT_PRF_NUM;
  logic                  MULT_result_buffer_inuse;
  logic [63:0]           MULT_result_buffer;

  wire [63:0] mem_disp = { {48{rs_ex_IR_in[15]}}, rs_ex_IR_in[15:0] };
  wire [63:0] br_disp  = { {41{rs_ex_IR_in[20]}}, rs_ex_IR_in[20:0], 2'b00 };
  wire [63:0] alu_imm  = { 56'b0, rs_ex_IR_in[20:13] };

  assign MULT_inst        = (rs_ex_opcode_in == `ALU_MULQ);
  assign MULT_ready_togo  = (MULT_done || MULT_result_buffer_inuse) 
                            && !dcacheCtrl_ld_ready_in;

  assign ex_MULT_busy_out = mult_busy | MULT_inst;

  // ALU opA mux
  always_comb
  begin
    case (rs_ex_opa_select_in)
      `ALU_OPA_IS_REGA:     opa_mux_out = srcA_value;
      `ALU_OPA_IS_MEM_DISP: opa_mux_out = mem_disp;
      `ALU_OPA_IS_NPC:      opa_mux_out = rs_ex_PC_plus_4_in;
      `ALU_OPA_IS_NOT3:     opa_mux_out = ~64'h3;
    endcase
  end

  // ALU opB mux
  always_comb
  begin
     // Default value, Set only because the case isnt full.  If you see this
     // value on the output of the mux you have an invalid opb_select
    opb_mux_out = 64'hbaadbeefdeadbeef;
    case (rs_ex_opb_select_in)
      `ALU_OPB_IS_REGB:    opb_mux_out = srcB_value;
      `ALU_OPB_IS_ALU_IMM: opb_mux_out = alu_imm;
      `ALU_OPB_IS_BR_DISP: opb_mux_out = br_disp;
    endcase 
  end

  // instantiate the ALU
  alu alu_0 (
       .opa(opa_mux_out),
       .opb(opb_mux_out),
       .func(rs_ex_opcode_in),

       .result(alu_result)
      );

  // instantiate the branch condition tester
  brcond brcond (
        .opa(srcA_value),       
        .func(rs_ex_IR_in[28:26]), 

        .cond(brcond_result)
         );

  // ultimate "take branch" signal:
  // unconditional, or conditional and the condition is true
  assign taken_branch = rs_ex_uncond_branch_in |
                (rs_ex_cond_branch_in & brcond_result);

  mult mult (
        .clock(clock),
        .reset(reset),
        .mcand(srcA_value),
        .mplier(srcB_value),
        .start(MULT_inst),

        .product(MULT_product),
        .done(MULT_done)
        );

  


  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      mult_busy    <= `SD 0;
      MULT_PRF_NUM <= `SD 0;
    end
    else begin
      if (MULT_inst) begin 
        mult_busy    <= `SD 1;
        MULT_PRF_NUM <= `SD rs_ex_dest_PRF_num_in;
      end
      else if (MULT_ready_togo) begin
        mult_busy    <= `SD 0;
        MULT_PRF_NUM <= `SD 0;
      end
    end
  end



  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      MULT_result_buffer_inuse <= `SD 0;
      MULT_result_buffer       <= `SD 0;
    end
    else begin
      if (MULT_done && dcacheCtrl_ld_ready_in) begin
        MULT_result_buffer_inuse <= `SD 1;
        MULT_result_buffer       <= `SD MULT_product;
      end
      else if (MULT_ready_togo)
        MULT_result_buffer_inuse <= `SD 0;
    end
  end


  //CDB arbitration logic
  always_comb begin
    ex_CDB_arb_stall_out     = 0;
    ex_branch_mispredict_out = 0;
    ex_branch_inst_out       = 0;
    ex_store_inst_out        = 0;
    ex_CDB_tag_out           = 0;
    ex_ROB_number_out        = 0;
    ex_result_out            = 0;
    ex_NPC_out               = 0;
    ex_branch_taken_out      = taken_branch;
    if (dcacheCtrl_ld_ready_in) begin
      ex_CDB_arb_stall_out = 1;
      ex_CDB_tag_out       = dcacheCtrl_ld_PRF_num_in;
      ex_result_out        = dcacheCtrl_ld_value_in;
    end
    else if (MULT_done || MULT_result_buffer_inuse) begin
      ex_CDB_arb_stall_out  = 1;
      ex_CDB_tag_out        = MULT_PRF_NUM;
      if (MULT_result_buffer_inuse)
        ex_result_out = MULT_result_buffer;
      else
        ex_result_out = MULT_product;
    end
    else begin
      ex_CDB_tag_out     = rs_ex_dest_PRF_num_in;
      ex_result_out      = alu_result;
      if (rs_ex_cond_branch_in || rs_ex_uncond_branch_in) begin
        ex_branch_inst_out = 1;
        ex_ROB_number_out  = rs_ex_ROB_num_in;
        ex_NPC_out         = alu_result;
        ex_result_out      = rs_ex_PC_plus_4_in;
        if (taken_branch && (alu_result != rs_ex_predicted_target_addr_in)) begin
          ex_branch_mispredict_out = 1; 
          ex_NPC_out               = alu_result;
        end
        else if (!taken_branch && (rs_ex_predicted_target_addr_in != rs_ex_PC_plus_4_in)) begin
          ex_branch_mispredict_out = 1; 
          ex_NPC_out               = rs_ex_PC_plus_4_in;
        end
      end
      else if (rs_ex_st_inst_in) begin
        ex_store_inst_out = 1; 
        ex_ROB_number_out = rs_ex_ROB_num_in;
      end
    end
  end
endmodule



module alu(
      input [63:0] opa,
      input [63:0] opb,
      input  [4:0] func,
           
      output logic [63:0] result
    );

    // This function computes a signed less-than operation
  function signed_lt;
    input [63:0] a, b;

    if (a[63] == b[63]) 
      signed_lt = (a < b); // signs match: signed compare same as unsigned
    else
      signed_lt = a[63];   // signs differ: a is smaller if neg, larger if pos
  endfunction

  always_comb
    begin
    case (func)
      `ALU_ADDQ:   result = opa + opb;
      `ALU_SUBQ:   result = opa - opb;
      `ALU_AND:    result = opa & opb;
      `ALU_BIC:    result = opa & ~opb;
      `ALU_BIS:    result = opa | opb;
      `ALU_ORNOT:  result = opa | ~opb;
      `ALU_XOR:    result = opa ^ opb;
      `ALU_EQV:    result = opa ^ ~opb;
      `ALU_SRL:    result = opa >> opb[5:0];
      `ALU_SLL:    result = opa << opb[5:0];
      `ALU_SRA:    result = (opa >> opb[5:0]) | ({64{opa[63]}} << (64 -
                 opb[5:0])); // arithmetic from logical shift
    //  `ALU_MULQ:   result = opa * opb;
      `ALU_CMPULT: result = { 63'd0, (opa < opb) };
      `ALU_CMPEQ:  result = { 63'd0, (opa == opb) };
      `ALU_CMPULE: result = { 63'd0, (opa <= opb) };
      `ALU_CMPLT:  result = { 63'd0, signed_lt(opa, opb) };
      `ALU_CMPLE:  result = { 63'd0, (signed_lt(opa, opb) || (opa == opb)) };
      default:     result = 64'hdeadbeefbaadbeef; // here only to force
                            // a combinational solution
                            // a casex would be better
    endcase
  end
endmodule // alu

module brcond(// Inputs
              input [63:0] opa,        // Value to check against condition
              input  [2:0] func,       // Specifies which condition to check
      
        output logic cond        // 0/1 condition result (False/True)
             );

  always_comb
  begin
    case (func[1:0]) // 'full-case'  All cases covered, no need for a default
      2'b00: cond = (opa[0] == 0);  // LBC: (lsb(opa) == 0) ?
      2'b01: cond = (opa == 0);     // EQ: (opa == 0) ?
      2'b10: cond = (opa[63] == 1); // LT: (signed(opa) < 0) : check sign bit
      2'b11: cond = (opa[63] == 1) || (opa == 0); // LE: (signed(opa) <= 0)
    endcase

     // negate cond if func[2] is set
    if (func[2])
      cond = ~cond;
  end
endmodule // brcond

module mult_stage(
          input clock, reset, start,
          input [63:0] product_in, mplier_in, mcand_in,

          output logic done,
          output logic [63:0] product_out, mplier_out, mcand_out
        );



  logic [63:0] prod_in_reg, partial_prod_reg;
  logic [63:0] partial_product, next_mplier, next_mcand;

  assign product_out = prod_in_reg + partial_prod_reg;

  assign partial_product = mplier_in[`MULT_WIDTH-1:0] * mcand_in;

  assign next_mplier = {`MULT_WIDTH'b0,mplier_in[63:`MULT_WIDTH]};
  assign next_mcand = {mcand_in[(63-`MULT_WIDTH):0],`MULT_WIDTH'b0};

  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    prod_in_reg      <= #1 product_in;
    partial_prod_reg <= #1 partial_product;
    mplier_out       <= #1 next_mplier;
    mcand_out        <= #1 next_mcand;
  end

  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if(reset)
      done <= #1 1'b0;
    else
      done <= #1 start;
  end

endmodule

module mult(
        input clock, reset,
        input [63:0] mcand, mplier,
        input start,
        
        output [63:0] product,
        output done
      );

  logic [63:0] mcand_out, mplier_out;
  logic [((`MULT_WIDTH-1)*64)-1:0] internal_products, internal_mcands, internal_mpliers;
  logic [(`MULT_WIDTH-2):0] internal_dones;
  
  mult_stage mstage [(`MULT_WIDTH-1):0]  (
    .clock(clock),
    .reset(reset),
    .product_in({internal_products,64'h0}),
    .mplier_in({internal_mpliers,mplier}),
    .mcand_in({internal_mcands,mcand}),
    .start({internal_dones,start}),
    .product_out({product,internal_products}),
    .mplier_out({mplier_out,internal_mpliers}),
    .mcand_out({mcand_out,internal_mcands}),
    .done({done,internal_dones})
  );

endmodule

