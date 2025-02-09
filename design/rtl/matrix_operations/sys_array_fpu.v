`timescale 1ns/1ps

module sys_array_fpu (
    input wire         clk,                             // Clock signal
    input wire         rst,                             // Synchronous active high reset
    input wire         load_in,                         // Load input signal to load new inputs
    input wire  [31:0] row_in_row0,                     // 32-bit input for row 0 of Matrix A
    input wire  [31:0] row_in_row1,                     // 32-bit input for row 1 of Matrix A
    input wire  [31:0] col_in_col0,                     // 32-bit input for column 0 of Matrix B
    input wire  [31:0] col_in_col1,                     // 32-bit input for column 1 of Matrix B
    output wire [31:0] result_row00,                    // 32-bit output for row 0, column 0 of Matrix C
    output wire [31:0] result_row01,                    // 32-bit output for row 0, column 1 of Matrix C
    output wire [31:0] result_row10,                    // 32-bit output for row 1, column 0 of Matrix C
    output wire [31:0] result_row11,                    // 32-bit output for row 1, column 1 of Matrix C
    output reg         done,                            // Done signal for processing element
    output reg         valid_op                         // Valid operation signal
);

    // Internal wires for PE communication
    wire [31:0] pe00_row_out;
    wire [31:0] pe00_col_out;
    wire [31:0] pe01_row_out; 
    wire [31:0] pe01_col_out;
    wire [31:0] pe10_row_out; 
    wire [31:0] pe10_col_out;
    wire [31:0] pe11_row_out; 
    wire [31:0] pe11_col_out;

    wire [31:0] pe00_result; 
    wire [31:0] pe01_result; 
    wire [31:0] pe10_result; 
    wire [31:0] pe11_result;

    reg done00; 
    reg done01; 
    reg done10; 
    reg done11;

    wire all_done;

    // Instantiate PE for (0,0)
    pe_fpu pe00 (
        .clk      (clk),
        .rst      (rst),
        .load_in  (load_in),
        .row_in   (row_in_row0),
        .col_in   (col_in_col0),
        .row_out  (pe00_row_out),
        .col_out  (pe00_col_out),
        .pe_result(pe00_result),
        .done_pe  (pe00_done)
    );

    // Instantiate PE for (0,1)
    pe_fpu pe01 (
        .clk      (clk),
        .rst      (rst),
        .load_in  (load_in),
        .row_in   (pe00_row_out), // Pass row output from PE00
        .col_in   (col_in_col1),
        .row_out  (pe01_row_out),
        .col_out  (pe01_col_out),
        .pe_result(pe01_result),
        .done_pe  (pe01_done)
    );

    // Instantiate PE for (1,0)
    pe_fpu pe10 (
        .clk      (clk),
        .rst      (rst),
        .load_in  (load_in),
        .row_in   (row_in_row1),
        .col_in   (pe00_col_out), // Pass column output from PE00
        .row_out  (pe10_row_out),
        .col_out  (pe10_col_out),
        .pe_result(pe10_result),
        .done_pe  (pe10_done)
    );

    // Instantiate PE for (1,1)
    pe_fpu pe11 (
        .clk       (clk),
        .rst       (rst),
        .load_in   (load_in),
        .row_in    (pe10_row_out),
        .col_in    (pe01_col_out),
        .col_out   (pe11_col_out),
        .row_out   (pe11_row_out),
        .pe_result (pe11_result),
        .done_pe   (pe11_done)
    );

    // Assign final results
    assign result_row00 = pe00_result;
    assign result_row01 = pe01_result;
    assign result_row10 = pe10_result;
    assign result_row11 = pe11_result;

    // Assign done signal based on all_done
    assign all_done = done00 & done01 & done10 & done11;

    // Sequential block to set done signal
    always @(posedge clk) begin 
        if (rst) begin
            done <= 0;
        end else begin
            if (all_done & !done) begin
                done <= 1'b1;
            end else begin
                done <= 1'b0;
            end
        end
    end

    // Sequential blocks to set done signals for each PE
    always @(posedge clk) begin 
        if (rst) begin
            done00 <= 0;
        end else begin
            if (pe00_done) begin
                done00 <= 1'b1;
            end else if (done) begin
                done00 <= 1'b0;
            end else begin
                done00 <= done00;
            end
        end
    end

    always @(posedge clk) begin 
        if (rst) begin
            done01 <= 0;
        end else begin
            if (pe10_done) begin
                done01 <= 1'b1;
            end else if (done) begin
                done01 <= 1'b0;
            end else begin
                done01 <= done01;
            end
        end
    end

    always @(posedge clk) begin 
        if (rst) begin
            done10 <= 0;
        end else begin
            if (pe10_done) begin
                done10 <= 1'b1;
            end else if (done) begin
                done10 <= 1'b0;
            end else begin
                done10 <= done10;
            end
        end
    end

    always @(posedge clk) begin 
        if (rst) begin
            done11 <= 0;
        end else begin
            if (pe11_done) begin
                done11 <= 1'b1;
            end else if (done) begin
                done11 <= 1'b0;
            end else begin
                done11 <= done11;
            end
        end
    end

    // Sequential block to set valid_op signal
    reg [2:0] count;
    always @(posedge clk) begin 
        if (rst) begin
            count <= 0;
            valid_op <= 0;
        end else begin
            if (pe11_done) begin
                count <= count + 1;
                valid_op <= 0;
            end else if (count == 3'b100) begin
                valid_op <= 1'b1;
                count <= 3'b000;
            end else begin
                valid_op <= 0;
                count <= count;
            end
        end
    end

endmodule
