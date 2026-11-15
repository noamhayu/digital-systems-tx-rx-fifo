`timescale 1ns / 1ps

module tx_top_tb;

    reg clk;
    reg tx_clr;
    reg rx_rdy;
    
    wire tx_data;
    wire tx_vld;
    wire tx_finish;

    tx_top dut (
        .clk(clk),
        .tx_clr(tx_clr),
        .rx_rdy(rx_rdy),
        .tx_data(tx_data),
        .tx_vld(tx_vld),
        .tx_finish(tx_finish)
    );

    // Clock Generator
    always begin
        #10 clk = ~clk;
    end

    // Test Stimulus Process
    initial begin
        // Initial Signal Reset
        clk = 0;
        tx_clr = 1;  // Reset
        rx_rdy = 0;
        
        // tx_clear = 0 after 2 clock cycles
        #20;
        tx_clr = 0;
        #20;

        // Byte 0 Transmission
             rx_rdy = 1;  // Ready for the first byte
        #20;         // Wait 1 clock cycle
        rx_rdy = 0;  // FSM has already captured the request and moved to ST_READ
        #250;        // Wait 250ns for serial transmission to complete

        // Byte 1 Transmission
            rx_rdy = 1;
        #20;
        rx_rdy = 0;
        #250;

        // Byte 2 Transmission
             rx_rdy = 1;
        #20;
        rx_rdy = 0;
        #250;

        // Byte 3 Transmission (last word)
             rx_rdy = 1;
        #20;
        rx_rdy = 0;
        
        // Wait 300ns to allow the FSM to finish 
        #300;

        // End of simulation
        $display("Simulation finished. Check waveforms for 4 transmitted bytes.");
        $finish;
    end

endmodule