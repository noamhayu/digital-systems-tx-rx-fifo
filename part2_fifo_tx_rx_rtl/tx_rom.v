// TX ROM Module - 4 Words x 8 Bits
module tx_rom (
    input wire clk,
    input wire rd,           // אות קריאה מה-FSM
    input wire [1:0] addr,   // כתובת בגודל 2 ביט
    output reg [7:0] dout    // מוצא הנתונים
);

    // הגדרת המערך בזיכרון
    reg [7:0] memory [0:3];

    // טעינת נתונים מקובץ חיצוני
    initial begin
        $readmemh("tx_data.txt", memory);
    end

    // קריאה סינכרונית מהזיכרון
    always @(posedge clk) begin
        if (rd) begin
            dout <= memory[addr];
        end
    end

endmodule