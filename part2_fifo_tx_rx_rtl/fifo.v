// Optimized FIFO Moduleh
module fifo (
    input wire clk,
    input wire rst,
    input wire wr_en,
    input wire rd_en,
    input wire [7:0] data_in,
    output reg [7:0] data_out,
    output wire full,
    output wire empty
);

    // memory 4 rows 8 bits
    reg [7:0] mem [0:3];
    
    // 2 bit pointer (address)
      reg [1:0] wr_ptr;
    reg [1:0] rd_ptr;
    
    // 3-bit element counter 
     reg [2:0] count;

    // Status Flag Logic
       assign full  = (count == 3'd4);
    assign empty = (count == 3'd0);

    // Write Operation Proces
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 2'b00;
        end else if (wr_en && !full) begin
            mem[wr_ptr] <= data_in;
            wr_ptr <= wr_ptr + 1'b1;      // Automatic circular overflow from 3 back to 0
        end
    end

    // Read Operation Process
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rd_ptr   <= 2'b00;
            data_out <= 8'b0;
        end else if (rd_en && !empty) begin
            data_out <= mem[rd_ptr];
            rd_ptr   <= rd_ptr + 1'b1; // Automatic circular overflow
        end
    end

    // Internal Element Counter Management
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 3'b000;
        end else begin
            case ({wr_en && !full, rd_en && !empty})
                2'b10: count <= count + 1'b1;        // Write only
                2'b01: count <= count - 1'b1;        // Read only
                2'b11: count <= count;               // Write and read   
                default: count <= count ;            // No activity 
            endcase 
        end
    end

endmodule