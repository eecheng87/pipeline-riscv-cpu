module ALU_ctrl(
	input [2:0]func3,
	input [6:0]func7,
	input [2:0]alu_op,
	output reg [3:0]alu_ctrl
);
	always@*begin
		if(alu_op==3'b000)begin
		// R
			if(func3==3'b000)
				alu_ctrl = func7[5]==1?4'b0110:4'b0010;
			else if(func3[2:0]==3'b001)
				alu_ctrl = 4'b1110;
			else if(func3[2:0]==3'b010)
				alu_ctrl = 4'b0111;
			else if(func3[2:0]==3'b011)
				alu_ctrl = 4'b1001;
			else if(func3[2:0]==3'b100)
				alu_ctrl = 4'b1100;
			else if(func3[2:0]==3'b101)
				alu_ctrl = func7[5]==1?4'b1111:4'b1101;
			else if(func3[2:0]==3'b110)
				alu_ctrl = 4'b0001;
			else if(func3[2:0]==3'b111)
				alu_ctrl = 4'b0000;
		end else if(alu_op==3'b001)begin
		// I-1 => lw
			alu_ctrl = 4'b0010;
		end else if(alu_op==3'b110)begin
		// I-2 => e.g: addi
			if(func3[2:0]==3'b000)
				alu_ctrl = 4'b0010;
			else if(func3[2:0]==3'b010)
				alu_ctrl = 4'b0111;
			else if(func3[2:0]==3'b011)
				alu_ctrl = 4'b1001;
			else if(func3[2:0]==3'b100)
				alu_ctrl = 4'b1100;
			else if(func3[2:0]==3'b110)
				alu_ctrl = 4'b0001;
			else if(func3[2:0]==3'b111)
				alu_ctrl = 4'b0000;
			else if(func3[2:0]==3'b001)
				alu_ctrl = 4'b1110;
			else if(func3[2:0]==3'b101)
				alu_ctrl = func7[5]==1?4'b1111:4'b1101;
		end else if(alu_op==3'b111)begin
		// I-3 => JALR
			alu_ctrl = 4'b0010;
		end else if(alu_op==3'b010)begin
		// S
			alu_ctrl = 4'b0010;
		end else if(alu_op==3'b011)begin
		// B
			if(func3[2:1]==2'b00)
			// beq, bnq
				alu_ctrl = 4'b0110;
			else if(func3[2:1]==2'b11)
			// bltu, bgeu
				alu_ctrl = 4'b1001;
			else
			// blt, bge
				alu_ctrl = 4'b0111;
		end else if(alu_op==3'b100)begin
		// U
			alu_ctrl = 4'b0010;
		end else if(alu_op==3'b101)begin
		// J
			alu_ctrl = 4'b0000; // don't care
		end  
	end
endmodule
