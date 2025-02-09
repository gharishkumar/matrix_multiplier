interface intf_dpu ();

	
	logic 		 clk;
	logic 		 rst;

	logic [15:0] mat1_11;
	logic [15:0] mat1_12;
	logic [15:0] mat1_21;
	logic [15:0] mat1_22;
	logic [15:0] mat2_11;
	logic [15:0] mat2_12;
	logic [15:0] mat2_21;
	logic [15:0] mat2_22;
	
	logic [32:0] out_11;
	logic [32:0] out_12;
	logic [32:0] out_21;
	logic [32:0] out_22;


endinterface


