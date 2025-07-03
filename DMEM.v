module DMEM (
    input clk, rst, MemRead, MemWrite,
    input [2:0] funct3, // T? instruction[14:12]
    input [31:0] address, write_data,
    output reg [31:0] read_data
);
    reg [7:0] memory [0:1023]; // 256 word = 1024 byte
    integer k;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (k = 0; k < 1024; k = k + 1)
                memory[k] = 8'b0;
        end else if (MemWrite) begin
            case (funct3)
                3'b000: memory[address] = write_data[7:0]; // SB
                3'b001: {memory[address+1], memory[address]} = write_data[15:0]; // SH
                3'b010: {memory[address+3], memory[address+2], memory[address+1], memory[address]} = write_data; // SW
            endcase
        end
    end
    always @(*) begin
        if (MemRead) begin
            case (funct3)
                3'b000: read_data = {{24{memory[address][7]}}, memory[address]}; // LB
                3'b001: read_data = {{16{memory[address+1][7]}}, memory[address+1], memory[address]}; // LH
                3'b010: read_data = {memory[address+3], memory[address+2], memory[address+1], memory[address]}; // LW
                3'b100: read_data = {24'b0, memory[address]}; // LBU
                3'b101: read_data = {16'b0, memory[address+1], memory[address]}; // LHU
                default: read_data = 32'b0;
            endcase
        end else
            read_data = 32'b0;
    end
endmodule
