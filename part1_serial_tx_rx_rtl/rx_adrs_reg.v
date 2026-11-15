// RX Address Register Module 
module rx_adrs_reg (
    input wire clk,
    input wire rx_clr,     // RX reset
    input wire inc,        // Increment control signal from the RX FSM
    output reg [1:0] addr  // 2-bit address output driving the RAM input
);

    always @(posedge clk or posedge rx_clr) begin
        if (rx_clr) begin
            addr <= 2'b00;       // Clears the address counter back to 0
        end else if (inc) begin  // Advances to the next RAM address location
            addr <= addr + 1'b1;
        end
    end

endmodule