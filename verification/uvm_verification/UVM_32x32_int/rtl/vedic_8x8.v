`ifndef VEDIC_8
    `define VEDIC_8

`timescale 1ns / 1ps

`include "PIPO.v"
`include "adder.v"
`include "vedic_4x4.v"

module vedic8x8(
    input wire        clk,
    input wire        reset,
    input wire [7 :0] a, b,
    input wire        start,
    output reg [15:0] result,   
    output reg        done
);
    wire [15:0] result_w;
    wire        result_pad;

    wire [7:0] t1, t2, t3, t6;
    wire [7:0] t1_buff_1, t1_buff_2;
    wire [7:0] t6_buff_1, t6_buff_2;
    wire [10:0] t4, t5;

    wire do_s2, do_s3, do_s4;

    vedic4x4 M4(clk, reset, a[7:4], b[7:4], start, t6, done_s1_1);    
    vedic4x4 M3(clk, reset, a[3:0], b[7:4], start, t3, done_s1_2);
    vedic4x4 M2(clk, reset, a[7:4], b[3:0], start, t2, done_s1_3);
    vedic4x4 M1(clk, reset, a[3:0], b[3:0], start, t1, done_s1_4);

    assign do_s2 = done_s1_1 & done_s1_2 & done_s1_3 & done_s1_4;

    PIPO #(8)  B2(clk, reset, t6,                       do_s2, t6_buff_1, done_s2_1);
    adder  #(10) A1(clk, reset, {2'b00, t2}, {2'b00, t3}, do_s2, t4,        done_s2_2);
    PIPO #(8)  B1(clk, reset, t1,                       do_s2, t1_buff_1, done_s2_3);
    
    assign do_s3 = done_s2_1 & done_s2_2 & done_s2_3;

    PIPO #(8)  B3(clk, reset, t6_buff_1,                            do_s3, t6_buff_2, done_s3_1);
    adder  #(10) A2(clk, reset, t4[9:0], {6'b000000, t1_buff_1[7:4]}, do_s3, t5,        done_s3_2);
    PIPO #(8)  B4(clk, reset, t1_buff_1,                            do_s3, t1_buff_2, done_s3_3);
    
    assign do_s4 = done_s3_1 & done_s3_2 & done_s3_3;
    
    adder  #(8) A3(clk, reset, t6_buff_2, {2'b00, t5[9:4]}, do_s4, {result_pad, result_w[15:8]}, done_s4_1);
    PIPO #(4) B6(clk, reset, t1_buff_2[3:0],              do_s4, result_w [3:0],               done_s4_2);
    PIPO #(4) B5(clk, reset, t5[3:0],                     do_s4, result_w [7:4],               done_s4_3);
    
    always @(posedge clk) begin 
        if (reset) begin
            done <= 1'b0;
        end else begin
            result <= result_w;
            done <= done_s4_1 & done_s4_2 & done_s4_3;
        end
    end
endmodule

`endif




