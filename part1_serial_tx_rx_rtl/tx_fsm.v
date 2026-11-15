module tx_fsm (
    input wire clk,
    input wire tx_clr,     // Reset
    input wire rx_rdy,     // Ready to accept data
    input wire [1:0] addr, // Cheak if all 4 word are sent
    output reg rd,         // Read enable control output for the ROM
    output reg ld,         // Load enable control output for the TBUF
    output reg shr,        // Shift right control output for the TBUF
    output reg inc,        // Increment control output for the ROM address counter
    output reg tx_vld,     // Transmit valid signal indicating valid data on the serial line
    output reg tx_finish   // Finish status signal
);

    // State definitions using parameters
    parameter ST_IDLE   = 3'b000;
    parameter ST_READ   = 3'b001;
    parameter ST_LOAD   = 3'b010;
    parameter ST_SHIFT  = 3'b011;
    parameter ST_INC    = 3'b100;
    parameter ST_FINISH = 3'b101;

    reg [2:0] current_state, next_state; // State registers
    reg [2:0] bit_cnt;                   // For 8 bits

    // State register
    always @(posedge clk or posedge tx_clr) begin
        if (tx_clr) begin
            current_state <= ST_IDLE;     // Reset to the initial IDLE state
            bit_cnt <= 3'b000;            // Clear the bit counter
        end else begin
            current_state <= next_state;       // Move to the next state
            if (current_state == ST_SHIFT)
                bit_cnt <= bit_cnt + 1'b1;     // Increment counter only while shifting bits
            else
                bit_cnt <= 3'b000;                     // clear counter
        end 
    end

    // Next state logic
    always @(*) begin
        next_state = current_state;
        case (current_state)
            ST_IDLE:  if (rx_rdy) next_state = ST_READ; // Wait fir receiver readiness
            ST_READ:  next_state = ST_LOAD;
            ST_LOAD:  next_state = ST_SHIFT;
            ST_SHIFT: if (bit_cnt == 3'd7) next_state = ST_INC; //Stay until all 8 bits are sent
            ST_INC: begin
                if (addr == 2'd3) next_state = ST_FINISH;  //Checks if the fourth word is finished
                else next_state = ST_IDLE;                            // else , return to send the next word
            end
            ST_FINISH: next_state = ST_FINISH; // Remain locked in finish state until system reset
            default:   next_state = ST_IDLE;   // Safe default state fallback
        endcase
    end

    // Output logic
    always @(*) begin
        rd = 0; ld = 0; shr = 0; inc = 0; tx_vld = 0; tx_finish = 0;
        case (current_state)
            ST_READ:   rd = 1;                                            // Enable ROM reading
            ST_LOAD:   ld = 1;                           // Enable TBUF parallel loading
            ST_SHIFT:  begin shr = 1; tx_vld = 1; end    // Enable right shifting and validate data output
            ST_INC:    inc = 1;                          // Trigger address counter increment
            ST_FINISH: tx_finish = 1;                    // Signal transmission complete
        endcase
    end

endmodule