`timescale 1ns/1ps

module vedic16x16(
    input wire        clk,
    input wire        reset,
    input wire [15:0] a, b,
    input wire        start,
    output reg [31:0] result,
    output reg        done
);
    wire [31:0] result_w;
    wire        result_pad;

    wire [15:0] t1, t2, t3, t6;
    wire [15:0] t1_buff_1, t1_buff_2;
    wire [15:0] t6_buff_1, t6_buff_2;
    wire [18:0] t4, t5;

    wire do_s2, do_s3, do_s4;

    vedic8x8 M4(clk, reset, a[15:8], b[15:8], start, t6, done_s1_1);
    vedic8x8 M3(clk, reset, a[7:0],  b[15:8], start, t3, done_s1_2);
    vedic8x8 M2(clk, reset, a[15:8], b[7:0],  start, t2, done_s1_3);
    vedic8x8 M1(clk, reset, a[7:0],  b[7:0],  start, t1, done_s1_4);

    assign do_s2 = done_s1_1 & done_s1_2 & done_s1_3 & done_s1_4;

    PIPO  #(16) B2(clk, reset, t6,                       do_s2, t6_buff_1, done_s2_1);
    adder #(18) A1(clk, reset, {2'b00, t2}, {2'b00, t3}, do_s2, t4,        done_s2_2);
    PIPO  #(16) B1(clk, reset, t1,                       do_s2, t1_buff_1, done_s2_3);

    assign do_s3 = done_s2_1 & done_s2_2 & done_s2_3;
    
    PIPO  #(16) B3(clk, reset, t6_buff_1,                          do_s3, t6_buff_2, done_s3_1);
    adder #(18) A2(clk, reset, t4[17:0], {10'b0, t1_buff_1[15:8]}, do_s3, t5,        done_s3_2);
    PIPO  #(16) B4(clk, reset, t1_buff_1,                          do_s3, t1_buff_2, done_s3_3);

    assign do_s4 = done_s3_1 & done_s3_2 & done_s3_3;
    
    adder #(16) A3(clk, reset, t6_buff_2, {6'b000000,t5[17:8]}, do_s4, {result_pad, result_w[31:16]}, done_s4_1);
    PIPO  #(8)  B5(clk, reset, t5[7:0],                         do_s4, result_w [15:8],               done_s4_2);
    PIPO  #(8)  B6(clk, reset, t1_buff_2[7:0],                  do_s4, result_w [7:0],                done_s4_3);    

    always @(posedge clk) begin
        if (reset) begin
            done <= 1'b0;
        end else begin
            result <= result_w;
            done <= done_s4_1 & done_s4_2 & done_s4_3;
        end
    end
endmodule