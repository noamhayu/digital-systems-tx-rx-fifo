// TBUF Module - Parallel to Serial Shift Register
module tbuf (
    input wire clk,
    input wire tx_clr,       // Reset
    input wire ld,           // Load signal from FSM
    input wire shr,          // Shift Right signal from FSM
    input wire [7:0] din,    // Data from ROM (dout)
    output wire tx_data      // Serial data output
);

    reg [7:0] shift_reg;

    // The output always reflects the current bit to be transmitted
    assign tx_data = shift_reg[0]; 

    always @(posedge clk or posedge tx_clr) begin
        if (tx_clr) begin
            shift_reg <= 8'b0;
        end else if (ld) begin
            shift_reg <= din; // Synchronous load 
        end else if (shr) begin
            shift_reg <= {1'b0, shift_reg[7:1]}; // Shift right 
        end
    end

endmodule