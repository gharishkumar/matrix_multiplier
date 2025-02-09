`timescale 1ns/1ps
`ifndef ADDER_
    `define ADDER_
module adder #(
    parameter N = 1
) (
    input wire clk,
    input wire reset,
    input wire [N-1:0] a_in, b_in,
    input wire start,
    output reg [N :0] result_out,
    output reg done
);

    always @(posedge clk) begin
        if (reset) begin
            done <= 1'b0;
        end else if (start) begin
            result_out <= a_in + b_in;
            done <= 1'b1;
        end else begin
            done <= 1'b0;
        end
    end
endmodule
`endif