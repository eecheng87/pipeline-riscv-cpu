module MEMWB_reg(
    input clk,
    input [31:0] mem_rd_data_in,
    input [31:0] data_in,
    input [4:0] mem_rd_addr_in,
    input memToReg_in,
    input regWrite_in,
    output reg [31:0] mem_rd_data_out,
    output reg [31:0] data_out,
    output reg [4:0] mem_rd_addr_out,
    output reg memToReg_out,
    output reg regWrite_out,
);
    
    always@(posedge clk)begin
        mem_rd_data_out = mem_rd_data_in;
        data_out = data_out;
        mem_rd_addr_out = mem_rd_addr_in;
        memToReg_out = memToReg_in;
        regWrite_out = regWrite_in;
    end

endmodule