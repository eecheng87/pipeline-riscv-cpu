module Shift_check(
	input clk,
	input [31:0]rs2_data,
	input [31:0]imm,
	input alu_src,
	input [6:0]op,
	input [2:0]func3,
	output reg[31:0]new_rs2,
	output reg[31:0]new_imm
);
	always@*begin
		if(op==7'b0110011)begin
		// R
			if(func3==3'b001||func3==3'b101)begin
				new_rs2 = rs2_data[4:0];
				new_imm = imm;
			end else begin
				new_rs2 = rs2_data;
				new_imm = imm;
			end
		end else if(op==7'b0010011)begin
		// I
			if(func3==3'b001||func3==3'b101)begin
				new_rs2 = rs2_data;
				new_imm = {27'b0,imm[4:0]};
			end else begin
				new_rs2 = rs2_data;
				new_imm = new_imm;
			end
		end if(op==7'b1100111)begin
			new_rs2 = rs2_data;
			new_imm = imm;		
		end else begin
			new_rs2 = rs2_data;
			new_imm = imm;
		end
	end
endmodule
