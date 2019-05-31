module ForwardUnit(
    input [4:0] ex_rs1_addr,
    input [4:0] ex_rs2_addr,
    input EX_MEM_regWrite,
    input MEM_WB_regWrite,
    input [4:0] EX_MEM_rd,
    input [4:0] MEM_WB_rd,
    output reg forwardRdSrc,
    output reg [1:0] forwardRs1Src,
    output reg [1:0] forwardRs2Src 
);

    always@*begin

        // EX hazard
        if((EX_MEM_regWrite==1)&&(EX_MEM_rd!=0)&&(EX_MEM_rd==ex_rs1_addr))
            forwardRs1Src = 2'b01;
        if((EX_MEM_regWrite==1)&&(EX_MEM_rd!=0)&&(EX_MEM_rd==ex_rs2_addr))
            forwardRs2Src = 2'b01;

        // MEM hazard
        if((MEM_WB_regWrite)&&(MEM_WB_rd!=0)&&!((EX_MEM_regWrite==1)&&(EX_MEM_rd!=0)&&(EX_MEM_rd==ex_rs1_addr))&&(MEM_WB_rd==ex_rs1_addr))
            forwardRs1Src = 2'b10;
        if((MEM_WB_regWrite)&&(MEM_WB_rd!=0)&&!((EX_MEM_regWrite==1)&&(EX_MEM_rd!=0)&&(EX_MEM_rd==ex_rs2_addr))&&(MEM_WB_rd==ex_rs2_addr))
            forwardRs2Src = 2'b10;
    end
endmodule