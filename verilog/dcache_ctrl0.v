//////////////////////////////////////////////////////////////////////////
//                                                                      //
//   Modulename :  dcache_ctrl0.v                                       //
//                                                                      //
//  Description :  Mealy FSM of MESI Cache Controller for CPU0          //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps



module dcache_ctrl0(
  input clock, reset, mispredict,
  input  [2:0] CPU_ID,
  // inputs
  // proc2cache
  input [15:0] proc2Dcache_addr,
  input [63:0] proc2Dcache_data,
  input  [1:0] proc2Dcache_command,
  // req_bus
  input [15:0] req_bus_addr,
  input  [1:0] req_bus_command,
  input  [2:0] req_bus_source,
  // resp_bus
  input [63:0] resp_bus_data,
//  input  [2:0] resp_bus_dest,        // bit0 for proc0, bit1 for proc1, bit2 for mem
  input        resp_bus_valid,
  // hit/hitm_bus
  input        hit_bus,
  input        hitm_bus,
  // cache2cache_ctrl
  input  [8:0] cache2cache_ctrl_tag,
  input [63:0] cache2cache_ctrl_data,
  input [63:0] cache2cache_ctrl_resp_data,
  input        cache2cache_ctrl_hit_way0,
  input        cache2cache_ctrl_hit_way1,
  input        cache2cache_ctrl_resp_hit_way0,
  input        cache2cache_ctrl_resp_hit_way1,
  input        cache2cache_ctrl_lru,
  // victim_cache2cache_ctrl
  input        victim_cache2cache_ctrl_hit,
  input [63:0] victim_cache2cache_ctrl_data,
  // mem2cache_ctrl
  input [3:0]  mem_response,                  // from
  input [3:0]  mem_tag,                       // arbiter
  // outputs
  // cache_ctrl2proc
  output logic        cache_ctrl2proc_done_out,
  output logic [63:0] cache_ctrl2proc_data_out,
  // cache_ctrl2resp_bus
  output logic [63:0] cache_ctrl2resp_bus_data,
  output logic        cache_ctrl2resp_bus_valid,
//  output logic  [2:0] cache_ctrl2resp_bus_dest,
  // cache_ctrl2req_bus
  output logic [63:0] cache_ctrl2req_bus_data,
  output logic [15:0] cache_ctrl2req_bus_addr,
  output logic  [1:0] cache_ctrl2req_bus_command,
  // cache_ctrl2cache
  output logic        cache_ctrl2cache_wr_en,
  output logic  [3:0] cache_ctrl2cache_index,
  output logic  [8:0] cache_ctrl2cache_tag,
  output logic  [3:0] cache_ctrl2cache_resp_index,
  output logic  [8:0] cache_ctrl2cache_resp_tag,
  output logic [63:0] cache_ctrl2cache_data,
  // cache_ctrl2victim_cache
  output logic        cache_ctrl2victim_cache_wr_en,
  output logic [15:0] cache_ctrl2victim_cache_addr_in,
  output logic [63:0] cache_ctrl2victim_cache_data,
  output logic        cache_ctrl2victim_cache_invalidate_en,
  output logic [15:0] cache_ctrl2victim_cache_invalidate_addr,
  // cache_ctrl2hit/hitm
  output logic cache_ctrl2hit,
  output logic cache_ctrl2hitm,
  output logic cache_ctrl_state,

  output logic write_back,
  output logic write_back_way_out
  );

  logic [15:0][1:0][1:0] cache_state;
  logic             cache_ctrl_next_state;
  logic       [1:0] cur_cache_state, cur_cache_next_state, resp_cache_state, resp_cache_next_state;
  logic             cur_cache_next_way, resp_cache_next_way;
  logic       [3:0] cur_mem_tag;
  logic             pr, pw, br, bi, rep, miss;
  logic       [3:0] modified_index;
  logic             need_write_back, write_back_way;
  // brave try
  logic             cache_ctrl2proc_done, delayed_cache_ctrl2proc_done;
  logic      [63:0] cache_ctrl2proc_data, delayed_cache_ctrl2proc_data;
  logic       [1:0] delayed_proc2Dcache_command;
  always_ff @(posedge clock) begin
    if (reset) begin
      delayed_proc2Dcache_command <= `SD `BUS_NONE;
      delayed_cache_ctrl2proc_data <= `SD 0;
      delayed_cache_ctrl2proc_done <= `SD 0;
    end
    else begin
      if (delayed_cache_ctrl2proc_done == 0) begin
        delayed_proc2Dcache_command <= `SD proc2Dcache_command;
        delayed_cache_ctrl2proc_data <= `SD cache_ctrl2proc_data;
        delayed_cache_ctrl2proc_done <= `SD cache_ctrl2proc_done;
      end
      else begin
        delayed_proc2Dcache_command <= `SD proc2Dcache_command;
        delayed_cache_ctrl2proc_data <= `SD cache_ctrl2proc_data;
        delayed_cache_ctrl2proc_done <= `SD 0;
      end
    end
  end
  assign cache_ctrl2proc_done_out = delayed_cache_ctrl2proc_done && (delayed_proc2Dcache_command == proc2Dcache_command) ;
  assign cache_ctrl2proc_data_out = delayed_cache_ctrl2proc_data;


  logic       need_write_back_reg;
  logic [3:0] modified_index_reg;
  logic state;//0 for search 1 for req(Write back only)

  logic cache2cache_ctrl_resp_hit, cache2cache_ctrl_hit;
  assign cache2cache_ctrl_resp_hit = cache2cache_ctrl_resp_hit_way0 | cache2cache_ctrl_resp_hit_way1;
  assign cache2cache_ctrl_hit      = cache2cache_ctrl_hit_way0 | cache2cache_ctrl_hit_way1;
  
  assign cur_cache_state  = cache2cache_ctrl_hit_way0 ? cache_state[proc2Dcache_addr[6:3]][0] :
                            cache2cache_ctrl_hit_way1 ? cache_state[proc2Dcache_addr[6:3]][1] :
                            cache_state[proc2Dcache_addr[6:3]][cache2cache_ctrl_lru];

  assign resp_cache_state = cache2cache_ctrl_resp_hit_way1 ? cache_state[req_bus_addr[6:3]][1] :
                            cache_state[req_bus_addr[6:3]][0];

//  assign cache_ctrl2proc_done = proc2Dcache_command != `BUS_NONE && cache_ctrl2cache_wr_en;

  // assign next state
  assign cache_ctrl_next_state = ((cache_ctrl_state == `STABLE) && pr && !hit_bus && !hitm_bus && (mem_response != 0)) ? 1'b1 :
                                 ((cache_ctrl_state == `IE) && (cur_mem_tag == mem_tag) && (mem_tag != 0)) ? 1'b0 : cache_ctrl_state;
  assign pr = req_bus_command == `GETS && req_bus_source == CPU_ID;       // ownGets
  assign pw = req_bus_command == `GETM && req_bus_source == CPU_ID;       // ownGetm
  assign rep = req_bus_command == `PUTM && req_bus_source == CPU_ID;      // ownPutm
  assign br = req_bus_command == `GETS && req_bus_source != CPU_ID;       // otherGets
  assign bi = req_bus_command == `GETM && req_bus_source != CPU_ID;       // otherGetm
  assign miss = !hit_bus && !hitm_bus;
  // assign outputs
  assign {cache_ctrl2cache_resp_tag, cache_ctrl2cache_resp_index} = req_bus_addr[15:3];
  assign cache_ctrl2cache_tag = proc2Dcache_command == `BUS_NONE ? 9'b111111111 : proc2Dcache_addr[15:7];
  assign cache_ctrl2cache_index = (write_back) ? modified_index_reg : proc2Dcache_addr[6:3];
  assign cache_ctrl2hit = req_bus_source != CPU_ID ? (resp_cache_state == `CACHE_SHARED || resp_cache_state == `CACHE_EXCLUSIVE) && cache2cache_ctrl_resp_hit : 0;
  assign cache_ctrl2hitm = req_bus_source != CPU_ID ? (resp_cache_state == `CACHE_MODIFIED) && cache2cache_ctrl_resp_hit : 0;
  assign cache_ctrl2req_bus_data = cache2cache_ctrl_data;
  assign cache_ctrl2req_bus_addr = write_back ? {cache2cache_ctrl_tag, modified_index_reg, 3'b0} : 
                                   cache_ctrl2req_bus_command == `PUTM ? {cache2cache_ctrl_tag, proc2Dcache_addr[6:3], 3'b0} : proc2Dcache_addr;

  //assign cache_ctrl2victim_cache_wr_en = rep && mem_response != 0;
  assign cache_ctrl2victim_cache_wr_en = rep;
  assign cache_ctrl2victim_cache_addr_in = cache_ctrl2victim_cache_wr_en ? req_bus_addr : proc2Dcache_addr;
  assign cache_ctrl2victim_cache_data = cache2cache_ctrl_data;
  assign cache_ctrl2victim_cache_invalidate_en = bi;
  assign cache_ctrl2victim_cache_invalidate_addr = req_bus_addr;

  always_comb begin
    if (delayed_cache_ctrl2proc_done)
      cache_ctrl2req_bus_command = `NONE;
    else if ((proc2Dcache_command == `BUS_LOAD && cur_cache_state == `CACHE_MODIFIED && !cache2cache_ctrl_hit && !victim_cache2cache_ctrl_hit))
      cache_ctrl2req_bus_command = `PUTM;
    else if (proc2Dcache_command == `BUS_STORE && cur_cache_state == `CACHE_MODIFIED && !cache2cache_ctrl_hit)
      cache_ctrl2req_bus_command = `PUTM;
    else if (proc2Dcache_command == `BUS_LOAD && cache_ctrl_state == `STABLE && ((!cache2cache_ctrl_hit || (cache2cache_ctrl_hit && cur_cache_state == `CACHE_INVALID)) && !victim_cache2cache_ctrl_hit))
      cache_ctrl2req_bus_command = `GETS;
    else if (proc2Dcache_command == `BUS_STORE && cache_ctrl_state == `STABLE && (!cache2cache_ctrl_hit || (cache2cache_ctrl_hit && (cur_cache_state == `CACHE_SHARED || cur_cache_state == `CACHE_INVALID))))
      cache_ctrl2req_bus_command = `GETM;
    else if (write_back && state)
      cache_ctrl2req_bus_command = `PUTM;
    else
      cache_ctrl2req_bus_command = `NONE;
  end


  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      state <= `SD 0;
    end
    else begin
      if (state == 0 && need_write_back && proc2Dcache_command == `BUS_WRITE_BACK)
        state <= `SD 1;
      else if (state == 1 && (rep || br || bi))
        state <= `SD 0;
    end
  end

  always_comb begin
    need_write_back = 0;
    modified_index  = 0;
    write_back_way = 0;
    for (int i = 0; i < 16; i++) begin
      if (cache_state[i][0] == `CACHE_MODIFIED) begin
        need_write_back = 1;
        modified_index  = i;
      end
    end
    for (int i = 0; i < 16; i++) begin
      if (cache_state[i][1] == `CACHE_MODIFIED) begin
        need_write_back = 1;
        modified_index  = i;
        write_back_way  = 1;
      end
    end
  end

  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      write_back          <= `SD 0;
      modified_index_reg  <= `SD 0;
      write_back_way_out  <= `SD 0;
      need_write_back_reg <= `SD 0;
    end
    else begin
      if (proc2Dcache_command == `BUS_WRITE_BACK && state == 0) begin
        write_back          <= `SD 1;
        modified_index_reg  <= `SD modified_index;
        write_back_way_out  <= `SD write_back_way;
        need_write_back_reg <= `SD need_write_back;
      end
    end
  end
  
  assign cache_ctrl2proc_done = write_back ? ~need_write_back_reg :
                                proc2Dcache_command == `BUS_LOAD ? (((cache2cache_ctrl_hit && cur_cache_state != `CACHE_INVALID) || victim_cache2cache_ctrl_hit) && !(bi && proc2Dcache_addr[15:3] == req_bus_addr[15:3])) :
                                proc2Dcache_command == `BUS_STORE ? (pw || ((cur_cache_state == `CACHE_EXCLUSIVE || cur_cache_state == `CACHE_MODIFIED) && cache2cache_ctrl_hit)) :
                                proc2Dcache_command == `BUS_NONE ? 0 : 0;

  assign cache_ctrl2proc_data = cache2cache_ctrl_hit ? cache2cache_ctrl_data : victim_cache2cache_ctrl_data;
  always_comb begin
    cache_ctrl2cache_wr_en = 0;
    cache_ctrl2cache_data = 0;
    cur_cache_next_state = cur_cache_state;
    cur_cache_next_way   = cache2cache_ctrl_hit_way0 ? 0 : cache2cache_ctrl_hit_way1 ? 1 : cache2cache_ctrl_lru;
    
    if (cache_ctrl_state == `STABLE) begin
      if (rep) begin
        cur_cache_next_state = `CACHE_INVALID;
      end
      else if (br && proc2Dcache_addr[15:3] == req_bus_addr[15:3] && proc2Dcache_command == `BUS_STORE) begin
          cache_ctrl2cache_wr_en = 1;
          cache_ctrl2cache_data = proc2Dcache_data;
      end
      else if (cur_cache_state == `CACHE_INVALID || !cache2cache_ctrl_hit) begin
        if (pr && hit_bus && resp_bus_valid) begin
          cache_ctrl2cache_wr_en = 1;
          cache_ctrl2cache_data = resp_bus_data;
          cur_cache_next_state = `CACHE_SHARED;
        end
        else if (pr && hitm_bus && resp_bus_valid) begin
          cache_ctrl2cache_wr_en = 1;
          cache_ctrl2cache_data = resp_bus_data;
          cur_cache_next_state = `CACHE_SHARED;
        end
        else if (pw) begin
          cache_ctrl2cache_wr_en = proc2Dcache_command == `BUS_STORE;
          cache_ctrl2cache_data = proc2Dcache_data;
          cur_cache_next_state = `CACHE_MODIFIED;
        end
      end
      else if (cur_cache_state == `CACHE_SHARED) begin
      if (pw) begin
          cache_ctrl2cache_wr_en = proc2Dcache_command == `BUS_STORE;
          cache_ctrl2cache_data = proc2Dcache_data;
          cur_cache_next_state = `CACHE_MODIFIED;
        end
      end
      else if (cur_cache_state == `CACHE_EXCLUSIVE) begin
        if (proc2Dcache_command == `BUS_STORE) begin
          cache_ctrl2cache_wr_en = 1;
          cache_ctrl2cache_data = proc2Dcache_data;
          cur_cache_next_state = `CACHE_MODIFIED;
        end
      end
      else if (cur_cache_state == `CACHE_MODIFIED) begin
        if (proc2Dcache_command == `BUS_STORE) begin
          cache_ctrl2cache_wr_en = 1;
          cache_ctrl2cache_data = proc2Dcache_data;
        end
      end
    end
    else begin
      if (cur_mem_tag == mem_tag && mem_tag != 0) begin
        cache_ctrl2cache_wr_en = 1;
        cache_ctrl2cache_data  = resp_bus_data;
        cur_cache_next_state = `CACHE_EXCLUSIVE;
      end
    end
  end

  always_comb begin
    // cache_ctrl2resp_bus
    cache_ctrl2resp_bus_data = 0;
    resp_cache_next_state = resp_cache_state;
    cache_ctrl2resp_bus_valid = 0;
    resp_cache_next_way   = cache2cache_ctrl_resp_hit_way1 ? 1 : 0;
    if (write_back && rep) begin
      resp_cache_next_state = `CACHE_INVALID;
      resp_cache_next_way   = write_back_way_out;
    end
    if (bi && cache2cache_ctrl_resp_hit) begin
      resp_cache_next_state = `CACHE_INVALID;
    end
    else if (br) begin
      if (proc2Dcache_addr[15:3] == req_bus_addr[15:3] && proc2Dcache_command == `BUS_STORE && cache2cache_ctrl_resp_hit) begin
        if (resp_cache_state == `CACHE_MODIFIED || resp_cache_state == `CACHE_EXCLUSIVE) begin
          resp_cache_next_state = `CACHE_SHARED;
          cache_ctrl2resp_bus_valid = 1;
          cache_ctrl2resp_bus_data = proc2Dcache_data;
        end
        else if (resp_cache_state == `CACHE_SHARED) begin
          cache_ctrl2resp_bus_valid = 1;
          cache_ctrl2resp_bus_data = cache2cache_ctrl_resp_data;
        end
      end
      else if (proc2Dcache_addr[15:3] == req_bus_addr[15:3] && proc2Dcache_command == `BUS_LOAD && cache2cache_ctrl_resp_hit) begin
        resp_cache_next_state = `CACHE_SHARED;
        cache_ctrl2resp_bus_valid = 1;
        cache_ctrl2resp_bus_data = cache2cache_ctrl_resp_data;
      end
      else if (resp_cache_state != `CACHE_INVALID && cache2cache_ctrl_resp_hit) begin
        cache_ctrl2resp_bus_valid = 1;
        cache_ctrl2resp_bus_data = cache2cache_ctrl_resp_data;
        resp_cache_next_state = `CACHE_SHARED;
      end
    end
  end



  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset)
      cache_ctrl_state <= `SD 1'b0;
    else begin
      if (mispredict)
        cache_ctrl_state <= `SD 1'b0;
      else
        cache_ctrl_state <= `SD cache_ctrl_next_state;
    end
  end

  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset)
      cache_state <= `SD {32{2'b0}};
    else begin
      if (bi && proc2Dcache_command == `BUS_LOAD && proc2Dcache_addr[15:3] == req_bus_addr[15:3])
        cache_state[cache_ctrl2cache_index][cur_cache_next_way]      <= `SD `CACHE_INVALID;
      else if (br && proc2Dcache_addr[15:3] == req_bus_addr[15:3] && proc2Dcache_command == `BUS_STORE)
        cache_state[cache_ctrl2cache_index][cur_cache_next_way]      <= `SD `CACHE_SHARED;
      else if (br && proc2Dcache_addr[15:3] == req_bus_addr[15:3] && proc2Dcache_command == `BUS_LOAD && cache2cache_ctrl_resp_hit)
        cache_state[cache_ctrl2cache_index][cur_cache_next_way]      <= `SD `CACHE_SHARED;
      else begin
        if (write_back) begin
          if (rep)
            cache_state[modified_index_reg][resp_cache_next_way] <= `SD resp_cache_next_state;
        end
        else begin
          cache_state[cache_ctrl2cache_index][cur_cache_next_way]      <= `SD cur_cache_next_state;
          if (bi | br)
            cache_state[cache_ctrl2cache_resp_index][resp_cache_next_way] <= `SD resp_cache_next_state;
        end
      end
    end
  end

  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset)
      cur_mem_tag <= `SD 0;
    else begin
      if (mispredict)
        cur_mem_tag <= `SD 0;
      else if (cache_ctrl_state == `STABLE && pr && !hit_bus && !hitm_bus && mem_response != 0)
        cur_mem_tag <= `SD mem_response;
      else if (cache_ctrl_state == `IE && cur_mem_tag == mem_tag && mem_tag != 0)
        cur_mem_tag <= `SD 0;
    end
  end

endmodule
