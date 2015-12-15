module mux21 (
  input select,
  input [4:0] in_0,
  input [4:0] in_1,
  output [4:0] out
  );

  assign out = select ? in_1 : in_0;

endmodule