module Ctrl_mux(
    input flush,
    input PCtoRegSrc_in,
    input branchCtrl_in,
    input aluop_in,
    input alusrc_in,
    input regWrite_in,
    input rdsrc_in,
    input memRead_in,
    input memWrite_in,
    input memToReg_in,
    output PCtoRegSrc_out,
    output branchCtrl_out,
    output aluop_out,
    output alusrc_out,
    output regWrite_out,
    output rdsrc_out,
    output memRead_out,
    output memWrite_out,
    output memToReg_out
);
    assign PCtoRegSrc_out = flush?0:PCtoRegSrc_in;
    assign branchCtrl_out = flush?0:branchCtrl_in;
    assign aluop_out = flush?0:aluop_in;
    assign alusrc_out = flush?0:alusrc_in;
    assign regWrite_out = flush?0:regWrite_in;
    assign rdsrc_out = flush?0:rdsrc_in;
    assign memRead_out = flush?0:memRead_in;
    assign memWrite_out = flush?0:memWrite_in;
    assign memToReg_out = flush?0:memToReg_in;
endmodule