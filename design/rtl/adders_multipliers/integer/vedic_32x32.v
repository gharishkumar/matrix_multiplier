`timescale 1ns / 1ps

module vedic32x32(
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] a, b,
    input  wire        start,
    output reg  [63:0] result,
    output reg         done
);
    wire [64:0] result_w;
    wire        result_pad;

    wire [31:0] t1, t2, t3, t6;
    wire [31:0] t1_buff_1, t1_buff_2;
    wire [31:0] t6_buff_1, t6_buff_2;
    wire [34:0] t4, t5;

    wire do_s2, do_s3, do_s4;

    vedic16x16 M4(clk, reset, a[31:16], b[31:16], start, t6, done_s1_1);
    vedic16x16 M3(clk, reset, a[15:0],  b[31:16], start, t3, done_s1_2);
    vedic16x16 M2(clk, reset, a[31:16], b[15:0],  start, t2, done_s1_3);
    vedic16x16 M1(clk, reset, a[15:0],  b[15:0],  start, t1, done_s1_4);

    assign do_s2 = done_s1_1 & done_s1_2 & done_s1_3 & done_s1_4;

    PIPO  #(32) B2(clk, reset, t6,                     do_s2, t6_buff_1, done_s2_1);
    adder #(34) A1(clk, reset, {2'b0, t2}, {2'b0, t3}, do_s2, t4,        done_s2_2);    
    PIPO  #(32) B1(clk, reset, t1,                     do_s2, t1_buff_1, done_s2_3);
    
    assign do_s3 = done_s2_1 & done_s2_2 & done_s2_3;

    PIPO  #(32) B3(clk, reset, t6_buff_1,                           do_s3, t6_buff_2, done_s3_1);
    adder #(34) A2(clk, reset, t4[33:0], {18'b0, t1_buff_1[31:16]}, do_s3, t5,        done_s3_2);
    PIPO  #(32) B4(clk, reset, t1_buff_1,                           do_s3, t1_buff_2, done_s3_3);
    
    assign do_s4 = done_s3_1 & done_s3_2 & done_s3_3;

    adder #(32) A3(clk, reset, t6_buff_2, {{14'b0}, t5[33:16]}, do_s4,{result_pad, result_w[63:32]}, done_s4_1);
    PIPO  #(16) B5(clk, reset, t5[15:0],                        do_s4, result_w [31:16],             done_s4_2);
    PIPO  #(16) B6(clk, reset, t1_buff_2[15:0],                 do_s4, result_w [15:0],              done_s4_3);
    
    always @(posedge clk) begin
        if (reset) begin
            done <= 1'b0;
        end else begin
            result <= result_w;
            done <= done_s4_1 & done_s4_2 & done_s4_3;
        end
    end
endmodule