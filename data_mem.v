// data_mem.v
module data_mem (
    input  clk,
    input  MemRead,
    input  MemWrite,
    input  [31:0] addr,
    input  [31:0] write_data,
    output reg [31:0] read_data
);
    reg [31:0] mem [0:63]; // 64 words (256 bytes)

    integer i;
    initial begin
        for (i=0; i<64; i=i+1) mem[i] = 0;
        // Test ke liye: maan lo mem[1] = 32'h0000000A; etc. agar chaho
    end

    wire [5:0] word_addr = addr[7:2];  // word aligned

    // READ: combinational
    always @(*) begin
        if (MemRead)
            read_data = mem[word_addr];
        else
            read_data = 32'd0;
    end

    // WRITE: synchronous
    always @(posedge clk) begin
        if (MemWrite)
            mem[word_addr] <= write_data;
    end
endmodule
