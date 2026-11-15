// Address Register Module - 2 bits (covers addresses 0-3)
module adrs_reg (
    input wire clk,
    input wire tx_clr,   // Reset signal
    input wire inc,      // Increment signal from FSM
    output reg [1:0] addr // 2-bit address to ROM
);

    always @(posedge clk or posedge tx_clr) begin
        if (tx_clr) begin
            addr <= 2'b00; // Reset address to 0
        end else if (inc) begin
            addr <= addr + 1'b1; // Move to next address
        end
    end

endmodule