module rbuf (
    input wire clk,
    input wire rx_clr,       // Reset
    input wire shr,          // Shift right enable signal from the RX FSM  
    input wire tx_data,      // 1-bit incoming serial data line from the transmitter  
    output reg [7:0] qbuf    // 8-bit parallel data output driving the RAM input  
);
    // Reset and synchronous shift logic
    always @(posedge clk or posedge rx_clr) begin
        if (rx_clr) begin
            qbuf <= 8'b0;                   // Clears the entire buffer to zero
        end else if (shr) begin             // Shift right
            qbuf <= {tx_data, qbuf[7:1]};
        end
    end

endmodule