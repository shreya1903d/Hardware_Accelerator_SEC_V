`timescale 1ns / 1ps

module FPGA_Top_Wrapper (
    input        board_clk_100mhz, 
    input        cpu_resetn,       // Red Button on Nexys A7 (Active Low)
    input        btn_start,        // Center Button
    input  [3:0] sw_image_sel,     // SW 0-3
    input  [3:0] sw_debug_sel,     // SW 4-7
    output       led_done,         // LED 0
    output [3:0] led_pred,         // LED 1-4 (The Answer)
    output [6:0] seg_out,          // Cathodes
    output [7:0] an_out            // Anodes
);

    // 1. INVERT RESET: Board gives 0 when pressed, Logic needs 1
    wire reset = ~cpu_resetn; 

    // Internal Wires
    wire signed [31:0] full_monitor_val;
    wire is_negative;
    wire [31:0] abs_32;    
    wire [15:0] magnitude;   
    wire [3:0] ones, tens, hundreds, thousands;
    wire [3:0] predicted_digit;

    // 2. ACCELERATOR INSTANCE
    // Ensure these port names match your "mnist_mlp_accelerator" exactly
    mnist_mlp_accelerator core_inst (
        .clk(board_clk_100mhz),      
        .reset(reset),
        .start(btn_start),           
        .image_index(sw_image_sel),  
        .monitor_select(sw_debug_sel), // Selects which neuron to watch
        .monitor_out(full_monitor_val),// Raw 32-bit data out
        .predicted_digit(predicted_digit),  
        .done(led_done)              
    );

    // 3. LED ASSIGNMENT
    // We map the 4-bit prediction directly to LEDs
    assign led_pred = predicted_digit;

    // 4. DATA PROCESSING FOR DISPLAY
    // CRITICAL FIX: Check Sign on 32-bit BEFORE truncating
    assign is_negative = full_monitor_val[31];
    
    // Get Absolute value (Twos Complement if negative)
    assign abs_32 = is_negative ? (~full_monitor_val + 1) : full_monitor_val;
    
    // Now safe to truncate to 16 bits for the BCD converter
    // (If value > 9999, it wraps, but that is expected for 4 digits)
    assign magnitude = abs_32[15:0];

    // 5. BCD CONVERTER INSTANCE
    Binary_to_BCD bcd_inst (
        .bin_in(magnitude),
        .ones(ones), 
        .tens(tens), 
        .hundreds(hundreds), 
        .thousands(thousands)
    );

    // 6. 7-SEGMENT DRIVER INSTANCE
    Seven_Seg_Driver driver_inst (
        .clk(board_clk_100mhz),      
        .reset(reset),
        .d3(thousands), 
        .d2(hundreds), 
        .d1(tens), 
        .d0(ones),
        .is_negative(is_negative),
        .seg(seg_out),               
        .an(an_out)                  
    );

endmodule