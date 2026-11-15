// RX Top Level Module
module rx_top (
    input wire clk,
    input wire rx_clr,       // Reset
    input wire tx_data,      // Incoming 1-bit serial data
    input wire tx_vld,       // Signals that the incoming serial data is valid 
    output wire rx_rdy,      // Ready
      output wire rx_finish,   
    output wire [7:0] dout   // 8-bit parallel data output from RAM for verification
);

      // Internal wires used to interconnect the sub-modules
    wire [1:0] internal_addr;          // 2-bit address bus connecting the counter to the RAM and FSM
    wire [7:0] internal_qbuf;          // 8-bit parallel data bus connecting the RBUF output to the RAM input
    wire ctrl_shr, ctrl_wr, ctrl_inc;  // FSM control wires

    // RBUF - Serial-to-Parallel Shift Register
    rbuf rbuf_inst (
        .clk(clk),
        .rx_clr(rx_clr),
        .shr(ctrl_shr),       // Controlled by FSM to shift-in incoming serial bits
        .tx_data(tx_data),    // Inputs the serial bit from the transmitter
        .qbuf(internal_qbuf)  // Outputs the 8-bit parallel byte
    );

    // RX RAM - Stores the 4 received bytes
    rx_ram ram_inst (
        .clk(clk),
        .wr(ctrl_wr),           // Controlled by FSM to trigger a synchronous write
        .addr(internal_addr),   // Inputs current address from the counter
        .din(internal_qbuf),    // Inputs parallel data byte from RBUF
        .dout(dout)             // Output the data to the top level
    ); 

    // RX Address Register
      rx_adrs_reg addr_inst (
        .clk(clk),
        .rx_clr(rx_clr),
        .inc(ctrl_inc),        // Controlled by FSM to advance to the next RAM row
        .addr(internal_addr)   // Outputs current address to RAM and FSM
    );

    // RX Control Unit (FSM)
    rx_fsm fsm_inst (
        .clk(clk),
        .rx_clr(rx_clr),
        .tx_vld(tx_vld),         // Monitors incoming data validity
        .addr(internal_addr),    // Monitors address to know when 4 words are done
        .rx_rdy(rx_rdy),
        .shr(ctrl_shr),         // Drives RBUF shift right enable
        .wr(ctrl_wr),           // Drives RAM write enable
        .inc(ctrl_inc),         // Drives address counter increment
        .rx_finish(rx_finish)
    );

endmodule