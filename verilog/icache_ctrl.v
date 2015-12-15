`timescale 1ns/100ps

module icache_ctrl(
  
  input   clock,
  input   reset,
  // mem2ctrl
  input   [3:0] Imem2proc_response,
  input  [63:0] Imem2proc_data,
  input   [3:0] Imem2proc_tag,
  // proc2ctrl
  input  [63:0] proc2Icache_addr,
  input   mispredict,                      // mispredict
  // cache2ctrl
  input  [63:0] cachemem_data,
  input   cachemem_valid,                    // cachemem_hit
  input   prefetch_valid,                    // cachemem_prefetch_hit
  // ctrl2mem
  output logic  [1:0] proc2Imem_command,
  output logic [63:0] proc2Imem_addr,
  // ctrl2proc
  output logic [63:0] Icache_data_out,     // value is memory[proc2Icache_addr]
  output logic  Icache_valid_out,    // when this is high
  // ctrl2cache
  output logic  [3:0] current_index,
  output logic  [8:0] current_tag,
  output logic  [3:0] wr_index,
  output logic  [8:0] wr_tag,
  output logic  data_write_enable,
  output logic  [8:0] prefetch_tag,
  output logic  [3:0] prefetch_index
  );
  parameter prefetch_size = 4;
  logic [prefetch_size-1:0]        MSHR_valid;          // invalidate when data received
  logic [prefetch_size-1:0] [63:0] MSHR_addr;
  logic [prefetch_size-1:0]        MSHR_issued;
  logic [prefetch_size-1:0]  [3:0] MSHR_mem_tag;
  logic                      [1:0] MSHR_issue_ptr, MSHR_receive_ptr;      // be careful when changing the size !!!!!!!
  logic                     [63:0] last_addr;
  logic                            changed_addr;
  
  assign proc2Imem_command = (!MSHR_issued[MSHR_issue_ptr] && !prefetch_valid && !reset && MSHR_valid[MSHR_issue_ptr]) ? `BUS_LOAD : `BUS_NONE;
  assign proc2Imem_addr = {MSHR_addr[MSHR_issue_ptr][63:3], 3'b0};
  assign Icache_data_out = cachemem_data;
  assign Icache_valid_out = cachemem_valid;
  assign {current_tag, current_index} = proc2Icache_addr[15:3];
  assign {wr_tag, wr_index} = MSHR_addr[MSHR_receive_ptr][15:3];
  assign data_write_enable = (MSHR_valid[MSHR_receive_ptr] && MSHR_mem_tag[MSHR_receive_ptr] == Imem2proc_tag && Imem2proc_tag != 0);
  assign {prefetch_tag, prefetch_index} = MSHR_addr[MSHR_issue_ptr][15:3];
  assign changed_addr = last_addr != proc2Icache_addr;

  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      last_addr <= `SD -1;
    end
    else
      last_addr <= `SD proc2Icache_addr;
  end

  // MSHR_receive_ptr
  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      MSHR_receive_ptr <= `SD 0;
    end
    else begin
      if (mispredict) begin
        MSHR_receive_ptr <= `SD 0;
      end
      else if (!cachemem_valid && changed_addr) begin
        MSHR_receive_ptr <= `SD 0;
      end
      else if ((!MSHR_valid[MSHR_receive_ptr] || (MSHR_mem_tag[MSHR_receive_ptr] == Imem2proc_tag && Imem2proc_tag != 0)) && MSHR_receive_ptr != (prefetch_size - 1)) begin
        MSHR_receive_ptr <= `SD MSHR_receive_ptr + 1'b1;
      end
    end
  end


  // MSHR_issue_ptr
  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      MSHR_issue_ptr <= `SD 0;
    end
    else begin
      if (mispredict) begin
        MSHR_issue_ptr <= `SD 0;
      end
      else if (!cachemem_valid && changed_addr) begin
        MSHR_issue_ptr <= `SD 0;
      end
      else if ((Imem2proc_response != 0 || prefetch_valid) && MSHR_issue_ptr != (prefetch_size - 1)) begin
        MSHR_issue_ptr <= `SD MSHR_issue_ptr + 1'b1;
      end
    end
  end

  // MSHR_mem_tag logic
  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      MSHR_mem_tag <= `SD {prefetch_size{4'b0}};
    end
    else begin
      if (mispredict) begin
        MSHR_mem_tag <= `SD {prefetch_size{4'b0}};
      end
      else if (!cachemem_valid && changed_addr) begin
        MSHR_mem_tag <= `SD {prefetch_size{4'b0}};
      end
      else if (Imem2proc_response != 0) begin
        MSHR_mem_tag[MSHR_issue_ptr] <= `SD Imem2proc_response;
      end
    end
  end

  // MSHR_addr logic
  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      MSHR_addr <= `SD {prefetch_size{64'b0}};
    end
    else begin
      if (mispredict) begin
        for (int i = 0; i < prefetch_size; i++) begin
          MSHR_addr[i] <= `SD proc2Icache_addr + (i << 3);
        end
      end
      else if (!cachemem_valid && changed_addr) begin
        for (int i = 0; i < prefetch_size; i++) begin
          MSHR_addr[i] <= `SD proc2Icache_addr + (i << 3);
        end
      end
    end
  end


  // MSHR_issued logic
  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      MSHR_issued <= `SD {prefetch_size{1'b0}};
    end
    else begin
      if (mispredict) begin
        MSHR_issued <= `SD {prefetch_size{1'b0}};
      end
      else if (!cachemem_valid && changed_addr) begin
        MSHR_issued <= `SD {prefetch_size{1'b0}};
      end
      else if (prefetch_valid) begin
        MSHR_issued[MSHR_issue_ptr] <= `SD 1'b0;
      end
      else if (Imem2proc_response != 0) begin
        MSHR_issued[MSHR_issue_ptr] <= `SD 1'b1;
      end
    end
  end

  // MSHR_valid logic
  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      MSHR_valid       <= `SD {prefetch_size{1'b0}};
    end
    else begin
      if (mispredict) begin
        MSHR_valid       <= `SD {prefetch_size{1'b1}};
      end
      else if (!cachemem_valid && changed_addr) begin
        MSHR_valid       <= `SD {prefetch_size{1'b1}};
      end
      else begin
        if (MSHR_mem_tag[MSHR_receive_ptr] == Imem2proc_tag && Imem2proc_tag != 0) begin
          MSHR_valid[MSHR_receive_ptr] <= `SD 1'b0;
        end
        else if (prefetch_valid) begin
          MSHR_valid[MSHR_issue_ptr]   <= `SD 1'b0;
        end
      end
    end
  end

endmodule