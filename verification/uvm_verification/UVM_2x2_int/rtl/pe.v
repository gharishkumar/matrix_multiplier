`timescale 1ns/1ps
`ifndef PE_
    `define PE_

    `include "vedic_2x2.v"
module pe 
( 
    input             clk,
    input             rst,
    input             load_in,
    input [1:0]      row_in, // parameter for datawidth to be added accordingly
    input [1:0]      col_in, 
    output reg [1:0] col_out, 
    output reg [1:0] row_out, 
    output reg [4:0] pe_result,
    output reg        done_pe
);
    
    wire [1:0] a;
    wire [1:0] b;
    wire [3:0] result;
    wire do_mul;

    vedic_2x2 inst_vedic_2x2
    (
        .clk    (clk),
        .reset  (rst),
        .a      (a),
        .b      (b),
        .start  (do_mul),
        .result (result),
        .done   (done)
    );


    reg do_mul_reg;

    assign do_mul = do_mul_reg;

    reg [1:0] a_in_reg;
    reg [1:0] b_in_reg;

    assign a = a_in_reg;
    assign b = b_in_reg;

    always @(posedge clk) begin 
        if(rst) begin
            a_in_reg <= 0;
            b_in_reg <= 0;
            pe_result <= 0;
            col_out <= 0;
            row_out <= 0;
            do_mul_reg <= 1'b0;
            done_pe  <= 1'b0;
        end else begin
            if (load_in) begin
                a_in_reg   <= row_in;
                b_in_reg   <= col_in;
                do_mul_reg <= 1'b1;
                done_pe    <= 1'b0;
            end else begin
                if(done) begin
                    pe_result <= pe_result + result;
                    done_pe   <= 1'b1;
                    do_mul_reg <= 1'b0;
                    row_out  <= a_in_reg;
                    col_out  <= b_in_reg;
                end else begin
                    pe_result  <= pe_result;
                    done_pe    <= 1'b0;
                    do_mul_reg <= 1'b0;
                end
            end
        end
    end
    
endmodule
`endif

