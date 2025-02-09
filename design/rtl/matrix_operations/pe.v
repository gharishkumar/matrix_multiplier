`timescale 1ns/1ps

module pe
( 
    input  wire        clk,            // Clock input
    input  wire        rst,            // Reset input
    input  wire        load_in,        // Load input signal
    input  wire [31:0] row_in,         // Row input data
    input  wire [31:0] col_in,         // Column input data
    output reg  [31:0] col_out,        // Column output data
    output reg  [31:0] row_out,        // Row output data
    output reg  [64:0] pe_result,      // PE result
    output reg         done_pe         // Done signal for PE
);

    wire [31:0] a;                    // Multiplicand a
    wire [31:0] b;                    // Multiplier b
    wire [63:0] result;               // Result of multiplication

    wire do_mul;                      // Multiplication control signal
    reg do_mul_reg;                   // Register for multiplication control signal
    
    vedic32x32 inst_vedic32x32(       // Instance of vedic32x32 multiplier
        .clk   (clk), 
        .reset (rst), 
        .a     (a), 
        .b     (b), 
        .start (do_mul), 
        .result(result), 
        .done  (done)
    );


    assign do_mul = do_mul_reg;       // Assign multiplication control signal to register

    reg [31:0] a_in_reg;              // Register for input a
    reg [31:0] b_in_reg;              // Register for input b

    assign a = a_in_reg;              // Assign input a to register
    assign b = b_in_reg;              // Assign input b to register

    always @(posedge clk) begin 
        if(rst) begin
            // Reset all registers and signals
            a_in_reg   <= 0;
            b_in_reg   <= 0;
            pe_result  <= 0;
            col_out    <= 0;
            row_out    <= 0;
            do_mul_reg <= 1'b0;
            done_pe    <= 1'b0;
        end else begin
            if (load_in) begin
                // Load inputs and initiate multiplication
                a_in_reg   <= row_in;
                b_in_reg   <= col_in;
                do_mul_reg <= 1'b1;
                done_pe    <= 1'b0;
            end else begin
                if(done) begin
                    // Update result and output signals when multiplication is done
                    pe_result  <= pe_result + result;
                    done_pe    <= 1'b1;
                    do_mul_reg <= 1'b0;
                    row_out    <= a_in_reg;
                    col_out    <= b_in_reg;
                end else begin
                    // Maintain current state
                    pe_result  <= pe_result;
                    done_pe    <= 1'b0;
                    do_mul_reg <= 1'b0;
                end
            end
        end
    end
    
endmodule
