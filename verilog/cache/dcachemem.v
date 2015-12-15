// dcachemem32x64
`timescale 1ns/100ps

module dcachemem(
    input clock, reset, wr_en,
    input [3:0] index_in,
    input [8:0] tag_in,
    input [3:0] resp_index_in, // for checking valid copy
    input [8:0] resp_tag_in, // for checking valid copy
    input [63:0] data_in,
    input        write_back,
    input        write_back_way,

    output logic [8:0]  tag_out,
    output logic [63:0] data_out,
    output logic [63:0] resp_data_out,
    output logic hit_way0,
    output logic hit_way1,
    output logic resp_hit_way0,
    output logic resp_hit_way1,
    output logic lru_out
  );

  logic [15:0] [63:0] data_way0;
  logic [15:0] [63:0] data_way1;

  logic [15:0]  [8:0] tags_way0;
  logic [15:0]  [8:0] tags_way1;
  logic [15:0]        lru;
  logic [15:0]        valid_way0;
  logic [15:0]        valid_way1;



  /*assign tag_out = tags[index_in];
  assign data_out = data[index_in];
  assign resp_data_out = data[resp_index_in];
  assign hit = tags[index_in] == tag_in;
  assign resp_hit = tags[resp_index_in] == resp_tag_in;*/

  assign hit_way0      = (tags_way0[index_in] == tag_in) && valid_way0[index_in];
  assign hit_way1      = (tags_way1[index_in] == tag_in) && valid_way1[index_in];

  assign data_out      = (write_back && !write_back_way) ? data_way0[index_in]:
                         (write_back && write_back_way) ? data_way1[index_in]:
                         hit_way0 ? data_way0[index_in] : 
                         hit_way1 ? data_way1[index_in] :
                         lru[index_in] ? data_way1[index_in] :
                         data_way0[index_in];

  assign tag_out       = (write_back && !write_back_way) ? tags_way0[index_in] :
                         (write_back && write_back_way) ? tags_way1[index_in] :
                         lru[index_in] ? tags_way1[index_in] : tags_way0[index_in];

  assign resp_hit_way0 = (tags_way0[resp_index_in] == resp_tag_in) && valid_way0[resp_index_in];
  assign resp_hit_way1 = (tags_way1[resp_index_in] == resp_tag_in) && valid_way1[resp_index_in];
  assign resp_data_out = resp_hit_way0 ? data_way0[resp_index_in] : data_way1[resp_index_in];
  assign lru_out       = lru[index_in];

  /*always_ff @(posedge clock) begin
    if (reset) begin
      data <= `SD {31{64'b0}};
      tags <= `SD {31{64'b0}};
      lru  <= `SD 0;
    end
    if (wr_en) begin
      data[index_in] <= `SD data_in;
      tags[index_in] <= `SD tag_in;
    end
  end*/

  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin //lru
    if (reset) begin
      lru <= `SD 0;
    end
    else begin
      if (hit_way0)
        lru[index_in] <= `SD 1;
      else if (hit_way1)
        lru[index_in] <= `SD 0;
      else if (wr_en)    
        lru[index_in] <= `SD ~lru[index_in];
    end
  end
  
  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin // way0
    if (reset) begin
      data_way0  <= `SD 0;
      tags_way0  <= `SD 0;
      valid_way0 <= `SD 0;
      data_way1  <= `SD 0;
      tags_way1  <= `SD 0;
      valid_way1 <= `SD 0;
    end
    else begin
      if (wr_en && hit_way0) begin
        data_way0[index_in]  <= `SD data_in;
        tags_way0[index_in]  <= `SD tag_in;
        valid_way0[index_in] <= `SD 1;
      end
      else if (wr_en && hit_way1) begin
        data_way1[index_in]  <= `SD data_in;
        tags_way1[index_in]  <= `SD tag_in;
        valid_way1[index_in] <= `SD 1;
      end
      else if (wr_en && !lru_out) begin
        data_way0[index_in]  <= `SD data_in;
        tags_way0[index_in]  <= `SD tag_in;
        valid_way0[index_in] <= `SD 1;
      end
      else if (wr_en && lru_out) begin
        data_way1[index_in]  <= `SD data_in;
        tags_way1[index_in]  <= `SD tag_in;
        valid_way1[index_in] <= `SD 1;
      end
    end
  end






endmodule