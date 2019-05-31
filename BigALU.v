module BigALU(
	input [31:0]src1,
	input [31:0]src2,
	input [3:0]alu_ctrl,
	output reg zero,
	output reg [31:0]alu_out
);
	always@*begin
		case(alu_ctrl)
			4'b0000:alu_out=src1&src2;
			4'b0001:alu_out=src1|src2;	
			4'b0010:alu_out=src1+src2;
			4'b0110:alu_out=src1-src2;
			4'b0111:alu_out=$signed(src1)<$signed(src2)?32'b1:0;
			4'b1100:alu_out=src1^src2;
			4'b1101:alu_out=$unsigned(src1)>>$unsigned(src2[4:0]);
			4'b1110:alu_out=$unsigned(src1)<<$unsigned(src2[4:0]);
			4'b1111:alu_out=$signed(src1)>>>$unsigned(src2[4:0]);
			4'b1000:alu_out=$signed(src1)<<<$unsigned(src2);
			4'b1001:alu_out=$unsigned(src1)<$unsigned(src2)?32'b1:0;
			default:alu_out=0;
		endcase
		
		zero = src1==src2?1:0;

	end
endmodule
