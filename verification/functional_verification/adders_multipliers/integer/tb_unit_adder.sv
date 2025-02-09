`timescale 1ns/1ps 


module tb_unit_adder #(parameter DATA_WIDTH = 4);

reg  				  clk;    
reg  		          rst_p;  
reg  [DATA_WIDTH-1:0] a_in;
reg  [DATA_WIDTH-1:0] b_in;
wire [DATA_WIDTH-1:0] sum_out;
wire				  carry_out;


unit_adder #(
		.DATA_WIDTH(DATA_WIDTH)
	) inst_unit_adder (
		.clk       (clk),
		.rst_p     (rst_p),
		.a_in      (a_in),
		.b_in      (b_in),
		.sum_out   (sum_out),
		.carry_out (carry_out)
	);


initial begin 
	clk = 1'b0;
	forever #5 clk = ~clk;
end

always #10 a_in = $random;
always #15 b_in = $random;

initial begin 
	a_in  =1'b0;
	b_in  =1'b0;
	rst_p =1'b1;
	#10 
	rst_p =1'b0;
	#100 
	rst_p =1'b1;
	#20
	$finish;
end

endmodule