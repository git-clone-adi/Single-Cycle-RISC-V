module alu (
    input  [31:0] a, b,
    input  [3:0] alu_op,
    output reg [31:0] result
);
    always @(*) begin
        case (alu_op)
            4'b0000: result = a + b;      // ADD
            4'b0001: result = a - b;      // SUB (for BEQ)
            default: result = a + b;
        endcase
    end
endmodule
