`include "uvm_macros.svh"
import uvm_pkg::*;

typedef class test;
typedef class env;

typedef class agent;
typedef class mon;
typedef class driver;

typedef class sequencer;
typedef class usequence;
typedef class usequence_item;

typedef class sb;


`include "intf_dpu.sv"
`include "dpu.sv"
`include "test.sv"
`include "env.sv"

`include "agent.sv"
`include "monitor.sv"
`include "driver.sv"

`include "sequencer.sv"
`include "usequence.sv"
`include "usequence_item.sv"

`include "scoreboard.sv"

module top_tb ();


	bit clk;
	bit rst;

	always #40ns clk = ~clk; 
	initial begin
		#10 rst = 1'b1;
		#10 rst = 1'b0;
	end

	intf_dpu vif ();

	assign vif.clk   = clk;
	assign vif.rst   = rst;
	
	dpu inst_dpu
		(
			.clk     (vif.clk),
			.rst     (vif.rst),
			.mat1_11 (vif.mat1_11),
			.mat1_12 (vif.mat1_12),
			.mat1_21 (vif.mat1_21),
			.mat1_22 (vif.mat1_22),
			.mat2_11 (vif.mat2_11),
			.mat2_12 (vif.mat2_12),
			.mat2_21 (vif.mat2_21),
			.mat2_22 (vif.mat2_22),
			.out_11  (vif.out_11),
			.out_12  (vif.out_12),
			.out_21  (vif.out_21),
			.out_22  (vif.out_22)
		);




	initial begin
		uvm_config_db #(virtual intf_dpu)::set(null, "uvm_test_top.env1.agent1.mon1", "INTF_KEY", vif);
		uvm_config_db #(virtual intf_dpu)::set(null, "uvm_test_top.env1.agent1.drv1", "INTF_KEY", vif);
		run_test("test");
	end

endmodule 