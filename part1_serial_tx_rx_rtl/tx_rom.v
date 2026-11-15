// TX ROM Module - 4 Words x 8 Bits
module tx_rom (
    input wire clk,
    input wire rd,           // Read enable signal coming from the FSM
    input wire [1:0] addr,   // 2-bit address input (4 memory rows)
    output reg [7:0] dout    // 8-bit parallel data output
);

    // Defines the physical memory array (4 rows, each row holds an 8-bit)
    reg [7:0] memory [0:3];

    // loading data
    initial begin
        $readmemh("tx_data.txt", memory);
    end

    // Synchronous memory read
    always @(posedge clk) begin
        if (rd) begin
            dout <= memory[addr];
        end
    end

endmodule