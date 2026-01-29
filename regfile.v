module regfile (
    input clk,
    input [4:0] rs1, rs2, rd,
    input [31:0] write_data,
    input reg_write,
    output [31:0] read_data1, read_data2
);
    reg [31:0] registers [31:0];
    
    integer i;
    initial for(i=0; i<32; i=i+1) registers[i] = 0;
    
    // x0 ALWAYS 0 (even if write attempt)
    assign read_data1 = (rs1 == 5'd0) ? 32'd0 : registers[rs1];
    assign read_data2 = (rs2 == 5'd0) ? 32'd0 : registers[rs2];
    
    always @(posedge clk)
        if (reg_write && rd != 5'd0)
            registers[rd] <= write_data;
endmodule
