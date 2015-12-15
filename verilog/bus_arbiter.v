//////////////////////////////////////////////////////////////////////////
//                                                                      //
//   Modulename :  bus_arbiter.v                                        //
//                                                                      //
//  Description :  req/resp bus arbiter                                 //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps

`define BA_IDLE 0
`define BA_BUSY 1

module bus_arbiter(
  input clock,
  input reset,
  // inputs from dcache ctrl0
  input cache_ctrl0_state,
  input cache_ctrl02hit,
  input cache_ctrl02hitm,
  input [63:0] cache_ctrl02req_bus_data,
  input [15:0] cache_ctrl02req_bus_addr,
  input  [1:0] cache_ctrl02req_bus_command,
  input [63:0] cache_ctrl02resp_bus_data,
  input        cache_ctrl02resp_bus_valid,
  // inputs from dcache ctrl1
  input cache_ctrl1_state,
  input cache_ctrl12hit,
  input cache_ctrl12hitm,
  input [63:0] cache_ctrl12req_bus_data,
  input [15:0] cache_ctrl12req_bus_addr,
  input  [1:0] cache_ctrl12req_bus_command,
  input [63:0] cache_ctrl12resp_bus_data,
  input        cache_ctrl12resp_bus_valid,
  // inputs from mem
  input  [3:0] mem_response,
  input  [3:0] mem_tag,
  input [63:0] mem_data,
  // mispredict inputs
//  input        core0_mispredict,
//  input        core1_mispredict,
  // outputs to req bus
  output logic [15:0] req_bus_addr,
  output logic  [1:0] req_bus_command,
  output logic  [2:0] req_bus_source,
  // outputs to resp bus
  output logic [63:0] resp_bus_data,
  output logic        resp_bus_valid,
  // outputs to dcache ctrl0
  output logic [3:0] mem_response2ctrl0,
  // outputs to dcache ctrl1
  output logic [3:0] mem_response2ctrl1,
  
  output logic [3:0] mem_tag2ctrl,
  // outputs to mem
  output logic  [1:0] bus_arbiter2mem_command,
  output logic [15:0] bus_arbiter2mem_addr,
  output logic [63:0] bus_arbiter2mem_data,
  // outputs to hit/m
  output logic hit_bus,
  output logic hitm_bus
  );

  logic state, next_state;

  logic  [3:0] temp_mem_tag;
  logic [63:0] temp_mem_data;

  logic  [1:0] bus_arbiter2mem_command_buffer;
  logic [15:0] bus_arbiter2mem_addr_buffer;
  logic [63:0] bus_arbiter2mem_data_buffer;
  logic  [1:0] req_bus_command_buffer;
  logic [15:0] req_bus_addr_buffer;
  logic  [2:0] req_bus_source_buffer;
  logic [63:0] req_bus_data_buffer;
  logic [63:0] req_bus_data;
  logic  [1:0] bus_arbiter2mem_command_temp;
  logic [15:0] bus_arbiter2mem_addr_temp;
  logic [63:0] bus_arbiter2mem_data_temp;
  logic  [1:0] req_bus_command_temp;
  logic  [2:0] req_bus_source_temp;
  logic [15:0] req_bus_addr_temp;
  logic [63:0] req_bus_data_temp;
  logic        req_abort;
  // assign req bus
  assign req_bus_command = (state == `BA_BUSY) ? req_bus_command_buffer : `NONE;
  assign req_bus_source  = (state == `BA_BUSY) ? req_bus_source_buffer  : 3'b000;
  assign req_bus_addr    = (state == `BA_BUSY) ? req_bus_addr_buffer    : 16'hFFFF;
//  assign req_bus_data
  
  // assign mem_response2ctrl0
  assign mem_response2ctrl0 = (state == `BA_BUSY && req_bus_source == 3'b001) ? mem_response : 0;
  // assign mem_response2ctrl1
  assign mem_response2ctrl1 = (state == `BA_BUSY && req_bus_source == 3'b010) ? mem_response : 0;
  // assign mem_tag2ctrl
  assign mem_tag2ctrl       = (state == `BA_BUSY) ? 0 : mem_tag;
  
  assign req_abort = 0;// (req_bus_source_buffer == 3'b001 && core0_mispredict) || (req_bus_source_buffer == 3'b010 && core1_mispredict);

  // assign bus_arbiter2mem_temp
  always_comb begin
    bus_arbiter2mem_command_temp = `BUS_NONE;
    bus_arbiter2mem_addr_temp    = 0;
    bus_arbiter2mem_data_temp    = 0;
    if (req_bus_command == `GETS && !hit_bus && !hitm_bus) begin
        bus_arbiter2mem_command_temp = `BUS_LOAD;
        bus_arbiter2mem_addr_temp    = req_bus_addr;
    end
    else if (req_bus_command == `GETS && hitm_bus) begin
      bus_arbiter2mem_command_temp = `BUS_STORE;
      bus_arbiter2mem_addr_temp    = req_bus_addr;
      bus_arbiter2mem_data_temp    = resp_bus_data;
    end
    else if (req_bus_command == `PUTM) begin
      bus_arbiter2mem_command_temp = `BUS_STORE;
      bus_arbiter2mem_addr_temp    = req_bus_addr;
      bus_arbiter2mem_data_temp    = req_bus_data_buffer;
    end
  end

  // assign bus_arbiter2mem
  assign bus_arbiter2mem_command = (state == `BA_BUSY && !req_abort) ? bus_arbiter2mem_command_temp : `BUS_NONE;
  assign bus_arbiter2mem_addr    = (state == `BA_BUSY) ? bus_arbiter2mem_addr_temp    : 0;
  assign bus_arbiter2mem_data    = (state == `BA_BUSY) ? bus_arbiter2mem_data_temp    : 0;

  assign hitm_bus = state == `BA_BUSY ? (cache_ctrl02hitm | cache_ctrl12hitm) : 0;
  assign hit_bus  = state == `BA_BUSY ? (cache_ctrl02hit  | cache_ctrl12hit) : 0;

  // assign resp bus
  always_comb begin
    resp_bus_data = 0;
    resp_bus_valid = 0;
    if (state == `BA_IDLE) begin
      resp_bus_data  = mem_data;
      resp_bus_valid = (mem_tag != 0);
    end
    else if (state == `BA_BUSY) begin
      resp_bus_data  = (cache_ctrl02resp_bus_valid) ? cache_ctrl02resp_bus_data :
                       (cache_ctrl12resp_bus_valid) ? cache_ctrl12resp_bus_data : 64'b0;
      resp_bus_valid = (cache_ctrl02resp_bus_valid) || (cache_ctrl12resp_bus_valid);
    end
  end

  // assign req bus temp
  always_comb begin
    req_bus_command_temp = `NONE;
    req_bus_source_temp  = 3'b000;
    req_bus_addr_temp    = 16'hFFFF;
    req_bus_data_temp    = 0;
    if (cache_ctrl02req_bus_command != `NONE) begin // core0 has priority by default
      req_bus_command_temp = cache_ctrl02req_bus_command;
      req_bus_addr_temp    = cache_ctrl02req_bus_addr;
      req_bus_data_temp    = cache_ctrl02req_bus_data;
      req_bus_source_temp  = 3'b001;
    end
    else if (cache_ctrl12req_bus_command != `NONE) begin
      req_bus_command_temp = cache_ctrl12req_bus_command;
      req_bus_addr_temp    = cache_ctrl12req_bus_addr;
      req_bus_data_temp    = cache_ctrl12req_bus_data;
      req_bus_source_temp  = 3'b010;
    end
  end
  
  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      req_bus_command_buffer <= `SD 0;
      req_bus_source_buffer  <= `SD 0;
      req_bus_addr_buffer    <= `SD 0;
      req_bus_data_buffer    <= `SD 0;
    end
    else begin
      if (state == `BA_IDLE && next_state == `BA_BUSY) begin
        req_bus_command_buffer <= `SD req_bus_command_temp;
        req_bus_source_buffer  <= `SD req_bus_source_temp;
        req_bus_addr_buffer    <= `SD req_bus_addr_temp;
        req_bus_data_buffer    <= `SD req_bus_data_temp;
      end
    end
  end

  always_comb begin
    next_state = state;
    if (state == `BA_IDLE && 
       (cache_ctrl02req_bus_command != `NONE || cache_ctrl12req_bus_command != `NONE) &&
       (cache_ctrl0_state != `IE  && cache_ctrl1_state != `IE)) begin
      next_state = `BA_BUSY;
    end
    else if (state == `BA_BUSY && (((bus_arbiter2mem_command == `BUS_NONE) || (bus_arbiter2mem_command != `BUS_NONE && mem_response != 0)) || req_abort)) begin
      next_state = `BA_IDLE;
    end
  end

  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      state <= `SD `BA_IDLE;
    end
    else begin
      state <= `SD next_state;
    end
  end

  


endmodule
