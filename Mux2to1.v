module Mux2to1(
	input [31:0]in1,
	input [31:0]in2,
	input select,
	output wire [31:0]out
);
	assign out = select==0?in1:in2;
endmodule
