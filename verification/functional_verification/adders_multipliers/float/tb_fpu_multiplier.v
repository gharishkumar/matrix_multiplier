`timescale 1ns / 1ps

module tb_fpu_multiplier;
    
    reg clk;
    reg rst;
    reg [31:0] input_a;
    reg input_a_stb;
    wire output_a_ack;
    reg [31:0] input_b;
    reg input_b_stb;
    wire output_b_ack;
    reg input_z_ack;
    wire [31:0] output_z;
    wire output_z_stb;
    
    // Instantiate the DUT (Device Under Test)
    fpu_multiplier uut (
        .clk(clk),
        .rst(rst),
        .input_a(input_a),
        .input_a_stb(input_a_stb),
        .output_a_ack(output_a_ack),
        .input_b(input_b),
        .input_b_stb(input_b_stb),
        .output_b_ack(output_b_ack),
        .output_z(output_z),
        .output_z_stb(output_z_stb),
        .input_z_ack(input_z_ack)
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
        input_z_ack = 0;
        
        // Reset pulse
        #10 rst = 0;
        
        // Test case 1: Multiplication of two normal floating-point numbers
        #10;
        input_a = 32'h3F800000; // 1.0 in IEEE 754
        input_b = 32'h40000000; // 2.0 in IEEE 754
        input_a_stb = 1;
        input_b_stb = 1;
        
        // Wait for acknowledgment
        // wait(output_a_ack && output_b_ack);
        #50
        input_a_stb = 0;
        input_b_stb = 0;
        
        // Wait for output
        // wait(output_z_stb);
        #50
        input_z_ack = 1;
        #10 input_z_ack = 0;
        
        // NEW TEST CASE
        #300;
        input_a = 32'h40400000 ; // 1.0 in IEEE 754
        input_b = 32'h40800000 ; // 2.0 in IEEE 754
        input_a_stb = 1;
        input_b_stb = 1;
        
        // Wait for acknowledgment
        // wait(output_a_ack && output_b_ack);
        #50
        input_a_stb = 0;
        input_b_stb = 0;
        
        // Wait for output
        // wait(output_z_stb);
        #50
        input_z_ack = 1;
        #10 input_z_ack = 0;
        
        // Test case 2: Multiplication of zero and a number
        #300;
        input_a = 32'h00000000; // 0.0 in IEEE 754
        input_b = 32'h3F800000; // 1.0 in IEEE 754
        input_a_stb = 1;
        input_b_stb = 1;
        
        // wait(output_a_ack && output_b_ack);
        #50
        input_a_stb = 0;
        input_b_stb = 0;
        
        // wait(output_z_stb);
        #50
        input_z_ack = 1;
        #10 input_z_ack = 0;
        
        // Test case 3: Multiplication involving infinity
        #300;
        input_a = 32'h7F800000; // +Infinity
        input_b = 32'h3F800000; // 1.0 in IEEE 754
        input_a_stb = 1;
        input_b_stb = 1;
        
        // wait(output_a_ack && output_b_ack);
        #50
        input_a_stb = 0;
        input_b_stb = 0;
        
        // wait(output_z_stb);
        #50
        input_z_ack = 1;
        #10 input_z_ack = 0;
        
        // Additional test cases can be added here
        
        #500;
        $finish;
    end
    
endmodule
