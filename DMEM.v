module DMEM (
    input clk, rst, MemRead, MemWrite,
    input [2:0] funct3, 
    input [31:0] address, write_data,
    output reg [31:0] read_data
);
    reg [31:0] memory [0:1023]; // 256 word = 1024 byte
    always_ff @(posedge clk) begin
        if (mem_write)
            memory[address >> 2] <= write_data;  
    end

    assign read_data = memory[address >> 2];   
endmodule
endmodule
