module RegisterFile (
    input clk,
    input [4:0] addA, addB, addD,
    input [31:0] WB_out,
    input RegWrite,
    output [31:0] dataA, dataB
);
    logic [31:0] regs [0:31];

    // reset về 0
    initial begin
        for (int i = 0; i < 32; i++) regs[i] = 32'b0;
    end
   
    always_comb begin
        dataA = regs[addA];
        dataB = regs[addB];
    end   
    
    always_ff @(posedge clk) begin
        if (RegWrite && addD  != 0)
            regs[addD] <= WB_out;
    end
endmodule
