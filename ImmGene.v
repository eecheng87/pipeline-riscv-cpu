module ImmGene(
	input [2:0]immType,
	input [31:0]instr,
	output reg[31:0]immOut 
);

	always@*begin
		case(immType)
			3'b000:immOut = {instr[31:12],12'h000};
			3'b001:immOut = instr[31]==1?{20'b11111111111111111111,instr[31:20]}:{20'b00000000000000000000,instr[31:20]};
			3'b010:immOut = instr[31]==1?{20'b11111111111111111111,instr[31:25],instr[11:7]}:{20'b00000000000000000000,instr[31:25],instr[11:7]};
			3'b011:immOut = instr[31]==1?{19'b1111111111111111111,instr[31],instr[7],instr[30:25],instr[11:8],1'b0}:{19'b0000000000000000000,instr[31],instr[7],instr[30:25],instr[11:8],1'b0};
			3'b100:immOut = instr[31]==1?{11'b11111111111,instr[31],instr[19:12],instr[20],instr[30:21],1'b0}:{11'b00000000000,instr[31],instr[19:12],instr[20],instr[30:21],1'b0};
			default:immOut = 0;
		endcase
	end
endmodule
