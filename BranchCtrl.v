module BranchCtrl(
	input [2:0]func3,
	input zero,
	input [1:0]btype,   // it is for check whether it is b-type , j , i 	
	input [31:0]alu_out, // when it is 1 means `less than` => set less than
	output reg[1:0]b_ctrl
);
	always@*begin		
		if(btype==1)begin
			case(func3)
				3'b000:b_ctrl = (zero==1&&btype==1)?1:2;
				3'b001:b_ctrl = (zero!=1&&btype==1)?1:2;
				3'b100:b_ctrl = (alu_out==1&&btype==1)?1:2;
				3'b101:b_ctrl = (alu_out==1&&btype==1)?2:1;
				3'b110:b_ctrl = (alu_out==1&&btype==1)?1:2;
				3'b111:b_ctrl = (alu_out==1&&btype==1)?2:1;
				default:b_ctrl = 1;
			endcase
		end else if(btype==2)begin
			// J type
			b_ctrl = 1;
		end else if(btype==3)begin
			// I type => JALR
			b_ctrl = 0;
		end else begin
			b_ctrl = 2;
		end
	end
endmodule
