module IDEX_reg(
    input clk,
    input[31:0] rs1_data_in,
    input[31:0] rs2_data_in,
    input[31:0] imm_in,
    input[2:0] func3_in,
    input[6:0] func7_in,
    input[4:0] rd_addr_in,
    input[4:0] rs1_addr_in,
    input[4:0] rs2_addr_in,
    input[31:0] ID_pc_in,
    input PCtoRegSrc_in,
    input branchCtrl_in,
    input aluop_in,
    input alusrc_in,
    input regWrite_in,
    input rdsrc_in,
    input memRead_in,
    input memWrite_in,
    input memToReg_in,
    output reg PCtoRegSrc_out,
    output reg branchCtrl_out,
    output reg aluop_out,
    output reg alusrc_out,
    output reg regWrite_out,
    output reg rdsrc_out,
    output reg memRead_out,
    output reg memWrite_out,
    output reg memToReg_out,
    output reg [31:0] rs1_data_out,
    output reg [31:0] rs2_data_out,
    output reg [31:0] imm_out,
    output reg [2:0] func3_out,
    output reg [6:0] func7_out,
    output reg [4:0] rd_addr_out,
    output reg [4:0] rs1_addr_out,
    output reg [4:0] rs2_addr_out,
    output reg [31:0] ID_pc_out,
);
    always@(posedge clk)begin
        rs1_data_out = rs1_data_in;
        rs2_data_out = rs2_data_in;
        imm_out = imm_in;
        func3_out = func3_in;
        func7_out = func7_in;
        rd_addr_out = rd_addr_in;
        rs1_addr_out = rs1_addr_in;
        rs2_addr_out = rs2_addr_in;
        ID_pc_out = ID_pc_in;
        PCtoRegSrc_out = PCtoRegSrc_in;
        branchCtrl_out = branchCtrl_in;
        aluop_out = aluop_in;
        alusrc_out = alusrc_in;
        regWrite_out = regWrite_in;
        rdsrc_out = rdsrc_in;
        memRead_out = memRead_in;
        memWrite_out = memWrite_in;
        memToReg_out = memToReg_in;
    end
endmodule