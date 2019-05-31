module Decoder(
	input [6:0]op,
	output reg RegWrite,
	output reg [2:0]ALUop,
	output reg ALUsrc,
	output reg [1:0]branchCtrl, // recognize Jtype, Btype, and other
	output reg PCtoRegSrc,
	output reg RDsrc,
	output reg MRead,
	output reg MWrite,
	output reg MenToReg,
	output reg [2:0]ImmType
);


	always@(op)begin
		if(op==7'b0110011)begin
		// R type
			RegWrite = 1;
			ALUop = 3'b000;
			ALUsrc = 0;
			branchCtrl = 0; // don't care
			PCtoRegSrc = 1; // don't care
			RDsrc = 1;
			MRead = 0;
			MWrite = 0;
			MenToReg = 0;
			ImmType = 3'b111; // don't care
		end else if(op==7'b0100011)begin
		// S type
			RegWrite = 0;
			ALUop = 3'b010;
			ALUsrc = 1;
			branchCtrl = 0; // don't care
			PCtoRegSrc = 1; // don't care
			RDsrc = 1; // don't care
			MRead = 0;
			MWrite = 1;  
			MenToReg = 0; // don't care
			ImmType = 3'b010; 
		end else if(op==7'b1100011)begin
		// B type
			RegWrite = 0;
			ALUop = 3'b011;
			ALUsrc = 0;
			branchCtrl = 1;  
			PCtoRegSrc = 0;
			RDsrc = 0;
			MRead = 0;
			MWrite = 0;  
			MenToReg = 0; // don't care
			ImmType = 3'b011; 
		end else if(op==7'b0010111)begin
		// U-1 type AUIPC
		   	RegWrite = 1;
			ALUop = 3'b100;
			ALUsrc = 1; // don't care
			branchCtrl = 0; // don't care
			PCtoRegSrc = 0;  
			RDsrc = 0; 
			MRead = 0;
			MWrite = 0;  
			MenToReg = 0;  
			ImmType = 3'b000; 
		end else if(op==7'b0110111)begin
		// U-2 type LUI
		    	RegWrite = 1;
			ALUop = 3'b100;
			ALUsrc = 1;  
			branchCtrl = 0; // don't care
			PCtoRegSrc = 0; // don't care
			RDsrc = 1; 
			MRead = 0;
			MWrite = 0;  
			MenToReg = 0;  
			ImmType = 3'b000; 
		end else if(op==7'b1101111)begin 
		// J type
		    	RegWrite = 1;
			ALUop = 3'b101;
			ALUsrc = 1; // don't care
			branchCtrl = 2;
			PCtoRegSrc = 1;
			RDsrc = 0;
			MRead = 0;
			MWrite = 0;  
			MenToReg = 0;  
			ImmType = 3'b100; 
		end else begin
		// I type
			if(op==7'b0000011)begin
		    		RegWrite = 1;
				ALUop = 3'b001;
				ALUsrc = 1; 
				branchCtrl = 0; // don't care
				PCtoRegSrc = 0; // don't care
				RDsrc = 1; 
				MRead = 1;
				MWrite = 0;  
				MenToReg = 1;  
				ImmType = 3'b001; 
			end else if(op==7'b0010011)begin
		    		RegWrite = 1;
				ALUop = 3'b110;
				ALUsrc = 1; 
				branchCtrl = 0; // don't care
				PCtoRegSrc = 0; // don't care
				RDsrc = 1; 
				MRead = 0;
				MWrite = 0;  
				MenToReg = 0;  
				ImmType = 3'b001; 
			end else begin
		    		RegWrite = 1;
				ALUop = 3'b111;
				ALUsrc = 1; 
				branchCtrl = 3; 
				PCtoRegSrc = 1; 
				RDsrc = 0; 
				MRead = 0;
				MWrite = 0;  
				MenToReg = 0;  
				ImmType = 3'b001; 
			end
		end

	end

endmodule
