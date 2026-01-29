// instr_mem.v (UPDATED - correct BEQ encoding)
module instr_mem(input [31:0] addr, output reg [31:0] instr);
    reg [31:0] rom[0:15];
    
    initial begin
        rom[0] = 32'h00500093;  // ADDI x1,x0,5
        rom[1] = 32'h00500113;  // ADDI x2,x0,5
        rom[2] = 32'h00208463;  // BEQ x1,x2,+8  (CORRECTED!)
        rom[3] = 32'h00100193;  // ADDI x3,x0,1 (skip if branch)
        rom[4] = 32'h00900193;  // ADDI x3,x0,9 (branch target)
        rom[5] = 32'h00000000;  // NOP
    end
    
    always @(*) instr = rom[addr[31:2]];
endmodule
