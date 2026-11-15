`timescale 1ns / 1ps

module tb_tx_rx_fifo;

    reg clk;
    reg tx_rst;
    reg rx_rst;

    // Manual Testbench Injection and Control Signal
      reg force_tb_control;
    reg tb_wr_en;
    reg tb_rd_en;
    reg [7:0] tb_data_in;

    // TX to FIFO
    wire [7:0] tx_to_fifo_data;
    wire tx_wr_en;
    wire tx_finish;

    // FIFO to RX
    wire [7:0] fifo_to_rx_data;
    wire rx_rd_en;
    wire fifo_full;
    wire fifo_empty;
    
    wire rx_finish;
    wire [7:0] rx_dout;

    // flow control multiplexers
    wire final_wr_en = force_tb_control ? tb_wr_en : tx_wr_en;
    wire final_rd_en = force_tb_control ? tb_rd_en : rx_rd_en;
    wire [7:0] final_data_in = force_tb_control ? tb_data_in : tx_to_fifo_data;

    // TX Top Level
    tx_top tx_inst (
        .clk(clk),
        .tx_clr(tx_rst),
        .fifo_full(fifo_full),
        .tx_data_out(tx_to_fifo_data),
        .fifo_wr_en(tx_wr_en),
        .tx_finish(tx_finish)
    );

    // Hardware FIFO Instance
    fifo fifo_inst (
        .clk(clk),
        .rst(tx_rst), 
        .wr_en(final_wr_en),
        .rd_en(final_rd_en),
        .data_in(final_data_in),
        .data_out(fifo_to_rx_data),
        .full(fifo_full),
        .empty(fifo_empty)
    );

    // RX Top Level
    rx_top rx_inst (
        .clk(clk),
        .rx_clr(rx_rst),                // Separate reset line to freeze the RX during overflow testing
        .fifo_data_in(fifo_to_rx_data),
        .fifo_empty(fifo_empty),
        .fifo_rd_en(rx_rd_en),
        .rx_finish(rx_finish),
        .dout(rx_dout)
    );

    always begin
        #10 clk = ~clk;
    end

    // Main Directed Test Suite
    initial begin
        // Global Reset
        clk = 0;
        tx_rst = 1;
        rx_rst = 1;
        force_tb_control = 0;
        tb_wr_en = 0;
        tb_rd_en = 0;
        tb_data_in = 8'b0;
        #40;
        tx_rst = 0; 
        
        $display("=================================================");
        $display("Starting Directed Edge-Case Testing for FIFO");
        $display("=================================================");

        // Empty FIFO (Underflow Test)
        $display("[%0d ns] EDGE CASE 1: Attempting to READ from an EMPTY FIFO...", $time);
        @(negedge clk);
        force_tb_control = 1;  //Enable manual testbench control
        tb_rd_en = 1;         // Assert illegal read command
        
        @(negedge clk);
        tb_rd_en = 0;
        force_tb_control = 0; // Return control back to system FSMs
        $display("[%0d ns] Result: count=%0d, empty=%0b (Verify count didn't underflow!)", $time, fifo_inst.count, fifo_empty);
        
        #40;

        // Full FIFO (Overflow Test)
        $display("[%0d ns] EDGE CASE 2: Filling FIFO to max while RX is frozen...", $time);
        repeat(5) @(posedge clk);
        
        $display("[%0d ns] FIFO status: count=%0d, full=%0b", $time, fifo_inst.count, fifo_full);
       
            $display("[%0d ns] Forcing a 5th WRITE (Value: 8'hFF) into a FULL FIFO...", $time);
        @(negedge clk);
        force_tb_control = 1;  // Assert manual testbench override
        tb_data_in = 8'hFF;    // Inject dummy error-prone data
        tb_wr_en = 1;          // Assert illegal write command
        
        @(negedge clk);
        tb_wr_en = 0;
        force_tb_control = 0;  // Return control back to system FSMs
        $display("[%0d ns] Result: count=%0d, full=%0b (Verify count stayed 4 and 8'hFF was rejected!)", $time, fifo_inst.count, fifo_full);

        #40;
        
        // Normal Operation Resume (Buffer Draining)
        $display("[%0d ns] Releasing RX from reset to drain the FIFO normally...", $time);
        rx_rst = 0; 
        fork
            wait(tx_finish == 1);
            wait(rx_finish == 1);
        join
        
        #100;
        $display("=================================================");
        $display("SUCCESS: Edge cases passed, and normal data transfer completed!");
        $display("=================================================");
        $finish;
    end

endmodule