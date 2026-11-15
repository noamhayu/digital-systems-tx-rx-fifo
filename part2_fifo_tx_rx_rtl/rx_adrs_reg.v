// RX Address Register Module - 2 bits
module rx_adrs_reg (
    input wire clk,
    input wire rx_clr,     // אות ריסט של ה-RX
    input wire inc,        // אות קידום כתובת מה-FSM
    output reg [1:0] addr  // הכתובת ל-RAM
);

    always @(posedge clk or posedge rx_clr) begin
        if (rx_clr) begin
            addr <= 2'b00;
        end else if (inc) begin
            addr <= addr + 1'b1;
        end
    end

endmodule