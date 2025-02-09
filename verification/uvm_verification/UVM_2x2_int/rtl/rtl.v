`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.02.2025 13:16:00
// Design Name: 
// Module Name: mat_wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "systolic_array_2x2.v"

module mat_wrapper(
    input        clk,
    input        rst,
    input        load_in,
    input [1:0]  a11,
    input [1:0]  a12,
    input [1:0]  a21,
    input [1:0]  a22,
    input [1:0]  b11,
    input [1:0]  b12,
    input [1:0]  b21,
    input [1:0]  b22,
    output reg [19:0] result_out,
    output reg   valid
    );

   wire [4:0] result_row00;
   wire [4:0] result_row01;
   wire [4:0] result_row10;
   wire [4:0] result_row11;
   
   wire valid_op;

   reg [7:0] a_reg;
   reg [7:0] b_reg;

   // reg load_in_reg = 
   reg load_in_sys_reg;

   reg [1:0] row_in_row0_reg;
   reg [1:0] row_in_row1_reg;
   reg [1:0] col_in_col0_reg;
   reg [1:0] col_in_col1_reg;

   wire [1:0] row_in_row0;
   wire [1:0] row_in_row1;
   wire [1:0] col_in_col0;
   wire [1:0] col_in_col1;
    
        systolic_array_2x2 inst_systolic_array_2x2
        (
            .clk          (clk),
            .rst          (rst),
            .load_in      (load_in_sys),
            .row_in_row0  (row_in_row0),
            .row_in_row1  (row_in_row1),
            .col_in_col0  (col_in_col0),
            .col_in_col1  (col_in_col1),
            .result_row00 (result_row00),
            .result_row01 (result_row01),
            .result_row10 (result_row10),
            .result_row11 (result_row11),
            .done         (done_sys),
            .valid_op     (valid_op)
        );




   assign row_in_row0 = row_in_row0_reg;
   assign row_in_row1 = row_in_row1_reg;
   assign col_in_col0 = col_in_col0_reg;
   assign col_in_col1 = col_in_col1_reg;

   assign load_in_sys = load_in_sys_reg;

   reg [3:0] state;

   parameter IDLE               = 4'b0000,
             LOAD_SET1          = 4'b0001,
             LOAD_UNSET1        = 4'b0010,
             LOAD_SET2          = 4'b0011,
             LOAD_UNSET2        = 4'b0100,
             LOAD_SET3          = 4'b0101,
             LOAD_UNSET3        = 4'b0110,
             LOAD_SET4          = 4'b0111,
             LOAD_UNSET4        = 4'b1000,
             WAIT_FOR_DONE      = 4'b1001;
             // PUT_RESULT_11      = 4'b0110,
             // PUT_RESULT_12      = 4'b0111,
             // PUT_RESULT_21      = 4'b1000,
             // PUT_RESULT_22_DONE = 4'b1001;

    always @(posedge clk) begin 
        if(rst) begin
            state <= IDLE;
            a_reg <= 0;
            b_reg <= 0;
            load_in_sys_reg <= 0;
            valid <= 1'b0;
        end else begin
            case (state)
                IDLE    : begin
                         valid <= 1'b0;
                         if (load_in)  begin
                             a_reg <= {a22, a21, a12, a11};
                             b_reg <= {b22, b21, b12, b11};
                             state <= LOAD_SET1;
                         end 
                end 
                LOAD_SET1 : begin
                            load_in_sys_reg <= 1'b1;
                            row_in_row0_reg <= a_reg[3:2];
                            row_in_row1_reg <= 2'b0;
                            col_in_col0_reg <= b_reg[5:4];
                            col_in_col1_reg <= 2'b0;
                            state <= LOAD_UNSET1;
                end
                LOAD_UNSET1 : begin 
                            load_in_sys_reg <= 1'b0;
                            state           <= LOAD_SET2;
                end
                LOAD_SET2 : begin
                    if (done_sys) begin
                            load_in_sys_reg <= 1'b1;
                            row_in_row0_reg <= a_reg[1:0];
                            row_in_row1_reg <= a_reg[7:6];
                            col_in_col0_reg <= b_reg[1:0];
                            col_in_col1_reg <= b_reg[7:6];
                            state <= LOAD_UNSET2;
                    end
                end
                LOAD_UNSET2 : begin 
                            load_in_sys_reg <= 1'b0;
                            state           <= LOAD_SET3;
                end
                LOAD_SET3 : begin
                    if (done_sys) begin
                            load_in_sys_reg <= 1'b1;
                            row_in_row0_reg <= 2'b0;
                            row_in_row1_reg <= a_reg[5:4];
                            col_in_col0_reg <= 2'b0;
                            col_in_col1_reg <= b_reg[3:2];
                            state <= LOAD_UNSET3;
                    end
                end
                LOAD_UNSET3 : begin 
                            load_in_sys_reg <= 1'b0;
                            state           <= LOAD_SET4;
                end
                LOAD_SET4 : begin
                    if (done_sys) begin
                            load_in_sys_reg <= 1'b1;
                            row_in_row0_reg <= 2'b0;
                            row_in_row1_reg <= 2'b0;
                            col_in_col0_reg <= 2'b0;
                            col_in_col1_reg <= 2'b0;
                            state <= LOAD_UNSET4;
                    end
                end
                LOAD_UNSET4 : begin 
                            load_in_sys_reg <= 1'b0;
                            state <= WAIT_FOR_DONE;
                end
                WAIT_FOR_DONE :  begin
                    load_in_sys_reg <= 1'b0;
                    if (valid_op) begin
                        result_out <= {result_row11, result_row10, result_row01, result_row00};
                        state <= IDLE;
                        valid <= 1'b1;
                    end
                end
                default : state <= IDLE;
            endcase
        end
    end

endmodule
