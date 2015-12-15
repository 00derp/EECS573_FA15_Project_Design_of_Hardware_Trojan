/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  PRF_FL.v                                            //
//                                                                     //
//  Description :  This module creates the PRF free list               // 
//                                                                     //
//                                                                     //
/////////////////////////////////////////////////////////////////////////


`timescale 1ns/100ps

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
  assign free_out = free_en ? 1 : free;

//synopsys sync_set_reset "reset"
  always_ff @ (posedge clock) begin
    if (reset)
      free <= `SD 1;
    else
      if (ROB_mispredict_in)
         free <= `SD RRAT_FL_in;
      else if (wr_en)
         free <= `SD 0;
      else if (free_en)
         free <= `SD 1;
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

module pe(gnt,enc);
        //synopsys template
        parameter OUT_WIDTH = `PRF_width;
        parameter IN_WIDTH  = 1<<OUT_WIDTH;

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
endmodule
