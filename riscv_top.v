module riscv_top (
    input clk, rst,
    output [31:0] pc_out, pc_next,
    output [31:0] instr_out, alu_out,
    output [31:0] reg1_out, reg2_out, imm_out,
    output [6:0] opcode_out,
    output [4:0] rs1_out, rs2_out, rd_out,
    output RegWrite, ALUSrc, MemRead, MemWrite, MemToReg, Branch,
    output Zero,
    output [31:0] read_data_mem
);
    // Internal wires
    wire [31:0] pc, instr, reg1, reg2, imm, alu_result;
    wire [31:0] alu_b, writeback_data;
    wire [6:0] opcode;
    wire [4:0] rs1, rs2, rd;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire reg_write, alusrc, mem_read, mem_write, memtoreg, branch;
    wire zero_flag;
    wire take_branch;
    wire [31:0] pc_plus4, pc_branch;
    wire [31:0] data_mem_read;
    
    // ==== FETCH ====
    pc_module PC(.clk(clk), .rst(rst), .pc_next(pc_next), .pc(pc));
    instr_mem IMEM(.addr(pc), .instr(instr));
    
    // ==== DECODE ====
    decoder DEC(.instr(instr), .opcode(opcode), .rs1(rs1), .rs2(rs2), .rd(rd),
                .funct3(funct3), .funct7(funct7));
    
    // ==== CONTROL (NEW!) ====
    control CTRL(.opcode(opcode),
                 .RegWrite(reg_write), .ALUSrc(alusrc),
                 .MemRead(mem_read), .MemWrite(mem_write),
                 .MemToReg(memtoreg), .Branch(branch));
    
    // ==== REGISTERS ====
    regfile RF(.clk(clk), .rs1(rs1), .rs2(rs2), .rd(rd),
               .write_data(writeback_data), .reg_write(reg_write),
               .read_data1(reg1), .read_data2(reg2));
    
    // ==== IMMEDIATE ====
    imm_gen IMMG(.instr(instr), .opcode(opcode), .imm(imm));
    
    // ==== ALU ====
    // Correct: BEQ ke liye ALUSrc=0
    assign alu_b = (branch && (opcode == 7'b1100011)) ? reg2 : (alusrc ? imm : reg2);

    wire [3:0] alu_op;
    alu_control ALU_CTRL(.opcode(opcode), .funct3(funct3), .funct7(funct7), .alu_op(alu_op));
    alu ALU_INST(.a(reg1), .b(alu_b), .alu_op(alu_op), .result(alu_result));
    assign zero_flag = (alu_result == 32'd0);

    // Make sure ye lines hain:
    assign pc_plus4 = pc + 32'd4;
    assign pc_branch = pc + imm;      // ← Ye imm use kar raha?
    assign take_branch = branch & zero_flag;
    assign pc_next = take_branch ? pc_branch : pc_plus4;

    
    // ==== DATA MEMORY (NEW!) ====
    data_mem DMEM(.clk(clk),
                  .MemRead(mem_read), .MemWrite(mem_write),
                  .addr(alu_result), .write_data(reg2),
                  .read_data(data_mem_read));
    
    // ==== WRITEBACK ====
    assign writeback_data = memtoreg ? data_mem_read : alu_result;
    
    // ==== BRANCH LOGIC (NEW!) ====
    assign take_branch = branch & zero_flag;  // BEQ: if Zero & Branch
    assign pc_plus4 = pc + 32'd4;
    assign pc_branch = pc + imm;
    assign pc_next = take_branch ? pc_branch : pc_plus4;
    
    // ==== DEBUG OUTPUTS ====
    assign pc_out = pc;
    assign instr_out = instr;
    assign alu_out = alu_result;
    assign reg1_out = reg1;
    assign reg2_out = reg2;
    assign imm_out = imm;
    assign opcode_out = opcode;
    assign rs1_out = rs1;
    assign rs2_out = rs2;
    assign rd_out = rd;
    assign RegWrite = reg_write;
    assign ALUSrc = alusrc;
    assign MemRead = mem_read;
    assign MemWrite = mem_write;
    assign MemToReg = memtoreg;
    assign Branch = branch;
    assign Zero = zero_flag;
    assign read_data_mem = data_mem_read;
endmodule
