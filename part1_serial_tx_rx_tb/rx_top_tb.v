`timescale 1ns / 1ps

module rx_top_tb;

    reg clk;
    reg rx_clr;
    reg tx_data;
    reg tx_vld;
    
    wire rx_rdy;
    wire rx_finish;
    wire [7:0] dout;

    rx_top dut (
        .clk(clk),
        .rx_clr(rx_clr),
        .tx_data(tx_data),
        .tx_vld(tx_vld),
        .rx_rdy(rx_rdy),
        .rx_finish(rx_finish),
        .dout(dout)
    );

    // Clock Generator
    always begin
        #10 clk = ~clk;
    end

    // Task to send a byte serially
    task send_byte(input [7:0] data_to_send);
        integer i;
        begin
            // Wait fo rx_rdy == 1
            while (!rx_rdy) @(posedge clk);
            
            // Change signals on negedge to ensure data stability
            @(negedge clk);
            tx_vld = 1;
            
            // Convert parallel byte to serial bitstream
            for (i = 0; i < 8; i = i + 1) begin
                tx_data = data_to_send[i]; 
                @(negedge clk); // Shift to the next bit on every falling edge
            end
            
            @(negedge clk);        // Wait an extra cycle on negative edge to ensure data stability
            
            // Clear the lines and return inputs back to idle state
            tx_vld = 0;
            tx_data = 0;
            
            // Wait for an additional rising edge to let the RX safely complete RAM write and address increment
            @(posedge clk); 
            #5; // Minor delay to stabilize tracking between consecutive bytes
        end
    endtask

    // Main Test
    initial begin
        // Initial Signal Reset
        clk = 0;
        rx_clr = 1;
        tx_data = 0;
        tx_vld = 0;
        
        #40;
        rx_clr = 0;
        #20;

        $display("=================================================");
        $display("Starting FIXED RX Testbench (LSB First)...");
        $display("=================================================");
        
        // Transmit the 4 bytes
        $display("[%0d ns] Sending Byte 0: A1", $time);
        send_byte(8'hA1); 
        #40; 
        
        $display("[%0d ns] Sending Byte 1: B2", $time);
        send_byte(8'hB2);
        #40;
        
        $display("[%0d ns] Sending Byte 2: C3", $time);
        send_byte(8'hC3);
        #40;
        
        $display("[%0d ns] Sending Byte 3: D4", $time);
        send_byte(8'hD4);
        
        // Post-transmission delay to observe the FSM locking into ST_FINISH
        #200;
        
        $display("=================================================");
        $display("Testbench execution finished.");
        $display("=================================================");
        $finish;
    end

endmodule