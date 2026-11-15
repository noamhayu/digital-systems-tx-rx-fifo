`timescale 1ns / 1ps

module tb_tx_rx;

    // Global System Signals
    reg clk;
    reg rst; // Shared reset for both TX and RX modules

    // Interconnection Communication Lines 
       wire tx_rx_line;    //Serial data line transferring bits from TX to RX
    wire tx_rx_vld;     // Data valid indicator signal driven by TX
    wire rx_tx_rdy;     // Ready indicator signal driven by RX
    wire tx_finish;
    wire rx_finish;
    wire [7:0] rx_dout; // 8-bit parallel output from RX RAM

    //TX Top Level
       tx_top tx_inst (
        .clk(clk),
        .tx_clr(rst),
        .rx_rdy(rx_tx_rdy),      // Inputs the ready status from RX
        .tx_data(tx_rx_line),    // Outputs serial data to the shared line
        .tx_vld(tx_rx_vld),      // Outputs valid indicator to the shared line
        .tx_finish(tx_finish)
    );

    //RX Top Level
    rx_top rx_inst (
        .clk(clk),
        .rx_clr(rst),
        .tx_data(tx_rx_line),    // Inputs serial data from the shared line
        .tx_vld(tx_rx_vld),      // Inputs valid indicator from the shared line
        .rx_rdy(rx_tx_rdy),      // Outputs ready status to TX
        .rx_finish(rx_finish),   
        .dout(rx_dout)           // Connects to parallel output for verification
    );

    always begin
        #10 clk = ~clk;
    end

    // Main Test
    initial begin
        // Initial Signal Reset
        clk = 0;
        rst = 1; 
        
        #40;
        rst = 0; //Turn off the reset to initiate automatic communication loop
        
        $display("=================================================");
        $display("Starting FULL SYSTEM Integration Test (TX -> RX)");
        $display("=================================================");

        
        // Wait for both modules to flag execution completion
        fork
            wait(tx_finish == 1);
            wait(rx_finish == 1);
        join
        
        #100; // Post-test delay to observe stable final waveform states
        
        $display("=================================================");
        $display("SUCCESS: Both TX and RX finished successfully!");
        $display("Check the RAM output to verify A1, B2, C3, D4.");
        $display("=================================================");
        $finish;
    end

endmodule