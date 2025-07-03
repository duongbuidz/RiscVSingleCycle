module RegisterFile (
    input clk,
    input rst, // Thêm tín hiệu reset
    input [4:0] addA, addB, addD,
    input [31:0] WB_out,
    input RegWrite,
    output reg [31:0] dataA, dataB
);
    logic [31:0] regs [0:31];

    // Khởi tạo thanh ghi khi reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (int i = 0; i < 32; i++) begin
                regs[i] <= 32'b0;
            end
        end
        else if (RegWrite && addD != 0) begin
            regs[addD] <= WB_out;
        end
    end

    // Gán giá trị đầu ra
    assign dataA = regs[addA];
    assign dataB = regs[addB];
endmodule
