`timescale 1ns/1ps

module sys_array_bfloat_16 (
    input clk,                             // clk
    input rst,                             // synchronous active high reset
    input load_in,                         // load_in to load new inputs
    input [15:0] row_in_row0, row_in_row1, // Matrix A inputs (2 rows)
    input [15:0] col_in_col0, col_in_col1, // Matrix B inputs (2 columns)
    output [15:0] result_row00, result_row01, result_row10, result_row11,// Output matrix C (2 rows)
    output reg done,                       // to denote PE done
    output reg valid_op                    // valid 
);

    // Internal wires for PE communication
    wire [15:0] pe00_row_out;
    wire [15:0] pe00_col_out;
    wire [15:0] pe01_row_out, pe01_col_out;
    wire [15:0] pe10_row_out, pe10_col_out;
    wire [15:0] pe11_row_out, pe11_col_out;

    wire [15:0] pe00_result, pe01_result, pe10_result, pe11_result;

    reg done00, done01, done10, done11;

    wire all_done;

    // Instantiate PE for (0,0)
    pe_fpu_bfloat_16 pe00 (
        .clk(clk),
        .rst(rst),
        .load_in(load_in),
        .row_in(row_in_row0),
        .col_in(col_in_col0),
        .row_out(pe00_row_out),
        .col_out(pe00_col_out),
        .pe_result(pe00_result),
        .done_pe(pe00_done)
    );

    // Instantiate PE for (0,1)
    pe_fpu_bfloat_16 pe01 (
        .clk(clk),
        .rst(rst),
        .load_in(load_in),
        .row_in(pe00_row_out), // Pass row output from PE00
        .col_in(col_in_col1),
        .row_out(pe01_row_out),
        .col_out(pe01_col_out),
        .pe_result(pe01_result),
        .done_pe(pe01_done)
    );

    // Instantiate PE for (1,0)
    pe_fpu_bfloat_16 pe10 (
        .clk(clk),
        .rst(rst),
        .load_in(load_in),
        .row_in(row_in_row1),
        .col_in(pe00_col_out), // Pass column output from PE00
        .row_out(pe10_row_out),
        .col_out(pe10_col_out),
        .pe_result(pe10_result),
        .done_pe(pe10_done)
    );

    // Instantiate PE for (1,1)
        pe_fpu_bfloat_16 pe11 (
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

    // assign done = all_done;

    assign all_done = done00 & done01 & done10 & done11;

    // always @(posedge clk) begin 
    //     if(rst) begin
    //         done <= 0;
    //     end else begin
    //         if ((done00 == 1'b1) && (done01 == 1'b1) && (done10 == 1'b1) && (done11 == 1'b0)) begin
    //             done <= 1'b1;
    //         end else begin
    //             done <= 1'b0;
    //         end
    //     end
    // end

    always @(posedge clk) begin 
        if(rst) begin
            done <= 0;
        end else begin
            if (all_done) begin
                done <= 1'b1;
            end else begin
                done <= 1'b0;
            end
        end
    end

    always @(posedge clk) begin 
        if(rst) begin
            done00 <= 0;
        end else begin
            if (pe00_done) begin
                done00 <= 1'b1;
            end else if (done) begin
                done00 = 1'b0;
            end else begin
                done00 <= done00;
            end
        end
    end

       always @(posedge clk) begin 
        if(rst) begin
            done01 <= 0;
        end else begin
            if (pe10_done) begin
                done01 <= 1'b1;
            end else if (done) begin
                done01 = 1'b0;
            end else begin
                done01 <= done01;
            end
        end
    end


       always @(posedge clk) begin 
        if(rst) begin
            done10 <= 0;
        end else begin
            if (pe10_done) begin
                done10 <= 1'b1;
            end else if (done) begin
                done10 = 1'b0;
            end else begin
                done10 <= done10;
            end
        end
    end


       always @(posedge clk) begin 
        if(rst) begin
            done11 <= 0;
        end else begin
            if (pe11_done) begin
                done11 <= 1'b1;
            end else if (done) begin
                done11 = 1'b0;
            end else begin
                done11 <= done11;
            end
        end
    end

      reg [2:0] count;

    always @(posedge clk) begin 
        if(rst) begin
            count <= 0;
            valid_op  <= 0;
        end else begin
            if (pe11_done) begin
                count <= count + 1;
                valid_op  <= 0;
            end else if (count == 3'b100) begin
                valid_op  <= 1'b1;
                count <= 3'b000;
            end else begin
                valid_op  <= 0;
                count <= count;
            end
        end
    end

   

endmodule