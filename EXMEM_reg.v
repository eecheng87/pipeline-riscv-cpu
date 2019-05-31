module EXMEM_reg(
    input clk,
    input [31:0] PcToReg_in,
    input [31:0] alu_out_in,
    input [31:0] EX_forward_rs2_data_in,
    input [4:0] EX_rd_addr_in,
    input rd_src_in,
    input memRead_in,
    input memWrite_in,
    input memToReg_in,
    input regWrite_in,
    output reg [31:0] PcToReg_out,
    output reg [31:0] alu_out_out,
    output reg [31:0] EX_forward_rs2_data_out,
    output reg [4:0] EX_rd_addr_out,
    output reg rd_src_out,
    output reg memRead_out,
    output reg memWrite_out,
    output reg memToReg_out,
    output reg regWrite_out
);

    always@(posedge clk)begin
        PcToReg_out = PcToReg_in;
        alu_out_out = alu_out_in;
        EX_forward_rs2_data_out = EX_forward_rs2_data_in;
        EX_rd_addr_out = EX_rd_addr_in;
        rd_src_out = rd_src_in;
        memRead_out = memRead_in;
        memWrite_out = memWrite_in;
        memToReg_out = memToReg_in;
        regWrite_out = regWrite_in;
    end

endmodule