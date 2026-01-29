// control.v
module control (
    input  [6:0] opcode,
    output reg   RegWrite,
    output reg   ALUSrc,
    output reg   MemRead,
    output reg   MemWrite,
    output reg   MemToReg,
    output reg   Branch
);
    always @(*) begin
        // Default sab 0
        RegWrite = 0;
        ALUSrc   = 0;
        MemRead  = 0;
        MemWrite = 0;
        MemToReg = 0;
        Branch   = 0;

        case (opcode)
            7'b0110011: begin // R-type: ADD,SUB,AND,OR,SLT
                RegWrite = 1;
                ALUSrc   = 0;
            end

            7'b0010011: begin // I-type: ADDI
                RegWrite = 1;
                ALUSrc   = 1;
            end

            7'b0000011: begin // LW
                RegWrite = 1;
                ALUSrc   = 1;
                MemRead  = 1;
                MemToReg = 1;
            end

            7'b0100011: begin // SW
                RegWrite = 0;
                ALUSrc   = 1;
                MemWrite = 1;
            end

            7'b1100011: begin // BEQ
                RegWrite = 0;
                ALUSrc   = 0;
                Branch   = 1;
            end

            default: begin
                // NOP / unknown → sab 0 hi rahne do
            end
        endcase
    end
endmodule
