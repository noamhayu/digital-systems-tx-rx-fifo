module tx_fsm (
    input wire clk,
    input wire tx_clr,
    input wire fifo_full,     // Status flag from FIFO
    input wire [1:0] addr,     // Current ROM memory address
    output reg rd,            // read enable signal for the ROM
    output reg fifo_wr_en,    // Write enable fifo
    output reg inc,           // Address control signal
    output reg tx_finish      
);

    // State Machine Parameter
    parameter ST_IDLE       = 3'b000;
    parameter ST_READ       = 3'b001;
    parameter ST_WRITE_FIFO = 3'b010;
    parameter ST_INC        = 3'b011;
    parameter ST_FINISH     = 3'b100;

    reg [2:0] current_state, next_state;

    always @(posedge clk or posedge tx_clr) begin
        if (tx_clr) begin
            current_state <= ST_IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Next State logic
    always @(*) begin
        next_state = current_state;
        case (current_state)
            ST_IDLE:       if (!fifo_full) next_state = ST_READ;
            ST_READ:       next_state = ST_WRITE_FIFO;  // Read data 
            ST_WRITE_FIFO: next_state = ST_INC;        // Write the word into the fifo
            ST_INC: begin
                if (addr == 2'd3) next_state = ST_FINISH; 
                else              next_state = ST_IDLE;
            end
            ST_FINISH:     next_state = ST_FINISH;     // Remain locked in finish state until system reset
            default:       next_state = ST_IDLE;
        endcase
    end

    // Output Assignment Combinational Logic
    always @(*) begin
        rd = 0; fifo_wr_en = 0; inc = 0; tx_finish = 0;
        case (current_state)
            ST_READ:       rd = 1;          // Enable ROM readout
            ST_WRITE_FIFO: fifo_wr_en = 1;  // Pulse FIFO write interface
            ST_INC:        inc = 1;         // Trigger address register increment
            ST_FINISH:     tx_finish = 1;
        endcase
    end

endmodule