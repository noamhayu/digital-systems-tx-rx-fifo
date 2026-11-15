module rx_fsm (
    input wire clk,          // Clock
    input wire rx_clr,       // Reset
    input wire tx_vld,       // sending valid data
    input wire [1:0] addr,   // current RAM address  
    output reg rx_rdy,       // Ready        
    output reg shr,          // Shift right control output for the rbuf shift register
    output reg wr,           //Write enable control output for the RAM 
    output reg inc,          // Increment control output for the RAM address counter  
    output reg rx_finish       
);

    // FSM states
    parameter ST_IDLE    = 2'b00;  // Waiting for incoming transmission
    parameter ST_RECEIVE = 2'b01;  // Receiving and shifting 8 bits of serial data
    parameter ST_WRITE   = 2'b10;  // Writing data to RAM and incrementing address 
    parameter ST_FINISH  = 2'b11;  // Finish after all 4 words are stored

    reg [1:0] current_state, next_state; // 4 states 2 bits
    reg [2:0] bit_cnt;                   // 3-bit counter to track the 8 received bits

    // State Register & Counter Update
    always @(posedge clk or posedge rx_clr) begin
        if (rx_clr) begin
            current_state <= ST_IDLE;    // Reset to initial IDLE state
            bit_cnt <= 3'b000;           // Clear the bit counter
        end else begin
            current_state <= next_state;
            if (current_state == ST_RECEIVE)
                bit_cnt <= bit_cnt + 1'b1;  // Count incoming bits during reception
            else 
                bit_cnt <= 3'b000;          // Clear counter in all other states
        end
    end

    // Next State Decoder
    always @(*) begin
        next_state = current_state;
        case (current_state)
            ST_IDLE: begin
                if (tx_vld) next_state = ST_RECEIVE;       //Start receiving when transmitter asserts valid data
            end
            ST_RECEIVE: begin
                   if (bit_cnt == 3'd7) next_state = ST_WRITE; // Move to write state after 8 cycles
            end
            ST_WRITE: begin
                if (addr == 2'd3) next_state = ST_FINISH; // Check if fourth word is finished 
                else next_state = ST_IDLE;                // else, return to wait for the next word
            end 
            ST_FINISH: begin
                next_state = ST_FINISH;                   // Remain locked in finish state until system reset
            end
            default: next_state = ST_IDLE;                // Safe fallback path
        endcase
    end

    // Output Decoder
    always @(*) begin
        rx_rdy = 0; shr = 0; wr = 0; inc = 0; rx_finish = 0; // Reset all
        
        case (current_state)
            ST_IDLE: begin
                rx_rdy = 1;
                         if (tx_vld) shr = 1; 
            end
            ST_RECEIVE: begin
                         if (bit_cnt < 3'd7) shr = 1;
            end
            ST_WRITE: begin
                wr = 1;   // Assert RAM write enable
                inc = 1;  // Increment
            end
            ST_FINISH: begin
                rx_finish = 1;  // Signal total reception sequence complete
            end
        endcase
    end

endmodule