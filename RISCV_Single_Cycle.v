module RISCV_Single_Cycle (
    input clk, rst_n
);

    wire [31:0] instruction;
    wire [6:0] op;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [4:0] addA, addB, addD;
    wire [31:0] imm_ext;
    wire [31:0] PC_plus4, PC_branch, next_PC, PC_Out;
    wire [31:0] dataA, dataB, A, B;
    wire [3:0] ALUControl;
    wire [31:0] alu_out;
    wire [31:0] read_data;
    wire [31:0] WB_out;
    wire ALUSrc, ALUSrc_pc, MemWrite, MemRead, RegWrite, Branch, branch_taken, Jump;
    wire [1:0] ResultSrc;
    wire [1:0] ALUOp;
    wire [2:0] imm_sel;

    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd  = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];
    assign opcode = instruction[6:0];
	
    PC PC(.clk(clk),
          .rst(rst_n),
          .next_PC(next_PC),
          .PC_Out(PC_Out));
    PCAdder PCAdder(.PC_in(PC_Out),
                    .PC_plus4(PC_plus4));
    NextPCSel NextPCSel(.PC_plus4(PC_plus4), 
                        .PC_branch(alu_out), // Dùng alu_out thay vì BranchAdder
                        .Branch(Branch),
                        .Jump(Jump), // Thêm tín hi?u Jump cho JAL/JALR
                        .branch_taken(branch_taken),
                        .next_PC(next_PC));
    IMEM IMEM_inst(.clk(clk),
              .rst(rst_n),
              .PC_Out(PC_Out), 
              .instruction(instruction));
    ControlUnit ControlUnit (
                            .op(instruction[6:0]),
                            .RegWrite(RegWrite),
                            .ALUSrc(ALUSrc),
                            .MemWrite(MemWrite),
                            .MemRead(MemRead),
                            .ResultSrc(ResultSrc),
                            .Branch(Branch),
                            .Jump(Jump), // Thêm Jump
                            .ALUOp(ALUOp),
                            .imm_sel(imm_sel));
    RegisterFile reg_unit(.clk(clk),
                          .rst(rst_n),
                          .addA(instruction[19:15]),
                          .addB(instruction[24:20]),
                          .addD(instruction[11:7]),
                          .WB_out(WB_out),
                          .RegWrite(RegWrite),
                          .dataA(dataA),
                          .dataB(dataB));
    ImmGen ImmGen(.instruction(instruction),
                  .imm_sel(imm_sel),
                  .imm_ext(imm_ext));
    reg[31:0] Instruction_out_top;
    assign Instruction_out_top = instruction;
    ALUControl ALU_Control(.ALUOp(ALUOp),
                          .funct3(instruction[14:12]),
                          .funct7(instruction[31:25]),
                          .op(instruction[6:0]),
                          .ALUControl(ALUControl));
    ALU ALU(.A(A), // Dùng dataA (rs1) ho?c PC cho JAL/Branch
            .B(B), 
            .ALUControl(ALUControl), 
            .alu_out(alu_out));
    BranchComp BranchComp(.op(instruction[6:0]),
                          .funct3(instruction[14:12]),
                          .rs1_data(dataA), 
                          .rs2_data(dataB),
                          .branch_taken(branch_taken));
   /* DMEM DMEM(.clk(clk),               
              .rst(rst),               
              .MemRead(MemRead),           
              .MemWrite(MemWrite),          
              .address(alu_out[31:2]), // Byte-address to word-address
              .write_data(dataB), 
              .read_data(read_data)); */
    DMEM DMEM_inst(.clk(clk), 
			  .rst(rst_n), 
			  .MemRead(MemRead),
			  .MemWrite(MemWrite),
			  .funct3(instruction[14:12]), 
			  .address(alu_out), 
			  .write_data(dataB),          
			  .read_data(read_data));
    MUX2 muxALU1(.input0(dataA),
               .input1(PC_Out),
               .select(ALUSrc_pc), 
               .out(A));
    MUX2 muxALU2(.input0(dataB),
               .input1(imm_ext),
               .select(ALUSrc), 
               .out(B)); 
    MUX3 muxWB(.input0(alu_out),
              .input1(read_data),
              .input2(PC_plus4),
              .select(ResultSrc),
              .out(WB_out));
endmodule 
