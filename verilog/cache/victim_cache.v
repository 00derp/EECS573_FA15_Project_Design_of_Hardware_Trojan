/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  victim_cache.v                                      //
//                                                                     //
//  Description :  4-line fully associative cache                      //
//                                                                     //
/////////////////////////////////////////////////////////////////////////


module victim_cache (
  input clock, reset, wr_en, invalidate_en,
  input [15:0] addr_in,
  input [15:0] invalidate_addr,
  input [63:0] data_in,

  output logic hit_out,
  output logic [63:0] data_out
  );

  logic       hit;
  logic [3:0] valid;
  logic [3:0][15:0] addr;
  logic [3:0][63:0] data;
  logic [2:0] lru, hit_next_lru;
  logic [1:0] hit_index;
  

  always_comb begin
    hit = 0;
    data_out = 64'b0;
    hit_index = 0;
    for (int i = 0; i < 4; i++) begin
      if (addr[i][15:3] == addr_in[15:3] && valid[i]) begin
        hit = 1;
        hit_index = i;
        data_out = data[i];
      end
    end
  end

  assign hit_out = hit && !wr_en;
  
  always_comb begin
    if (hit_index == 2'b0)
      hit_next_lru = {lru[2], 1'b0, 1'b1};
    else if (hit_index == 2'b01)
      hit_next_lru = {lru[2], 1'b0, 1'b0};
    else if (hit_index == 2'b10)
      hit_next_lru = {1'b0, 1'b1, lru[0]};
    else
      hit_next_lru = {1'b1, 1'b1, lru[0]};
  end
  
  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      lru  <= `SD 3'b000;
    end
    else begin
      if (wr_en) begin
        if (hit) begin
          lru    <= `SD hit_next_lru;
        end
        else if (lru[1] == 1'b0) begin
          lru[2] <= `SD ~lru[2];
          lru[1] <= `SD 1'b1;
        end
        else if (lru[1] == 1'b1) begin
          lru[0] <= `SD ~lru[0];
          lru[1] <= `SD 1'b0;
        end
      end
    end
  end
  
  // validate and invalidate logic
  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      valid <= `SD 0;
      addr  <= `SD 0;
      data  <= `SD 0;
    end
    else begin
      if (wr_en) begin
        if (hit) begin
          data[hit_index] <= `SD data_in;
          addr[hit_index] <= `SD addr_in;
        end
        else if (lru[2:1] == 2'b00) begin
          valid[3] <= `SD 1'b1;
          data[3]  <= `SD data_in;
          addr[3]  <= `SD {addr_in[15:3],3'b000};
        end
        else if (lru[2:1] == 2'b10) begin
          valid[2] <= `SD 1'b1;
          data[2]  <= `SD data_in;
          addr[2]  <= `SD {addr_in[15:3],3'b000};
        end
        else if (lru[1:0] == 2'b10) begin
          valid[1] <= `SD 1'b1;
          data[1]  <= `SD data_in;
          addr[1]  <= `SD {addr_in[15:3],3'b000};
        end
        else begin
          valid[0] <= `SD 1'b0;
          data[0]  <= `SD data_in;
          addr[0]  <= `SD {addr_in[15:3],3'b000};
        end
      end
      if (invalidate_en) begin
        for (int i = 0; i < 4; i++) begin
          if (addr[i] == invalidate_addr[i]) begin
            valid[i] <= `SD 0;
          end
        end
      end
    end
  end


endmodule