module alu_control (
    input  [6:0] opcode,
    input  [2:0] funct3,
    input  [6:0] funct7,
    output reg [3:0] alu_op
);
    always @(*) begin
        case (opcode)
            7'b0110011: alu_op = 4'b0000;  // ADD (default)
            7'b0010011: alu_op = 4'b0000;  // ADDI
            7'b0000011: alu_op = 4'b0000;  // LW
            7'b0100011: alu_op = 4'b0000;  // SW
            7'b1100011: alu_op = 4'b0001;  // BEQ → SUB!
            default:    alu_op = 4'b0000;
        endcase
    end
endmodule
