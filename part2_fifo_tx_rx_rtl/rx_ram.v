
module rx_ram (
    input wire clk,
    input wire wr,           // אות הרשאת כתיבה מה-FSM (Write Enable)
    input wire [1:0] addr,   // כתובת בגודל 2 ביט (0 עד 3)
    input wire [7:0] din,    // הנתון המקבילי שמגיע מה-RBUF
    output reg [7:0] dout    // מוצא הנתונים (לקריאה עתידית או תצוגה)
);

    // הגדרת המערך בזיכרון (4 שורות, כל אחת ברוחב 8 ביט)
    reg [7:0] memory [0:3];

    // פעולת כתיבה/קריאה סינכרונית לשעון
    always @(posedge clk) begin
        if (wr) begin
            memory[addr] <= din;  // כתיבת הנתון לזיכרון
        end
        dout <= memory[addr];     // קריאה רציפה מהכתובת הנוכחית
    end

endmodule