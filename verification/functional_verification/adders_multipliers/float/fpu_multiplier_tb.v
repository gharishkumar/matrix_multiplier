`timescale 1ns / 1ps

module fpu_multiplier_tb;

    // Inputs
    reg clk;
    reg rst;
    reg [31:0] input_a;
    reg input_a_stb;
    reg [31:0] input_b;
    reg input_b_stb;

    // Outputs
    wire [31:0] output_z;
    wire output_z_stb;

    // Instantiate the Unit Under Test (UUT)
    fpu_multiplier uut (
        .input_a(input_a),
        .input_b(input_b),
        .input_a_stb(input_a_stb),
        .input_b_stb(input_b_stb),
        .clk(clk),
        .rst(rst),
        .output_z(output_z),
        .output_z_stb(output_z_stb)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period clock
    end

    // Test sequence
    initial begin
        // Initialize inputs
        rst = 1;
        input_a = 0;
        input_b = 0;
        input_a_stb = 0;
        input_b_stb = 0;

        // Apply reset
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        rst = 0;

        // Test case 1: Multiply 2.0 and 3.0 (0x40000000 * 0x40400000)
        #5;
        input_a = 32'h40000000; // 2.0
        input_b = 32'h40400000; // 3.0
        input_a_stb = 1;
        input_b_stb = 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        input_a_stb = 0;
        input_b_stb = 0;

        // Wait for the result
        wait(output_z_stb == 1);
        $display("Test Case 1: 2.0 * 3.0 = %h (Expected: 40C00000)", output_z);

        // Test case 2: Multiply 1.0 and 1.0 (0x3F800000 * 0x3F800000)
        #5;
        input_a = 32'h3F800000; // 1.0
        input_b = 32'h3F800000; // 1.0
        input_a_stb = 1;
        input_b_stb = 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        input_a_stb = 0;
        input_b_stb = 0;

        // Wait for the result
        wait(output_z_stb == 1);
        $display("Test Case 2: 1.0 * 1.0 = %h (Expected: 3F800000)", output_z);

        // Test case 3: Multiply 0.5 and 0.5 (0x3F000000 * 0x3F000000)
        #5;
        input_a = 32'h3F000000; // 0.5
        input_b = 32'h3F000000; // 0.5
        input_a_stb = 1;
        input_b_stb = 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        input_a_stb = 0;
        input_b_stb = 0;

        // Wait for the result
        wait(output_z_stb == 1);
        $display("Test Case 3: 0.5 * 0.5 = %h (Expected: 3E800000)", output_z);

        // Test case 4: Multiply -2.0 and 4.0 (0xC0000000 * 0x40800000)
        #5;
        input_a = 32'hC0000000; // -2.0
        input_b = 32'h40800000; // 4.0
        input_a_stb = 1;
        input_b_stb = 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        input_a_stb = 0;
        input_b_stb = 0;

        // Wait for the result
        wait(output_z_stb == 1);
        $display("Test Case 4: -2.0 * 4.0 = %h (Expected: C50000)", output_z);

        // Test case 5: Multiply 0.0 and 5.0 (0x00000000 * 0x40A00000)
        #5;
        input_a = 32'h00000000; // 0.0
        input_b = 32'h40A00000; // 5.0
        input_a_stb = 1;
        input_b_stb = 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        input_a_stb = 0;
        input_b_stb = 0;

        // Wait for the result
        wait(output_z_stb == 1);
        $display("Test Case 5: 0.0 * 5.0 = %h (Expected: 00000000)", output_z);

        // End simulation
        #5;
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time: %0t | Output: %h | Output Strobe: %b", $time, output_z, output_z_stb);
    end

endmodule