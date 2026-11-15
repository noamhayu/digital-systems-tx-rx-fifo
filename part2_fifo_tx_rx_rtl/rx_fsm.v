module rx_fsm (
    input wire clk,
    input wire rx_clr,
    input wire fifo_empty,    // Status flag from FIFO
    input wire [1:0] addr,     // Current RAM memory address
    output reg fifo_rd_en,    // Read enable
    output reg wr,            // Write enable
    output reg inc,           // Address control signal
    output reg rx_finish      
);

    //State Machine Parameter
    parameter ST_IDLE      = 2'b00;
    parameter ST_READ_FIFO = 2'b01;
    parameter ST_WRITE_RAM = 2'b10;
    parameter ST_FINISH    = 2'b11;

    reg [1:0] current_state, next_state;

    always @(posedge clk or posedge rx_clr) begin
        if (rx_clr) begin
            current_state <= ST_IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Next state logic
    always @(*) begin
        next_state = current_state;
        case (current_state)
            ST_IDLE:      if (!fifo_empty) next_state = ST_READ_FIFO;
            ST_READ_FIFO: next_state = ST_WRITE_RAM; 
            ST_WRITE_RAM: begin
                if (addr == 2'd3) next_state = ST_FINISH; 
                else              next_state = ST_IDLE;
            end
            ST_FINISH:    next_state = ST_FINISH;
            default:      next_state = ST_IDLE;
        endcase
    end

    // Output
    always @(*) begin
        fifo_rd_en = 0; wr = 0; inc = 0; rx_finish = 0;
        case (current_state)
            ST_READ_FIFO: fifo_rd_en = 1;  // Pulse FIFO read interface
            ST_WRITE_RAM: begin
                wr = 1;                    // Enable RAM write cycle
                inc = 1;                   
            end
            ST_FINISH:    rx_finish = 1;
        endcase
    end

endmodule