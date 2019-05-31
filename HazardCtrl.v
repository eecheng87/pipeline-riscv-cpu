module HazardCtrl(
    input [6:0] op,
    input [4:0] IDEX_rt,
    input [4:0] IFID_rs,
    input [4:0] IFID_rt,
    input IDEX_memRead,
    input takeBranch,
    output reg PCWrite,
    output reg IFID_reg_write,
    output reg instr_flush,
    output reg ctrl_flush,
    output reg targetPC
);

    always@*begin
        // load use hazard
        if(op==7'b0000011&&IDEX_memRead==1&&(IDEX_rt==IFID_rs||IDEX_rt==IFID_rt))begin
            // stall the pipeline
            ctrl_flush = 1;
            instr_flush = 1;
            IFID_reg_write = 0;
            PCWrite = 0;
            targetPC = 0;
        end else if(takeBranch==1&&(op==7'b1100011||op==7'b1101111))begin
            // branch hazard
            // JAL hazard
            targetPC = 1;
            IFID_reg_write = 0;
            ctrl_flush = 1;
            instr_flush = 1;
            PCWrite = 1;
        end begin
            // no hazard
            ctrl_flush = 0;
            instr_flush = 0;
            IFID_reg_write = 1;
            PCWrite = 1;
            targetPC = 0;
        end

    end

endmodule