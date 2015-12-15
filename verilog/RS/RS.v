//////////////////////////////////////////////////////////////////////////
//                                                                      //
//   Modulename :  RS.v                                                 //
//                                                                      //
//  Description :  Reservation Station                                  //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps


module RS (
    input clock, reset,
    input                  ROB_branch_mispredict_in,
    input [`ROB_width-1:0] ROB_ROB_num_in,
    input                  ex_MULT_busy_in,
    input                  ex_CDB_arb_stall_in,
    input                  id_rs_srcA_valid_in,
    input                  id_rs_srcB_valid_in,
    input                  id_rs_valid_inst_in,
    input                  id_rs_uncond_branch_in,
    input                  id_rs_cond_branch_in,
    input                  id_rs_cpuid_in,
    input [1:0]            id_rs_opa_select_in, 
    input [1:0]            id_rs_opb_select_in,
    input [4:0]            id_rs_opcode_in,
    input [31:0]           id_rs_IR_in, 
    input [63:0]           id_rs_PC_plus_4_in,
    input [63:0]           id_rs_predicted_target_addr_in,
    input [`PRF_width-1:0] id_rs_srcA_PRF_num_in,
    input [`PRF_width-1:0] id_rs_srcB_PRF_num_in,
    input [`PRF_width-1:0] id_rs_dest_PRF_num_in,
    input [`PRF_width-1:0] ex_CDB_tag_in,

    output logic                  RS_full_out,
    output logic                  RS_valid_inst_out,
    output wor                    RS_uncond_branch_out,
    output wor                    RS_cond_branch_out,
    output wor                    RS_cpuid_out,
    output wor   [1:0]            RS_opa_select_out, 
    output wor   [1:0]            RS_opb_select_out,
    output wor   [4:0]            RS_opcode_out,
    output wor   [31:0]           RS_IR_out,
    output wor   [63:0]           RS_PC_plus_4_out,
    output wor   [63:0]           RS_predicted_target_addr_out,
    output wor   [`PRF_width-1:0] RS_srcA_PRF_num_out,
    output wor   [`PRF_width-1:0] RS_srcB_PRF_num_out,
    output wor   [`PRF_width-1:0] RS_dest_PRF_num_out,
    output wor   [`ROB_width-1:0] RS_ROB_num_out
);

  logic [`RS_size-1:0] free_list, choose_list, issue_list;
  logic [`RS_size-1:0] wr_en, issue_en;
  logic                srcA_valid_in, srcB_valid_in;

  assign choose_list       = free_list | issue_en;
  assign RS_full_out       = choose_list == `RS_size'b0;
  assign RS_valid_inst_out = (issue_list != 0);

  //Avoid ship in the dark problem
  assign srcA_valid_in = id_rs_srcA_valid_in || (id_rs_srcA_PRF_num_in == ex_CDB_tag_in);
  assign srcB_valid_in = id_rs_srcB_valid_in || (id_rs_srcB_PRF_num_in == ex_CDB_tag_in);
  
  ps dispatch_select (
    .req(choose_list),
    .en(~RS_full_out & id_rs_valid_inst_in),
    .gnt(wr_en)
  );

  ps issue_select (
    .req(issue_list),
    .en(~ex_CDB_arb_stall_in),
    .gnt(issue_en)
  );

  RS_entry RS8 [`RS_size-1:0] (
    .clock(clock),
    .reset(reset),
    .wr_en(wr_en),
    .issue_en(issue_en),
    .branch_mispredict(ROB_branch_mispredict_in),
    .MULT_busy(ex_MULT_busy_in),
    .srcA_valid_in(srcA_valid_in),
    .srcB_valid_in(srcB_valid_in),
    .uncond_branch_in(id_rs_uncond_branch_in),
    .cond_branch_in(id_rs_cond_branch_in),
    .cpuid_in(id_rs_cpuid_in),
    .opa_select_in(id_rs_opa_select_in),
    .opb_select_in(id_rs_opb_select_in),
    .opcode_in(id_rs_opcode_in),
    .IR_in(id_rs_IR_in),
    .PC_plus_4_in(id_rs_PC_plus_4_in),
    .predicted_target_addr_in(id_rs_predicted_target_addr_in),
    .srcA_PRF_num_in(id_rs_srcA_PRF_num_in),
    .srcB_PRF_num_in(id_rs_srcB_PRF_num_in),
    .dest_PRF_num_in(id_rs_dest_PRF_num_in),
    .ROB_num_in(ROB_ROB_num_in),
    .CDB_tag_in(ex_CDB_tag_in),

    .issue_out(issue_list),
    .free_out(free_list),
    .uncond_branch_out(RS_uncond_branch_out),
    .cond_branch_out(RS_cond_branch_out),
    .cpuid_out(RS_cpuid_out),
    .opa_select_out(RS_opa_select_out),
    .opb_select_out(RS_opb_select_out),
    .opcode_out(RS_opcode_out),
    .IR_out(RS_IR_out),
    .PC_plus_4_out(RS_PC_plus_4_out),
    .predicted_target_addr_out(RS_predicted_target_addr_out),
    .srcA_PRF_num_out(RS_srcA_PRF_num_out),
    .srcB_PRF_num_out(RS_srcB_PRF_num_out),
    .dest_PRF_num_out(RS_dest_PRF_num_out),
    .ROB_num_out(RS_ROB_num_out)
  );

  

endmodule




module RS_entry (
    input clock, reset, wr_en, issue_en,
    input                  branch_mispredict,
    input                  MULT_busy,
    input                  srcA_valid_in,
    input                  srcB_valid_in,
    input                  uncond_branch_in,
    input                  cond_branch_in,
    input                  cpuid_in,
    input [1:0]            opa_select_in, 
    input [1:0]            opb_select_in,
    input [4:0]            opcode_in,
    input [31:0]           IR_in,                     
    input [63:0]           PC_plus_4_in,
    input [63:0]           predicted_target_addr_in,
    input [`PRF_width-1:0] srcA_PRF_num_in,
    input [`PRF_width-1:0] srcB_PRF_num_in,
    input [`PRF_width-1:0] dest_PRF_num_in,
    input [`PRF_width-1:0] CDB_tag_in,
    input [`ROB_width-1:0] ROB_num_in,

    output logic                  issue_out,
    output logic                  free_out,
    output logic                  uncond_branch_out,
    output logic                  cond_branch_out,
    output logic                  cpuid_out,
    output logic [1:0]            opa_select_out, 
    output logic [1:0]            opb_select_out,
    output logic [4:0]            opcode_out,
    output logic [31:0]           IR_out,
    output logic [63:0]           PC_plus_4_out,
    output logic [63:0]           predicted_target_addr_out,
    output logic [`PRF_width-1:0] srcA_PRF_num_out,
    output logic [`PRF_width-1:0] srcB_PRF_num_out,
    output logic [`PRF_width-1:0] dest_PRF_num_out,
    output logic [`ROB_width-1:0] ROB_num_out
);

  logic                  free;
  logic                  srcA_valid, srcB_valid;
  logic                  uncond_branch;
  logic                  cond_branch;
  logic                  cpuid;
  logic [1:0]            opa_select, opb_select;
  logic [4:0]            opcode;
  logic [20:0]           IR;
  logic [63:0]           PC_plus_4;
  logic [63:0]           predicted_target_addr;
  logic [`PRF_width-1:0] srcA_PRF_num;
  logic [`PRF_width-1:0] srcB_PRF_num;
  logic [`PRF_width-1:0] dest_PRF_num;
  logic [`ROB_width-1:0] ROB_num;

  logic srcA_PRF_match, srcB_PRF_match;

  assign srcA_PRF_match = srcA_PRF_num == CDB_tag_in;
  assign srcB_PRF_match = srcB_PRF_num == CDB_tag_in;
  
  assign free_out                  = free;
  assign issue_out                 = !(!free && (srcA_valid || srcA_PRF_match)
                                     && (srcB_valid || srcB_PRF_match))? 0 : 
                                     opcode != `ALU_MULQ? 1 :
                                     MULT_busy? 0 : 1;
  assign uncond_branch_out         = issue_en? uncond_branch : 0;  
  assign cond_branch_out           = issue_en? cond_branch : 0;
  assign cpuid_out                 = issue_en? cpuid : 0;
  assign opa_select_out            = issue_en? opa_select : 0;
  assign opb_select_out            = issue_en? opb_select : 0;
  assign opcode_out                = issue_en? opcode : 0;
  assign IR_out                    = issue_en? IR : 0;
  assign PC_plus_4_out             = issue_en? PC_plus_4 : 0;
  assign predicted_target_addr_out = issue_en? predicted_target_addr : 0;
  assign srcA_PRF_num_out          = issue_en? srcA_PRF_num : 0;
  assign srcB_PRF_num_out          = issue_en? srcB_PRF_num : 0;
  assign dest_PRF_num_out          = issue_en? dest_PRF_num : 0;
  assign ROB_num_out               = issue_en? ROB_num : 0;

  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset)
      srcA_valid <= `SD 0;
    else 
      if (branch_mispredict)
        srcA_valid <= `SD 0;
      else if (wr_en)
        srcA_valid <= `SD srcA_valid_in;
      else if (srcA_PRF_match)
        srcA_valid <= `SD 1;
  end

  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset)
      srcB_valid <= `SD 0;
    else
      if (branch_mispredict)
        srcB_valid <= `SD 0;
      else if (wr_en)
        srcB_valid <= `SD srcB_valid_in;
      else if (srcB_PRF_match)
        srcB_valid <= `SD 1;
  end

  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset)
      free <= `SD 1;
    else
      if (branch_mispredict)
        free <= `SD 1;
      else if (wr_en)
        free <= `SD 0;
      else if (issue_en)
        free <= `SD 1;
  end

  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      uncond_branch         <= `SD 0;
      cond_branch           <= `SD 0;
      cpuid                 <= `SD 0;
      opa_select            <= `SD 0;
      opb_select            <= `SD 0;
      opcode                <= `SD 0;
      IR                    <= `SD 0;
      PC_plus_4             <= `SD 0;
      predicted_target_addr <= `SD 0;
      srcA_PRF_num          <= `SD 0;
      srcB_PRF_num          <= `SD 0;
      dest_PRF_num          <= `SD 0;
      ROB_num               <= `SD 0;
    end
    else begin
      if (branch_mispredict) begin
        uncond_branch         <= `SD 0;
        cond_branch           <= `SD 0;
        cpuid                 <= `SD 0;
        opa_select            <= `SD 0;
        opb_select            <= `SD 0;
        opcode                <= `SD 0;
        IR                    <= `SD 0;
        PC_plus_4             <= `SD 0;
        predicted_target_addr <= `SD 0;
        srcA_PRF_num          <= `SD 0;
        srcB_PRF_num          <= `SD 0;
        dest_PRF_num          <= `SD 0;
        ROB_num               <= `SD 0;
      end
      else if (wr_en) begin
        uncond_branch         <= `SD uncond_branch_in;
        cond_branch           <= `SD cond_branch_in;
        cpuid                 <= `SD cpuid_in;
        opa_select            <= `SD opa_select_in;
        opb_select            <= `SD opb_select_in;
        opcode                <= `SD opcode_in;
        IR                    <= `SD IR_in;
        PC_plus_4             <= `SD PC_plus_4_in;
        predicted_target_addr <= `SD predicted_target_addr_in;
        srcA_PRF_num          <= `SD srcA_PRF_num_in;
        srcB_PRF_num          <= `SD srcB_PRF_num_in;
        dest_PRF_num          <= `SD dest_PRF_num_in;
        ROB_num               <= `SD ROB_num_in;
      end
    end
  end
endmodule




module ps (req, en, gnt, req_up);
//synopsys template
parameter NUM_BITS = `RS_size;

  input  [NUM_BITS-1:0] req;
  input                 en;

  output [NUM_BITS-1:0] gnt;
  output                req_up;
        
  wire   [NUM_BITS-2:0] req_ups;
  wire   [NUM_BITS-2:0] enables;
        
  assign req_up = req_ups[NUM_BITS-2];
  assign enables[NUM_BITS-2] = en;
        
  genvar i,j;
  generate
    if ( NUM_BITS == 2 )
    begin
      ps2 single (.req(req),.en(en),.gnt(gnt),.req_up(req_up));
    end
    else
    begin
      for(i=0;i<NUM_BITS/2;i=i+1)
      begin : foo
        ps2 base ( .req(req[2*i+1:2*i]),
                   .en(enables[i]),
                   .gnt(gnt[2*i+1:2*i]),
                   .req_up(req_ups[i])
        );
      end

      for(j=NUM_BITS/2;j<=NUM_BITS-2;j=j+1)
      begin : bar
        ps2 top ( .req(req_ups[2*j-NUM_BITS+1:2*j-NUM_BITS]),
                  .en(enables[j]),
                  .gnt(enables[2*j-NUM_BITS+1:2*j-NUM_BITS]),
                  .req_up(req_ups[j])
        );
      end
    end
  endgenerate
endmodule

module ps2(req, en, gnt, req_up);

  input     [1:0] req;
  input           en;
  
  output    [1:0] gnt;
  output          req_up;
  
  assign gnt[1] = en & req[1];
  assign gnt[0] = en & req[0] & !req[1];
  
  assign req_up = req[1] | req[0];

endmodule
