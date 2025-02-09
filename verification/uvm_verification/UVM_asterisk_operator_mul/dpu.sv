`timescale 1ns / 1ps


module dpu (


	input logic clk,
	input logic rst,
	input logic [15:0] mat1_11,
	input logic [15:0] mat1_12,
	input logic [15:0] mat1_21,
	input logic [15:0] mat1_22,

	input logic [15:0] mat2_11,
	input logic [15:0] mat2_12,
	input logic [15:0] mat2_21,
	input logic [15:0] mat2_22,

	output logic [32:0] out_11,
	output logic [32:0] out_12,
	output logic [32:0] out_21,
	output logic [32:0] out_22
);

always_ff @(posedge clk or posedge rst) begin 
	if(rst) begin
		out_11 <= 0;
		out_12 <= 0;
		out_21 <= 0;
		out_22 <= 0;
	end else begin
		out_11 <= (mat1_11*mat1_11 + mat1_12*mat2_21);
		out_12 <= (mat1_21*mat2_11 + mat1_22*mat2_21);
		out_21 <= (mat1_11*mat2_12 + mat1_12*mat2_22);
		out_12 <= (mat1_21*mat2_12 + mat1_22*mat2_22);
	end
end

endmodule : dpu