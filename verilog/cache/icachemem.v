// cachemem16x2x64

`timescale 1ns/100ps

module icachemem(
        input clock, reset, wr1_en,
        input  [3:0] wr1_idx, rd1_idx, prefetch_rd_idx,
        input  [8:0] wr1_tag, rd1_tag, prefetch_rd_tag,
        input [63:0] wr1_data, 

        output [63:0] rd1_data,
        output rd1_valid, prefetch_valid
        
      );



  logic [15:0] [63:0] data_way0, data_way1;
  logic [15:0]  [8:0] tags_way0, tags_way1; 
  logic [15:0]        valids_way0, valids_way1;
  logic [15:0]        lru;

  assign rd1_data = (valids_way0[rd1_idx] && (tags_way0[rd1_idx] == rd1_tag)) ? data_way0[rd1_idx] : data_way1[rd1_idx] ;
  assign rd1_valid = (valids_way0[rd1_idx] && (tags_way0[rd1_idx] == rd1_tag)) || (valids_way1[rd1_idx] && (tags_way1[rd1_idx] == rd1_tag));
  assign prefetch_valid = (valids_way0[prefetch_rd_idx] && (tags_way0[prefetch_rd_idx] == prefetch_rd_tag)) || (valids_way1[prefetch_rd_idx] && (tags_way1[prefetch_rd_idx] == prefetch_rd_tag));
  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset)
      lru <= `SD 16'b0;
    else if (valids_way0[rd1_idx] && (tags_way0[rd1_idx] == rd1_tag))
      lru[rd1_idx] <= `SD 1;
    else if (valids_way1[rd1_idx] && (tags_way1[rd1_idx] == rd1_tag))
      lru[rd1_idx] <= `SD 0;
  end
  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock)
  begin
    if(reset) begin
      valids_way0 <= `SD 16'b0;
      valids_way1 <= `SD 16'b0;
    end
    else if(wr1_en)
      if (lru[wr1_idx])
        valids_way1[wr1_idx] <= `SD 1;
      else
        valids_way0[wr1_idx] <= `SD 1;
  end
  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock)
  begin
    if(wr1_en) begin
      if (lru[wr1_idx]) begin
        data_way1[wr1_idx] <= `SD wr1_data;
        tags_way1[wr1_idx] <= `SD wr1_tag;
      end
      else begin
        data_way0[wr1_idx] <= `SD wr1_data;
        tags_way0[wr1_idx] <= `SD wr1_tag;
      end
    end
  end

endmodule
