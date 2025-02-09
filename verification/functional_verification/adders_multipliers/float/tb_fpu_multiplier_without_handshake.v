`timescale 1ns / 1ps

module tb_fpu_multiplier_without_handshake;
    
    reg clk;
    reg rst;
    reg [31:0] input_a;
    reg input_a_stb;
    reg [31:0] input_b;
    reg input_b_stb;
    wire [31:0] output_z;
    wire output_z_stb;

    fpu_multiplier_without_handshake
    inst_fpu_multiplier_without_handshake 
    (
        .input_a      (input_a),
        .input_b      (input_b),
        .input_a_stb  (input_a_stb),
        .input_b_stb  (input_b_stb),
        .clk          (clk),
        .rst          (rst),
        .output_z     (output_z),
        .output_z_stb (output_z_stb)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        // Initialize inputs
        clk = 0;
        rst = 1;
        input_a = 0;
        input_a_stb = 0;
        input_b = 0;
        input_b_stb = 0;
        
        // Reset pulse
        #10 rst = 0;
        
        // Test case 1: Multiplication of two normal floating-point numbers
        #10;
        input_a = 32'h3F800000;
        input_b = 32'h40000000;
        input_a_stb = 1;
        input_b_stb = 1;
        
        #50
        input_a_stb = 0;
        input_b_stb = 0;
        
        // Test case 2: Multiplication of two normal floating-point numbers
        #360;
        input_a = 32'h40400000 ;
        input_b = 32'h40800000 ;
        input_a_stb = 1;
        input_b_stb = 1;
        
        #60
        input_a_stb = 0;
        input_b_stb = 0;
        
        // Test case 3: Multiplication of two normal floating-point numbers
        #360;
        input_a = 32'h40490FDB;
        input_b = 32'hC0200000;
        input_a_stb = 1;
        input_b_stb = 1;
        
        #60
        input_a_stb = 0;
        input_b_stb = 0;
        
        // Test case 4: Multiplication of zero and a number
        #360;
        input_a = 32'h00000000;
        input_b = 32'h3F800000;
        input_a_stb = 1;
        input_b_stb = 1;
        
        #60
        input_a_stb = 0;
        input_b_stb = 0;
        
        // Test case 5: Multiplication involving infinity
        #360;
        input_a = 32'h7F800000; // +Infinity
        input_b = 32'h3F800000; // 1.0 in IEEE 754
        input_a_stb = 1;
        input_b_stb = 1;
        
        #60
        input_a_stb = 0;
        input_b_stb = 0;

        #5000;
        $finish;
    end
    
endmodule
