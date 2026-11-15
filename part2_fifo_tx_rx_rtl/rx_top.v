module rx_top (
    input wire clk,
    input wire rx_clr,
    input wire [7:0] fifo_data_in, // 8-bit parallel data input
    input wire fifo_empty,         // Status flag input from source FIFO
    output wire fifo_rd_en,        // Read enable fifo
    output wire rx_finish,
    output wire [7:0] dout         // Parallel RAM output
);

    wire [1:0] internal_addr;
    wire ctrl_wr, ctrl_inc;

    // RAM Instance
    rx_ram ram_inst (
        .clk(clk),
        .wr(ctrl_wr),          // Write strobe input from FSM
        .addr(internal_addr),  // Shared address bus input
        .din(fifo_data_in),    // Parallel input data directly driven by the FIFO
        .dout(dout) 
    );

    // RAM Address Counter Instance
    rx_adrs_reg addr_inst (
        .clk(clk),
        .rx_clr(rx_clr),
        .inc(ctrl_inc),        // Input increment trigger from FSM
        .addr(internal_addr)
    );

    // Control Unit
    rx_fsm fsm_inst (
        .clk(clk),
        .rx_clr(rx_clr),
        .fifo_empty(fifo_empty),
        .addr(internal_addr),     // Internal tracking of current address pointer
        .fifo_rd_en(fifo_rd_en),  // Drives the parallel FIFO read control line
        .wr(ctrl_wr),             // Drives the RAM write signal
        .inc(ctrl_inc),
        .rx_finish(rx_finish)
    );

endmodule