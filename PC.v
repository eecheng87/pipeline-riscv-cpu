module PC(
	input clk,
	input rst,
	input PCWrite,
	input [31:0]pcin,
	output reg[31:0] pcout
);
	always@(posedge clk)begin
		if(PCWrite)begin
			if(rst)
				pcout<=32'h00000000;
			else
				pcout <= pcin;
		end
	end

endmodule
