module cmp_unit(
    input [31:0] src1,
    input [31:0] src2,
    input [6:0] op,
    input [2:0] func3,
    output reg [31:0] src1_out,
    output reg [31:0] src2_out,
    output reg takeBranch
);
    always@*begin
        if(op == 7'b1100011)begin
            case(func3)
                3'b000:
                    begin
                        src1_out = src1;
                        src2_out = src2;
                        takeBranch = src1==src2?1:0;
                    end
                3'b001:
                    begin
                        src1_out = src1;
                        src2_out = src2;
                        takeBranch = src1!=src2?1:0;
                    end
                3'b100:
                    begin
                        src1_out = src1;
                        src2_out = src2;
                        takeBranch = $signed(src1)<$signed(src2)?1:0;
                    end
                3'b101:
                    begin
                        src1_out = src1;
                        src2_out = src2;
                        takeBranch = $signed(src1)<$signed(src2)?0:1;
                    end
                3'b110:
                    begin
                        src1_out = src1;
                        src2_out = src2;
                        takeBranch = $unsigned(src1)<$unsigned(src2)?1:0;
                    end
                3'b111:
                    begin
                        src1_out = src1;
                        src2_out = src2;
                        takeBranch = $unsigned(src1)<$unsigned(src2)?0:1;
                    end
                default:
                    begin
                        src1_out = src1;
                        src2_out = src2;
                        takeBranch = 0;
                    end
            endcase
        end
        else begin
            src1_out = src1;
            src2_out = src2;
            takeBranch = 0;
        end
    end

endmodule