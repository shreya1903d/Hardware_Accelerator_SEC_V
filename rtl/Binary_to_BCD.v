module Binary_to_BCD (
    input [15:0] bin_in,
    output reg [3:0] ones,
    output reg [3:0] tens,
    output reg [3:0] hundreds,
    output reg [3:0] thousands
);
    integer i;
    reg [31:0] bcd; 

    always @* begin
        bcd = 0;
        bcd[15:0] = bin_in; 

        for (i = 0; i < 16; i = i + 1) begin
            // Double Dabble Algorithm
            if (bcd[19:16] > 4) bcd[19:16] = bcd[19:16] + 3;
            if (bcd[23:20] > 4) bcd[23:20] = bcd[23:20] + 3;
            if (bcd[27:24] > 4) bcd[27:24] = bcd[27:24] + 3;
            if (bcd[31:28] > 4) bcd[31:28] = bcd[31:28] + 3;
            bcd = bcd << 1;
        end
        
        thousands = bcd[31:28];
        hundreds  = bcd[27:24];
        tens      = bcd[23:20];
        ones      = bcd[19:16];
    end
endmodule