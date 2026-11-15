
module rx_ram (
    input wire clk,
    input wire wr,           // Write enable control signal from the RX FSM
    input wire [1:0] addr,  
    input wire [7:0] din,     // 8-bit parallel data input received from the RBUF shift register
    output reg [7:0] dout   // 8-bit parallel data output for reading stored data
);

    // Defines the physical RAM array: 4 rows deep, each row holds an 8-bit byte
    reg [7:0] memory [0:3];

    // Clock synchronous write/read operation
    always @(posedge clk) begin
        if (wr) begin
            memory[addr] <= din;  // Write data to memory
        end
        dout <= memory[addr];     // Read data from the curren t address
    end

endmodule