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

	assign instr_read = 1;
	assign instr_addr = pcout;
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
	wire ID_RegWrite_after_mux;
	wire [2:0] ID_ALUop_after_mux;
	wire ID_ALUsrc_after_mux;
	wire [1:0] ID_branchCtrl_after_mux;
	wire ID_PCtoRegSrc_after_mux;
	wire ID_RDsrc_after_mux;
	wire ID_MRead_after_mux;
	wire ID_MWrite_after_mux;
	wire ID_MenToReg_after_mux;
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
		// ALU net begin
		wire EX_zero;
		// ALU net end
	wire [31:0] EX_pc;
	wire [31:0] EX_rs1_data;
	wire [31:0] EX_rs2_data;
	wire [31:0] EX_imm;
	wire [2:0] EX_func3;
	wire [6:0] EX_func7;
	wire [4:0] EX_rd_addr;
	wire [4:0] EX_rs1_addr;
	wire [4:0] EX_rs2_addr;
	//wire [31:0] WB_rd_data;
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
	// EX net end
	// MEM net begin
		// control net begin
		wire MEM_RDsrc;
		wire MEM_memRead;
		wire MEM_memWrite;
		wire MEM_regWrite;
		wire MEM_mem_to_reg;
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
	//wire [31:0] WB_rd_data;
	wire [31:0] WB_rd_data_pre_mux;
	wire [31:0] WB_data_out;
	wire [31:0] WB_mux_out;
	wire WB_MenToReg;
	wire WB_regWrite;
	// WB net end

	// connect module begin
	// IF begin
	assign branch_mux_src1 = EX_alu_out;
	assign branch_mux_src2 = EX_adder1_out;
	Mux3to1 pc_mux3to1(
		.in1(branch_mux_src1),
		.in2(branch_mux_src2),
		.in3(branch_mux_src3),
		.select(BranchCTRL),
		.out(no_hazard_pcout)
	);

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

	Adder EX_hazard_adder(
		.src1(ID_pc),
		.src2(ID_imm),
		.out(ID_pre_next_pc_adder)
	);

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
    	.PCtoRegSrc_in(ID_PCtoRegSrc),
    	.branchCtrl_in(ID_branchCtrl),
    	.aluop_in(ID_ALUop),
    	.alusrc_in(ID_ALUsrc),
    	.regWrite_in(ID_RegWrite),
    	.rdsrc_in(ID_RDsrc),
    	.memRead_in(ID_MRead),
    	.memWrite_in(ID_MWrite),
    	.memToReg_in(ID_MenToReg),
    	.PCtoRegSrc_out(ID_PCtoRegSrc_after_mux),
    	.branchCtrl_out(ID_branchCtrl_after_mux),
    	.aluop_out(ID_ALUop_after_mux),
    	.alusrc_out(ID_ALUsrc_after_mux),
    	.regWrite_out(ID_RegWrite_after_mux),
    	.rdsrc_out(ID_RDsrc_after_mux),
    	.memRead_out(ID_MRead_after_mux),
    	.memWrite_out(ID_MWrite_after_mux),
    	.memToReg_out(ID_MenToReg_after_mux)
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


	IDEX_reg IDEXreg(
    	.clk(clk),
    	.rs1_data_in(ID_rs1_after_cmp_unit),
    	.rs2_data_in(ID_rs2_after_cmp_unit),
    	.imm_in(ID_imm_after_shift_check),
    	.func3_in(ID_func3),
    	.func7_in(ID_func7),
    	.rd_addr_in(ID_rd),
    	.rs1_addr_in(ID_rs1),
    	.rs2_addr_in(ID_rs2),
    	.ID_pc_in(ID_pc),
    	.PCtoRegSrc_in(ID_PCtoRegSrc),
    	.branchCtrl_in(ID_branchCtrl),
    	.aluop_in(ID_ALUop),
    	.alusrc_in(ID_ALUsrc),
    	.regWrite_in(ID_RegWrite),
    	.rdsrc_in(ID_RDsrc),
    	.memRead_in(ID_MRead),
    	.memWrite_in(ID_MWrite),
    	.memToReg_in(ID_MenToReg),
    	.PCtoRegSrc_out(EX_PCtoRegSrc),
    	.branchCtrl_out(EX_branchCtrl),
    	.aluop_out(EX_ALUop),
    	.alusrc_out(EX_ALUsrc),
    	.regWrite_out(EX_RegWrite),
    	.rdsrc_out(EX_RDsrc),
		.memRead_out(EX_MRead),
    	.memWrite_out(EX_MWrite),
   		.memToReg_out(EX_MenToReg),
    	.rs1_data_out(EX_rs1_data),
    	.rs2_data_out(EX_rs2_data),
    	.imm_out(EX_imm),
    	.func3_out(EX_func3),
    	.func7_out(EX_func7),
    	.rd_addr_out(EX_rd_addr),
    	.rs1_addr_out(EX_rs1_addr),
    	.rs2_addr_out(EX_rs2_addr),
    	.ID_pc_out(EX_pc),
	);

	// ID end
	 
	// EX begin

	ForwardUnit frdunit(
    	.ex_rs1_addr(EX_rs1_addr),
    	.ex_rs2_addr(EX_rs2_addr),
    	.EX_MEM_regWrite(MEM_regWrite),
    	.MEM_WB_regWrite(WB_regWrite),
    	.EX_MEM_rd(MEM_rd_addr),
    	.MEM_WB_rd(WB_rd_addr),
    	.forwardRdSrc(forward_rd_src),
    	.forwardRs1Src(forward_rs1_src),
    	.forwardRs2Src(forward_rs2_src) 
	);
	BranchCtrl b_ctrl( 
		.func3(EX_func3),
		.zero(EX_zero),
		.btype(EX_branchCtrl),
		.alu_out(EX_alu_out),
		.b_ctrl(BranchCTRL)
	);

	BigALU big_alu(
		.src1(EX_mux2_out),
		.src2(EX_mux4_out),
		.alu_ctrl(EX_alu_ctrl),
		.zero(EX_zero),
		.alu_out(EX_alu_out)
	);

	ALU_ctrl ALUctrl(
		.func3(EX_func3),
		.func7(EX_func7),
		.alu_op(EX_ALUop),
		.alu_ctrl(EX_alu_ctrl)
	);

	Adder add1(
		.src1(EX_pc),
		.src2(EX_imm),
		.out(EX_adder1_out)
	);

	Adder add2(
		.src1(EX_pc),
		.src2(four),
		.out(EX_adder2_out)
	);

	Mux2to1 ex_mux1(
		.in1(EX_adder1_out),
		.in2(EX_adder2_out),
		.select(EX_PCtoRegSrc),
		.out(EX_mux1_out)
	);

	Mux2to1 ex_mux4(
		.in1(EX_mux3_out),
		.in2(EX_imm),
		.select(EX_ALUsrc),
		.out(EX_mux4_out)
	);
 
	Mux3to1 ex_mux2(
		.in1(EX_rs1_data),
		.in2(MEM_rd_data),
		.in3(WB_rd_data),
		.select(forward_rs1_src),
		.out(EX_mux2_out)
	);

	Mux3to1 ex_mux3(
		.in1(EX_rs2_data),
		.in2(MEM_rd_data),
		.in3(WB_rd_data),
		.select(forward_rs1_src),
		.out(EX_mux3_out)
	);


	assign EX_pc_to_reg = EX_mux1_out;
	EXMEM_reg EXMEMreg(
    	.clk(clk),
    	.PcToReg_in(EX_pc_to_reg),
    	.alu_out_in(EX_alu_out),
    	.EX_forward_rs2_data_in(EX_mux3_out),
    	.EX_rd_addr_in(EX_rd_addr),
    	.rd_src_in(EX_RDsrc),
    	.memRead_in(EX_MRead),
    	.memWrite_in(EX_MWrite),
    	.memToReg_in(EX_MenToReg),
    	.regWrite_in(EX_RegWrite),
    	.PcToReg_out(MEM_pc_to_reg),
    	.alu_out_out(MEM_alu_out),
    	.EX_forward_rs2_data_out(MEM_forward_rs2_data),
   		.EX_rd_addr_out(MEM_rd_addr),
   		.rd_src_out(MEM_RDsrc),
    	.memRead_out(MEM_memRead),
    	.memWrite_out(MEM_memWrite),
    	.memToReg_out(MEM_mem_to_reg),
    	.regWrite_out(MEM_regWrite)
	);
 
	// EX end

	// MEM begin
	assign data_addr = MEM_alu_out;
	assign data_read = MEM_memRead;
	assign data_write = MEM_memWrite;

	Mux2to1 mem_mux5(
		.in1(MEM_pc_to_reg),
		.in2(MEM_alu_out),
		.select(MEM_RDsrc),
		.out(MEM_rd_data)
	);	

	Mux2to1 mem_mux6(
		.in1(MEM_forward_rs2_data),
		.in2(WB_rd_data),
		.select(forward_rd_src),
		.out(data_in)
	);	

	MEMWB_reg MEMWBreg(
    	.clk(clk),
    	.mem_rd_data_in(MEM_rd_data),
    	.data_in(data_out),
    	.mem_rd_addr_in(MEM_rd_addr),
    	.memToReg_in(MEM_mem_to_reg),
    	.regWrite_in(MEM_regWrite),
    	.mem_rd_data_out(WB_rd_data_pre_mux),
    	.data_out(WB_data_out),
    	.mem_rd_addr_out(WB_rd_addr),
    	.memToReg_out(WB_MenToReg),
   		.regWrite_out(WB_regWrite)
	);

	// MEM end
	// WB begin
	Mux2to1 wb_mux7(
		.in1(WB_rd_data_pre_mux),
		.in2(WB_data_out),
		.select(WB_MenToReg),
		.out(WB_rd_data)
	);	
	// WB end
	//connect module end

	// pipe end
endmodule
