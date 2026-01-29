`timescale 1ns/1ps

module tb_riscv;
    reg clk=0, rst=1;
    
    // Outputs from top
    wire [31:0] pc_out, pc_next;
    wire [31:0] instr_out, alu_out;
    wire [31:0] reg1_out, reg2_out, imm_out;
    wire [6:0] opcode_out;
    wire [4:0] rs1_out, rs2_out, rd_out;
    wire RegWrite, ALUSrc, MemRead, MemWrite, MemToReg, Branch;
    wire Zero;
    wire [31:0] read_data_mem;
    
    // Instantiate top
    riscv_top DUT(
        .clk(clk), .rst(rst),
        .pc_out(pc_out), .pc_next(pc_next),
        .instr_out(instr_out), .alu_out(alu_out),
        .reg1_out(reg1_out), .reg2_out(reg2_out), .imm_out(imm_out),
        .opcode_out(opcode_out),
        .rs1_out(rs1_out), .rs2_out(rs2_out), .rd_out(rd_out),
        .RegWrite(RegWrite), .ALUSrc(ALUSrc),
        .MemRead(MemRead), .MemWrite(MemWrite),
        .MemToReg(MemToReg), .Branch(Branch),
        .Zero(Zero),
        .read_data_mem(read_data_mem)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    // VCD dump
    initial begin
        $dumpfile("riscv_day3.vcd");
        $dumpvars(0, tb_riscv);
    end
    
    // Test sequence
    initial begin
        $display("╔════════════════════════════════════════╗");
        $display("║ DAY 3: CONTROL + BRANCH TEST ║");
        $display("║ Expect: x1=5, x2=5, x3=9 (NOT 1)  ║");
        $display("╚════════════════════════════════════════╝");
        
        #20 rst = 0;  // Release reset
        
        // Run 30 cycles
        repeat(30) @(posedge clk);
        
        $display("\n╔════════════════════════════════════════╗");
        $display("║ TEST COMPLETE - Check GTKWave ║");
        $display("╚════════════════════════════════════════╝");
        $finish;
    end
    
    // MONITOR: Print every cycle
    always @(posedge clk) begin
        if (!rst) begin
            $display("t=%0t | PC=0x%02h | opcode=%2d | instr=0x%h | ALU=0x%h | Zero=%b | Branch=%b | RegWr=%b",
                     $time, pc_out[7:0], opcode_out, instr_out, alu_out, Zero, Branch, RegWrite);
        end
    end
    
    // SPECIAL: Print x1, x2, x3 register values
    always @(posedge clk) begin
        if (!rst && pc_out >= 32'h8) begin  // After BEQ
            $display("  → x1=%d, x2=%d, x3=%d, RegWrite=%b, rd=%d",
                     DUT.RF.registers[1], DUT.RF.registers[2], DUT.RF.registers[3],
                     RegWrite, rd_out);
        end
    end

    always @(posedge clk) begin
        if (!rst && Branch)
            $display("BEQ: pc=0x%h imm=0x%h pc_branch=0x%h",
                    pc_out, imm_out, pc_out + imm_out);
    end

endmodule
