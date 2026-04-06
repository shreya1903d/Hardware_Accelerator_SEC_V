module Seven_Seg_Driver (
    input clk,               
    input reset,
    input [3:0] d3, d2, d1, d0, 
    input is_negative,       
    output reg [6:0] seg,    
    output reg [7:0] an      
);

    reg [16:0] refresh_counter;
    wire [1:0] digit_select;
    
    always @(posedge clk or posedge reset) begin
        if (reset) refresh_counter <= 0;
        else refresh_counter <= refresh_counter + 1;
    end
    assign digit_select = refresh_counter[16:15]; 

    reg [3:0] digit_to_show;
    always @* begin
        case(digit_select)
            2'b00: begin an = 8'b11111110; digit_to_show = d0; end 
            2'b01: begin an = 8'b11111101; digit_to_show = d1; end 
            2'b10: begin an = 8'b11111011; digit_to_show = d2; end
            2'b11: begin 
                   an = 8'b11110111; 
                   // If negative, show Minus Sign (mapped to 10), else show d3
                   digit_to_show = is_negative ? 4'd10 : d3; 
                   end 
        endcase
    end

    always @* begin
        case(digit_to_show)
            4'd0: seg = 7'b1000000; // 0
            4'd1: seg = 7'b1111001; // 1
            4'd2: seg = 7'b0100100; // 2
            4'd3: seg = 7'b0110000; // 3
            4'd4: seg = 7'b0011001; // 4
            4'd5: seg = 7'b0010010; // 5
            4'd6: seg = 7'b0000010; // 6
            4'd7: seg = 7'b1111000; // 7
            4'd8: seg = 7'b0000000; // 8
            4'd9: seg = 7'b0010000; // 9
            4'd10:seg = 7'b0111111; // Minus (-)
            default: seg = 7'b1111111; // Off
        endcase
    end
endmodule