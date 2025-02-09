`timescale 1ns / 1ps

module fpu_adder_tb;

  // Inputs
  reg [31:0] input_a;
  reg [31:0] input_b;
  reg input_a_stb;
  reg input_b_stb;
  reg clk;
  reg rst;

  // Outputs
  wire [31:0] output_z;
  wire output_z_stb;

  // Instantiate the Unit Under Test (UUT)
  fpu_adder uut (
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
  always #5 clk = ~clk;

  // Testbench logic
  initial begin
    // Initialize inputs
    clk = 0;
    rst = 1;
    input_a_stb = 0;
    input_b_stb = 0;
    input_a = 0;
    input_b = 0;

    // Apply reset
    #10;
    rst = 0;

    // Test case 1: Add 1.5 and 2.5
    // 1.5 in IEEE 754 single-precision format: 0x3FC00000
    // 2.5 in IEEE 754 single-precision format: 0x40200000
    #10;
    input_a = 32'h3FC00000; // 1.5
    input_b = 32'h40200000; // 2.5
    input_a_stb = 1;
    input_b_stb = 1;

    // Wait for the output to be ready
    #1000;
    if (output_z_stb) begin
      $display("Test case 1: 1.5 + 2.5 = %h (Expected: 0x40400000)", output_z);
    end else begin
      $display("Test case 1: Output not ready");
    end

    // Test case 2: Add -3.25 and 1.75
    // -3.25 in IEEE 754 single-precision format: 0xC0500000
    // 1.75 in IEEE 754 single-precision format: 0x3FE00000
    #10;
    input_a = 32'hC0500000; // -3.25
    input_b = 32'h3FE00000; // 1.75
    input_a_stb = 1;
    input_b_stb = 1;

    // Wait for the output to be ready
    #1000;
    if (output_z_stb) begin
      $display("Test case 2: -3.25 + 1.75 = %h (Expected: 0xBF800000)", output_z);
    end else begin
      $display("Test case 2: Output not ready");
    end

    // Test case 3: Add 0.0 and 5.0
    // 0.0 in IEEE 754 single-precision format: 0x00000000
    // 5.0 in IEEE 754 single-precision format: 0x40A00000
    #10;
    input_a = 32'h00000000; // 0.0
    input_b = 32'h40A00000; // 5.0
    input_a_stb = 1;
    input_b_stb = 1;

    // Wait for the output to be ready
    #1000;
    if (output_z_stb) begin
      $display("Test case 3: 0.0 + 5.0 = %h (Expected: 0x40A00000)", output_z);
    end else begin
      $display("Test case 3: Output not ready");
    end

    // Test case 4: Add 1.0 and -1.0
    // 1.0 in IEEE 754 single-precision format: 0x3F800000
    // -1.0 in IEEE 754 single-precision format: 0xBF800000
    #10;
    input_a = 32'h3F800000; // 1.0
    input_b = 32'hBF800000; // -1.0
    input_a_stb = 1;
    input_b_stb = 1;

    // Wait for the output to be ready
    #1000;
    if (output_z_stb) begin
      $display("Test case 4: 1.0 + (-1.0) = %h (Expected: 0x00000000)", output_z);
    end else begin
      $display("Test case 4: Output not ready");
    end

    // Test case 5: Add very small numbers (denormalized)
    // 1.0e-38 in IEEE 754 single-precision format: 0x00000001
    // 2.0e-38 in IEEE 754 single-precision format: 0x00000002
    #10;
    input_a = 32'h00000001; // 1.0e-38
    input_b = 32'h00000002; // 2.0e-38
    input_a_stb = 1;
    input_b_stb = 1;

    // Wait for the output to be ready
    #1000;
    if (output_z_stb) begin
      $display("Test case 5: 1.0e-38 + 2.0e-38 = %h (Expected: 0x00000003)", output_z);
    end else begin
      $display("Test case 5: Output not ready");
    end

    // Test case 6: Add numbers with different exponents
    // 1.0 in IEEE 754 single-precision format: 0x3F800000
    // 1.0e-10 in IEEE 754 single-precision format: 0x2E8BA2E9
    #10;
    input_a = 32'h3F800000; // 1.0
    input_b = 32'h2E8BA2E9; // 1.0e-10
    input_a_stb = 1;
    input_b_stb = 1;

    // Wait for the output to be ready
    #1000;
    if (output_z_stb) begin
      $display("Test case 6: 1.0 + 1.0e-10 = %h (Expected: 0x3F800000)", output_z);
    end else begin
      $display("Test case 6: Output not ready");
    end

    // Test case 7: Add infinity and a finite number
    // Infinity in IEEE 754 single-precision format: 0x7F800000
    // 5.0 in IEEE 754 single-precision format: 0x40A00000
    #10;
    input_a = 32'h7F800000; // Infinity
    input_b = 32'h40A00000; // 5.0
    input_a_stb = 1;
    input_b_stb = 1;

    // Wait for the output to be ready
    #1000;
    if (output_z_stb) begin
      $display("Test case 7: Infinity + 5.0 = %h (Expected: 0x7F800000)", output_z);
    end else begin
      $display("Test case 7: Output not ready");
    end

    // Test case 8: Add NaN and a finite number
    // NaN in IEEE 754 single-precision format: 0x7FC00000
    // 5.0 in IEEE 754 single-precision format: 0x40A00000
    #10;
    input_a = 32'h7FC00000; // NaN
    input_b = 32'h40A00000; // 5.0
    input_a_stb = 1;
    input_b_stb = 1;

    // Wait for the output to be ready
    #1000;
    if (output_z_stb) begin
      $display("Test case 8: NaN + 5.0 = %h (Expected: 0x7FC00000)", output_z);
    end else begin
      $display("Test case 8: Output not ready");
    end

    // End simulation
    #10;
    $finish;
  end

endmodule