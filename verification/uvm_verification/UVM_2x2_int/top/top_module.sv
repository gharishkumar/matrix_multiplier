`timescale 1ns/1ps

`include"uvm_macros.svh"
import uvm_pkg::*;

`include "test_pkg.sv"
import test_pkg::*;

`include "rtl.v"
`include "interface.sv"

module top_module;

	bit clk;
	bit rst;

	intf  vif();

	initial begin 
		clk = 0;
		forever #5 clk = ~clk;
	end

	initial begin 
		rst = 1'b1;
		#10 
		rst = 1'b0;
	end
	

	initial begin 

		uvm_config_db #(virtual intf) :: set (null , "uvm_test_top.env_h.agent_h.mon_h" , "INTF_KEY" , vif);
		uvm_config_db #(virtual intf) :: set (null , "uvm_test_top.env_h.agent_h.drv_h" , "INTF_KEY" , vif);

		run_test("integrated_test");
	end


	assign vif.clk = clk;
	assign vif.rst = rst;

		mat_wrapper inst_mat_wrapper 
		(
			.clk        (vif.clk),
			.rst        (vif.rst),
			.load_in    (vif.load_in),
			.a11        (vif.a11),
			.a12        (vif.a12),
			.a21        (vif.a21),
			.a22        (vif.a22),
			.b11        (vif.b11),
			.b12        (vif.b12),
			.b21        (vif.b21),
			.b22        (vif.b22),
			.result_out (vif.result_out),
			.valid      (vif.valid)
		);


endmodule