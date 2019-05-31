module RegFile(
	input clk,
	input [4:0]rs1_addr,
	input [4:0]rs2_addr,
	input [4:0]rd_addr,
	input regWrite,
	input [31:0]rd_data,
    output wire[31:0]rs1_data,
	output wire[31:0]rs2_data,
	input [6:0]op,
	input [31:0]pc
);

	reg [31:0]Register[0:31];

	initial begin
		Register[0]=32'b0;
		Register[1]=32'b0;
	end

	assign rs1_data = (op==7'b0110111)?0:Register[rs1_addr];
	assign rs2_data = Register[rs2_addr];

	always@(posedge clk)begin
		 
		if(regWrite==1)begin
			Register[rd_addr] <= rd_addr==0?0:rd_data; 
		end
	end

endmodule
