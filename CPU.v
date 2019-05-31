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

	reg [31:0] four = 4;
	reg [31:0] zero = 0;
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
	reg [31:0] zero = 0;
	wire BranchCtrl;
	wire [31:0] branch_mux_src1;
	wire [31:0] branch_mux_src2;
	wire [31:0] branch_mux_src3;
	wire [31:0] instr_out_after_mux;
	// IF net end
	// ID net begin
		// control unit net begin
		wire ID_RegWrite;
		wire [2:0]ID_ALUop;
		wire ID_ALUsrc;
		wire [1:0] ID_branchCtrl;
		wire ID_PCtoRegSrc;
		wire ID_RDsrc;
		wire ID_MRead;
		wire ID_MWrite;
		wire ID_MenToReg;
		wire [2:0] ID_ImmType;
		// control unit net end
	wire [31:0] ID_instr_out;
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
	wire [31:0] ID_imm;
	wire [31:0] ID_imm_after_shift_check;
	wire [31:0] ID_rs2_after_shift_check;
	wire [31:0] ID_rs1_after_cmp_unit;
	wire [31:0] ID_rs2_after_cmp_unit;
	wire [31:0] ID_pre_next_pc_adder;
	wire takeBranch;
	// ID net end
	// EX net begin
		// control net begin
		wire EX_RegWrite;
		wire [2:0] EX_ALUop;
		wire EX_ALUsrc;
		wire [1:0] EX_branchCtrl;
		wire EX_PCtoRegSrc;
		wire EX_RDsrc;
		wire EX_MRead;
		wire EX_MWrite;
		wire EX_MenToReg;
		wire [2:0] EX_ImmType;
		// control net end
		// forward unit net begin
		wire forward_rs1_src;
		wire forward_rs2_src;
		// forward unit net end
		// ALU ctrl net begin
		wire [3:0] EX_alu_ctrl;
		// ALU ctrl net end
	wire EX_RegWrite_after_mux;
	wire [2:0] EX_ALUop_after_mux;
	wire EX_ALUsrc_after_mux;
	wire [1:0] EX_branchCtrl_after_mux;
	wire EX_PCtoRegSrc_after_mux;
	wire EX_RDsrc_after_mux;
	wire EX_MRead_after_mux;
	wire EX_MWrite_after_mux;
	wire EX_MenToReg_after_mux;
	wire [31:0] EX_pc;
	wire [31:0] EX_rs1_data;
	wire [31:0] EX_rs2_data;
	wire [31:0] EX_imm;
	wire [2:0] EX_func3;
	wire [6:0] EX_func7;
	wire [4:0] EX_rd_addr;
	wire [4:0] EX_rs1_addr;
	wire [4:0] EX_rs2_addr;
	wire [31:0] WB_rd_data;
	wire [31:0] MEM_rd_data;
	wire [31:0] EX_imm;
	wire [31:0] EX_pc_to_reg;
	wire [31:0] EX_alu_out;
		// mux and adder net begin
		wire [31:0] EX_adder1_out;
		wire [31:0] EX_adder2_out;
		wire [31:0] EX_mux1_out;
		wire [31:0] EX_mux2_out;
		wire [31:0] EX_mux3_out;
		wire [31:0] EX_mux4_out;
		// mux and adder net end
	wire EX_zero_flag;
	// EX net end
	// MEM net begin
		// control net begin
		wire MEM_RDsrc;
		wire MEM_memRead;
		wire MEM_memWrite;
		// control net end
		// forward unit begin
		wire forward_rd_src;
		// forward unit end
	wire [31:0] MEM_forward_rs2_data;
	wire [31:0] MEM_alu_out;
	wire [31:0] MEM_pc_to_reg;
	wire [31:0] MEM_rd_data;
	wire [4:0] MEM_rd_addr;
	// MEM net end
	// WB net begin
	wire [31:0] WB_rd_data;
	wire [31:0] WB_data_out;
	wire [31:0] WB_mux_out;
	wire WB_MenToReg;
	wire WB_regWrite;
	// WB net end

	// connect module begin
	// IF begin
	PC pc_counter(
		.clk(clk),
		.rst(rst),
		.PCWrite(PCWrite),
		.pcin(pcin),
		.pcout(pcout)
	);

	Mux2to1 pre_pc_mux(
		.in1(no_hazard_pcout),
		.in2(ID_pre_next_pc_adder),
		.select(targetPC),
		.out(pcin)
	);

	Mux2to1 IF_instr_mux(
		.in1(instr_out),
		.in2(zero),
		.select(hazard_ctrl_flush_instr),
		.out(instr_out_after_mux)
	);

	Adder IF_adder(
		.src1(four),
		.src2(pcout),
		.out(branch_mux_src3)
	);

	HazardCtrl hazard_control(
    	.op(ID_op),
    	.IDEX_rt(EX_rd_addr),
    	.IFID_rs(ID_rs1),
    	.IFID_rt(ID_rs2),
    	.IDEX_memRead(EX_MRead),
    	.takeBranch(takeBranch),
    	.PCWrite(PCWrite),
    	.IFID_reg_write(IFID_regWrite),
    	.instr_flush(hazard_ctrl_flush_instr),
    	.ctrl_flush(hazard_ctrl_flush_ctrl),
    	.targetPC(targetPC)
	);

	IFID_reg IFIFreg(
    	.clk(clk),
    	.IFID_RegWrite(IFID_regWrite),
    	.pc_in(pcout),
    	.instr_in(instr_out_after_mux),
    	.pc_out(ID_pc),
    	.instr_out(ID_instr_out)
	);
	// IF end

	// ID begin
	assign ID_rs1 = ID_instr_out[19:15];
	assign ID_rs2 = ID_instr_out[24:20];
	assign ID_rd = ID_instr_out[11:7];
	assign ID_op = ID_instr_out[6:0];
	assign ID_func3 = ID_instr_out[14:12];
	assign ID_func7 = ID_instr_out[31:25];

	ImmGene imm_gene(
		.immType(ID_ImmType),
		.instr(ID_instr_out),
		.immOut(ID_imm)
	);

	Shift_check shfc(
		.rs2_data(ID_rs2_data),
		.imm(ID_imm),
		.alu_src(ID_ALUsrc),
		.op(ID_op),
		.func3(ID_func3),
		.new_rs2(ID_rs2_after_shift_check),
		.new_imm(ID_imm_after_shift_check)
	);

	cmp_unit cmpunit(
    	.src1(ID_rs1_data),
    	.src2(ID_rs2_after_shift_check),
    	.op(ID_op),
    	.func3(ID_func3),
    	.src1_out(ID_rs1_after_cmp_unit),
    	.src2_out(ID_rs2_after_cmp_unit),
    	.takeBranch(takeBranch)
	);

	Decoder controlunit(
		.op(ID_op),
		.RegWrite(ID_RegWrite),
		.ALUop(ID_ALUop),
		.ALUsrc(ID_ALUsrc),
		.branchCtrl(ID_branchCtrl),
		.PCtoRegSrc(ID_PCtoRegSrc),
		.RDsrc(ID_RDsrc),
		.MRead(ID_MRead),
		.MWrite(ID_MWrite),
		.MenToReg(ID_MenToReg),
		.ImmType(ID_ImmType)
	);
		
	Ctrl_mux ctrl_mux(
    	.flush(hazard_ctrl_flush_ctrl),
    	.PCtoRegSrc_in(EX_PCtoRegSrc),
    	.branchCtrl_in(EX_branchCtrl),
    	.aluop_in(EX_ALUop),
    	.alusrc_in(EX_ALUsrc),
    	.regWrite_in(EX_RegWrite),
    	.rdsrc_in(EX_RDsrc),
    	.memRead_in(EX_MRead),
    	.memWrite_in(EX_MWrite),
    	.memToReg_in(EX_MenToReg),
    	.PCtoRegSrc_out(EX_PCtoRegSrc_after_mux),
    	.branchCtrl_out(EX_branchCtrl_after_mux),
    	.aluop_out(EX_ALUop_after_mux),
    	.alusrc_out(EX_ALUsrc_after_mux),
    	.regWrite_out(EX_RegWrite_after_mux),
    	.rdsrc_out(EX_RDsrc_after_mux),
    	.memRead_out(EX_MRead_after_mux),
    	.memWrite_out(EX_MWrite_after_mux),
    	.memToReg_out(EX_MenToReg_after_mux)
	);
	
	RegFile registerFile(
		.clk(clk),
		.rs1_addr(ID_rs1),
		.rs2_addr(ID_rs2),
		.rd_addr(WB_rd_addr),
		.regWrite(WB_regWrite),
		.rd_data(WB_rd_data),
		.rs1_data(ID_rs1_data),
		.rs2_data(ID_rs2_data),
		.op(ID_op),
		.pc(ID_pc)
	);
	// ID end

	//connect module end

	// pipe end
endmodule
