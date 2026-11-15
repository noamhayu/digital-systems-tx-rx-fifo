module tx_top (
    input wire clk,
    input wire tx_clr,
    input wire fifo_full,          // Status flag from FIFO
    output wire [7:0] tx_data_out, // 8-bit parallel data output 
    output wire fifo_wr_en,        // Write enable
    output wire tx_finish
);

    wire [1:0] internal_addr;
    wire ctrl_rd, ctrl_inc;

    // ROM Address Counter
    adrs_reg addr_inst (
        .clk(clk),
        .tx_clr(tx_clr),
        .inc(ctrl_inc),          // Input increment trigger from FSM
        .addr(internal_addr) // Driven address output bus
    );

    // Synchronous ROM Instance
    tx_rom rom_inst (
        .clk(clk),
        .rd(ctrl_rd),          // Read strobe input from FSM
        .addr(internal_addr),  // Shared address bus input
        .dout(tx_data_out)     // Direct parallel data link to FIFO
    );

    // Control Unit
    tx_fsm fsm_inst (
        .clk(clk),
        .tx_clr(tx_clr),
        .fifo_full(fifo_full),
        .addr(internal_addr),
        .rd(ctrl_rd),
        .fifo_wr_en(fifo_wr_en),
        .inc(ctrl_inc),
        .tx_finish(tx_finish)
    );

endmodule