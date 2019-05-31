`include "Adder.v"
`include "Mux3to1.v"
`include "BranchCtrl.v"
`include "BigALU.v"
`include "ALU_ctrl.v"
`include "Decoder.v"
`include "Mux2to1.v"
`include "ImmGene.v"
`include "PC.v"
`include "RegFile.v"
`include "Shift_check.v"

`include "ForwardUnit.v"
`include "HazardCtrl.v"
`include "EXMEM_reg.v"
`include "IDEX_reg.v"
`include "IFID_reg.v"
`include "MEMWB_reg.v"
`include "Ctrl_mux.v"
`include "cmp_unit.v"


module CPU(
    input         clk,
    input         rst,
    output        instr_read,
    output [31:0] instr_addr,
    input  [31:0] instr_out,
    output        data_read,
    output        data_write,
    output [31:0] data_addr,
    output [31:0] data_in,
    input  [31:0] data_out
);

	reg [31:0]four = 4;
	// basic net
	wire [4:0]rs1;
	wire [4:0]rs2;
	wire [4:0]rd;
	wire [6:0]op;
	wire [2:0]func3;
	wire [6:0]func7;
	// pc net
 	wire [31:0]pcin;
	wire [31:0]pcout;

	// decoder net
	wire RegWrite;
	wire [2:0]ALUop;
	wire ALUsrc;
	wire[1:0]branchCtrl;
	wire PCtoRegSrc;
	wire RDsrc;
	wire MRead;
	wire MWrite;
	wire MenToReg;
	wire [2:0]ImmType;

	// immediate net
	wire [31:0]imm;

	// ALU ctrl net
	wire [3:0]alu_ctrl;

	// Register File net
	wire [31:0]rs1_data;
	wire [31:0]rs2_data;
	wire [31:0]rd_data;

	// big alu net
	wire [31:0] big_alu_in1;
	wire [31:0] big_alu_in2;
	wire [31:0] alu_out;
	wire zero;

	// mux net
	wire [31:0] pc_to_reg;
	wire [31:0] add1_out;
	wire [31:0] add2_out;
	wire [31:0] add3_out;
	wire [31:0] pc_or_alu_out;

	// branch ctrl net
	wire [1:0] BranchCTRL;
	

	// check wire
	wire [31:0] new_rs2;
	wire [31:0] new_imm;

	PC pc_counter(
		.clk(clk),
		.rst(rst),
		.pcin(pcin),
		.pcout(pcout));

	Decoder decoder(
		.op(op),
		.RegWrite(RegWrite),
		.ALUop(ALUop),
		.ALUsrc(ALUsrc),
		.branchCtrl(branchCtrl),
		.PCtoRegSrc(PCtoRegSrc),
		.RDsrc(RDsrc),
		.MRead(MRead),
		.MWrite(MWrite),
		.MenToReg(MenToReg),
		.ImmType(ImmType));
	
	ImmGene imm_gene(
		.immType(ImmType),
		.instr(instr_out),
		.immOut(imm));

	ALU_ctrl ALUctrl(
		.func3(func3),
		.func7(func7),
		.alu_op(ALUop),
		.alu_ctrl(alu_ctrl));

	BigALU big_alu(
		.src1(big_alu_in1),
		.src2(big_alu_in2),
		.alu_ctrl(alu_ctrl),
		.zero(zero),
		.alu_out(alu_out));

	Shift_check shfc(
		.rs2_data(rs2_data),
		.imm(imm),
		.alu_src(ALUsrc),
		.op(op),
		.func3(func3),
		.new_rs2(new_rs2),
		.new_imm(new_imm));

	Mux2to1 mux2to1_1(
		.in1(add1_out),
		.in2(add2_out),
		.select(PCtoRegSrc),
		.out(pc_to_reg));

	Mux2to1 mux2to1_2(
		.in1(new_rs2),
		.in2(new_imm),
		.select(ALUsrc),
		.out(big_alu_in2));

	Mux2to1 mux2to1_3(
		.in1(pc_to_reg),
		.in2(alu_out),
		.select(RDsrc),
		.out(pc_or_alu_out));

	Mux2to1 mux2to1_4(
		.in1(pc_or_alu_out),
		.in2(data_out),
		.select(MenToReg),
		.out(rd_data));

	Adder add1(
		.src1(pcout),
		.src2(imm),
		.out(add1_out));

	Adder add2(
		.src1(pcout),
		.src2(four),
		.out(add2_out));

	Adder add3(
		.src1(four),
		.src2(pcout),
		.out(add3_out));

	BranchCtrl b_ctrl( 
		.func3(func3),
		.zero(zero),
		.btype(branchCtrl),
		.alu_out(alu_out),
		.b_ctrl(BranchCTRL));

	Mux3to1 mux3to1(
		.in1(alu_out),
		.in2(add1_out),
		.in3(add3_out),
		.select(BranchCTRL),
		.out(pcin));

	RegFile registerFile(
		.clk(clk),
		.rs1_addr(rs1),
		.rs2_addr(rs2),
		.rd_addr(rd),
		.regWrite(RegWrite),
		.rd_data(rd_data),
		.rs1_data(rs1_data),
		.rs2_data(rs2_data),.op(op),.t(func3),.pc(instr_out));

	assign rs1 = instr_out[19:15];
	assign rs2 = instr_out[24:20];
	assign rd = instr_out[11:7];
	assign op = instr_out[6:0];
	assign func3 = instr_out[14:12];
	assign func7 = instr_out[31:25];
	assign big_alu_in1 = rs1_data;
	assign instr_addr = pcout;
	assign data_read = MRead;
	assign data_write = MWrite;
	assign data_addr = alu_out;
	assign data_in = rs2_data;

	assign instr_read = 1;
	// pipe start
	// IF net begin
		// hazard ctrl net begin
		wire targetPC;
		wire PCWrite;
		wire BranchCTRL;
		wire IFID_regWrite;
		wire hazard_ctrl_flush_instr;
		wire hazard_ctrl_flush_ctrl;
		// hazard ctrl net end
	wire [31:0] pcin;
	wire [31:0] pcout;
	wire [31:0] no_hazard_pcout;
	reg [31:0] four = 4;
	wire BranchCtrl;
	wire [31:0] branch_mux_src1;
	wire [31:0] branch_mux_src2;
	wire [31:0] branch_mux_src3;
	wire instr_out_after_mux;
	// IF net end
	// ID net begin
		// control unit net begin

		// control unit net end
	wire [4:0] ID_rs1;
	wire [4:0] ID_rs2;
	wire [4:0] ID_rd;
	wire [6:0] ID_op;
	wire [2:0] ID_func3;
	wire [6:0] ID_func7;
	wire [31:0] WB_rd_data;
	wire [4:0] WB_rd_addr;
	wire [31:0] ID_pc;
	wire [31:0] ID_rs1_data;
	wire [31:0] ID_rs2_data;
	wire [31:0] ID_imm
	// ID net end

	// connect module begin
	PC pc_counter(
		.clk(clk),
		.rst(rst),
		.PCWrite(PCWrite),
		.pcin(pcin),
		.pcout(pcout));
	//connect module end

	// pipe end
endmodule
