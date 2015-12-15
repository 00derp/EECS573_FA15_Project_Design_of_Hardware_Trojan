//////////////////////////////////////////////////////////////////////////
//                                                                      //
//   Modulename :  mem_arbiter.v                                        //
//                                                                      //
//  Description :  arbitration logic for mem requests                   //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps

module mem_arbiter (
  input clock, reset,
  // inputs from bus_arbiter
  input  [1:0] bus_arbiter2mem_command,
  input [15:0] bus_arbiter2mem_addr,
  input [63:0] bus_arbiter2mem_data,
  // inputs from icache_ctrl0
  input  [1:0] icache_ctrl02mem_command,
  input [15:0] icache_ctrl02mem_addr,
  // inputs from icache_ctrl1
  input  [1:0] icache_ctrl12mem_command,
  input [15:0] icache_ctrl12mem_addr,
  // inputs from mem
  input [63:0] mem_data,
  input  [3:0] mem_tag,
  input  [3:0] mem_response,
  // outputs to bus_arbiter
//  output logic [63:0] mem_arb2bus_arb_data,
  output logic  [3:0] mem_arb2bus_arb_response,
//  output logic  [3:0] mem_arb2bus_arb_tag,
  // outputs to icache_ctrl0
//  output logic [63:0] mem_arb2icache_ctrl0_data,
  output logic  [3:0] mem_arb2icache_ctrl0_response,
  // outputs to icache_ctrl1
//  output logic [63:0] mem_arb2icache_ctrl1_data,
  output logic  [3:0] mem_arb2icache_ctrl1_response,
  // tag output
  output logic  [3:0] mem_arb_tag_out,
  output logic [63:0] mem_arb_data_out,
  // outputs to mem
  output logic [63:0] mem_arb2mem_data,
  output logic [63:0] mem_arb2mem_addr,
  output logic  [1:0] mem_arb2mem_command

  );

  logic icache_req_priority;

  assign mem_arb2bus_arb_response = bus_arbiter2mem_command != `BUS_NONE ? mem_response : 0;
  assign mem_arb2icache_ctrl0_response = bus_arbiter2mem_command != `BUS_NONE ? 0 : 
                                        (icache_ctrl02mem_command == `BUS_LOAD && icache_ctrl12mem_command == `BUS_LOAD && (icache_ctrl02mem_addr == icache_ctrl12mem_addr)) ? mem_response :
                                        (icache_ctrl02mem_command == `BUS_LOAD && icache_ctrl12mem_command == `BUS_LOAD && !icache_req_priority) ? mem_response :
                                        (icache_ctrl02mem_command == `BUS_LOAD && icache_ctrl12mem_command != `BUS_LOAD) ? mem_response : 0;
  assign mem_arb2icache_ctrl1_response = bus_arbiter2mem_command != `BUS_NONE ? 0 : 
                                        (icache_ctrl02mem_command == `BUS_LOAD && icache_ctrl12mem_command == `BUS_LOAD && (icache_ctrl02mem_addr == icache_ctrl12mem_addr)) ? mem_response :
                                        (icache_ctrl02mem_command == `BUS_LOAD && icache_ctrl12mem_command == `BUS_LOAD && icache_req_priority) ? mem_response :
                                        (icache_ctrl02mem_command != `BUS_LOAD && icache_ctrl12mem_command == `BUS_LOAD) ? mem_response : 0;
  assign mem_arb_tag_out = mem_tag;
  assign mem_arb_data_out = mem_data;
  assign mem_arb2mem_data = bus_arbiter2mem_data;
  assign mem_arb2mem_addr = bus_arbiter2mem_command != `BUS_NONE ? {48'b0, bus_arbiter2mem_addr} : 
                            (icache_ctrl02mem_command == `BUS_LOAD && icache_ctrl12mem_command == `BUS_LOAD && (icache_ctrl02mem_addr == icache_ctrl12mem_addr)) ? {48'b0, icache_ctrl02mem_addr} :
                            (icache_ctrl02mem_command == `BUS_LOAD && icache_ctrl12mem_command == `BUS_LOAD && !icache_req_priority) ? {48'b0, icache_ctrl02mem_addr} : 
                            (icache_ctrl02mem_command == `BUS_LOAD && icache_ctrl12mem_command == `BUS_LOAD && icache_req_priority) ? {48'b0, icache_ctrl12mem_addr} : 
                            icache_ctrl02mem_command == `BUS_LOAD ? {48'b0, icache_ctrl02mem_addr} : {48'b0, icache_ctrl12mem_addr};

  assign mem_arb2mem_command = bus_arbiter2mem_command != `BUS_NONE ? bus_arbiter2mem_command : 
                               (icache_ctrl02mem_command == `BUS_LOAD || icache_ctrl12mem_command == `BUS_LOAD) ? `BUS_LOAD : `BUS_NONE;
  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset)
      icache_req_priority <= `SD 0;
    else begin
      if (icache_ctrl02mem_command == `BUS_LOAD && icache_ctrl12mem_command == `BUS_LOAD && bus_arbiter2mem_command == `BUS_NONE)
        icache_req_priority <= `SD ~icache_req_priority;
    end
  end

endmodule