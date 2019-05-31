module IFID_reg(
    input clk,
    input IFID_RegWrite,
    input [31:0] pc_in,
    input [31:0] instr_in,
    output reg[31:0] pc_out,
    output reg[31:0] instr_out
);
    
    always@(posedge clk)begin
        if(IFID_RegWrite)begin
            pc_out = pc_in;
            instr_out = instr_in;
        end
    end

endmodule