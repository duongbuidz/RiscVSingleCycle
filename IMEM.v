module IMEM (	
    input [29:0] addr,
    output [31:0] instruction
);
    reg [31:0] memory [0:1023];
    initial begin
    integer i;
        for (i = 0; i < 1024; i = i + 1) begin
            imem[i] = 32'b0;
        end    
    imem[0] = 32'b0000000000000000000000000000000 ;       // nop
    imem[1] = 32'b0100000_00011_01000_000_00101_0110011;     // sub x5, x8, x3
    imem[2] = 32'b000000000010_10101_000_10110_0010011;    // addi x22, x21, 2
    imem[3]= 32'b000000001111_00010_010_01000_0000011;    // lw x8, 15(x2)
    imem[4]= 32'b0000000_01110_00110_010_01100_0100011;     // sw x14, 12(x6), x6 = 44   
    imem[5]= 32'b0_000000_01001_01001_000_0110_0_1100011; // beq x9, x9, 12, (PC + 12 if x9 = x9 
    end
    assign instruction = memory[addr];
endmodule 
