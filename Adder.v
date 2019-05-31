module Adder(
	input [31:0]src1,
	input [31:0]src2,
	output wire [31:0]out
);
	assign out = src1+src2;
endmodule
