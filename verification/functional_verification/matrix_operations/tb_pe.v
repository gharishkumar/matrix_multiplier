`timescale 1ns / 1ps

module tb_pe();

    // Parameters
    parameter DATA_TYPE = 3'b011; // Example: int 8

    // Inputs
    reg clk;
    reg rst;
    reg [31:0] mat1;
    reg [31:0] mat2;

    // Outputs
    wire [31:0] outp_col;
    wire [31:0] outp_row;
    wire [64:0] pe_result;

    // Instantiate the PE module
    pe #(DATA_TYPE) uut (
        .clk(clk),
        .rst(rst),
        .mat1(mat1),
        .mat2(mat2),
        .outp_col(outp_col),
        .outp_row(outp_row),
        .pe_result(pe_result)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Test sequence
    initial begin
        // Initialize inputs
        rst = 1;
        mat1 = 0;
        mat2 = 0;

        // Apply reset
        #40;
        rst = 0;
        
        // Test case 1: Simple multiplication
        mat1 = 32'h00000002; // 2
        mat2 = 32'h00000003; // 3
        #200; // Wait for computation

        // Test case 2: Larger values
        mat1 = 32'h0000000A; // 10
        mat2 = 32'h0000000B; // 11
        #200; // Wait for computation

        // Test case 2: Larger values
        mat1 = 32'h00000007; // 10
        mat2 = 32'h00000008; // 11
        #200; // Wait for computation

        // Test case 2: Larger values
        mat1 = 32'h00000005; // 10
        mat2 = 32'h00000006; // 11
        #200; // Wait for computation

        // Test case 3: Edge case with zeros
        mat1 = 32'h00000000; // 0
        mat2 = 32'h0000000F; // 15
        #200; // Wait for computation

        // Test case 4: Edge case with maximum values
        mat1 = 32'hFFFFFFFF; // Maximum 32-bit value
        mat2 = 32'hFFFFFFFF; // Maximum 32-bit value
        #200; // Wait for computation

        // End simulation
        $display("Simulation complete.");
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time: %0t | mat1: %h | mat2: %h | outp_row: %h | outp_col: %h | pe_result: %h",
                 $time, mat1, mat2, outp_row, outp_col, pe_result);
    end

endmodule