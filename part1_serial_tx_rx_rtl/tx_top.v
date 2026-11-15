// TX Top Level Module - Integrates all sub-modules
module tx_top (
    input wire clk,          
    input wire tx_clr,        
    input wire rx_rdy,        
    output wire tx_data,     
    output wire tx_vld,
    output wire tx_finish
);

    // Internal wires used to interconnect the sub-modules
    wire [1:0] internal_addr;                    // 2-bit address 
    wire [7:0] internal_dout;                    // 8-bit parallel data
    wire ctrl_rd, ctrl_ld, ctrl_shr, ctrl_inc;    // Control signals from the FSM

    // Address Register - Manages the ROM indexing
    adrs_reg addr_inst (
        .clk(clk),
        .tx_clr(tx_clr),
        .inc(ctrl_inc),            // Controlled by FSM to move to the next word
        .addr(internal_addr)       // Outputs current address to ROM and FSM
    );

    // TX ROM - Stores the data payload to be transmitted
    tx_rom rom_inst (
        .clk(clk),
        .rd(ctrl_rd),          // Controlled by FSM to trigger a synchronous read
        .addr(internal_addr),  // Inputs current address from the counte
        .dout(internal_dout)   // Outputs fetched 8-bit parallel data byte
    );

    // 3.TBUF - Parallel-to-Serial Shift Register
    tbuf tbuf_inst (
        .clk(clk),
        .tx_clr(tx_clr),
        .ld(ctrl_ld),              
        .shr(ctrl_shr),         // Controlled by FSM to shift bits right serially
        .din(internal_dout),    // Inputs parallel data byte from ROM
        .tx_data(tx_data)       // Outputs the current bit serially to the external line
    );

    // control unit (FSM)
    tx_fsm fsm_inst (
        .clk(clk),
        .tx_clr(tx_clr),
        .rx_rdy(rx_rdy),       // Monitors receiver readiness to start transmission
        .addr(internal_addr),  // Monitors address to know when 4 words are done
        .rd(ctrl_rd),          // ROM read enable 
        .ld(ctrl_ld),          // TBUF load enable 
        .shr(ctrl_shr),        // TBUF shidt right enable
        .inc(ctrl_inc),        // Address counter increment
        .tx_vld(tx_vld),       // External data valid status line 
        .tx_finish(tx_finish)  
    );

endmodule