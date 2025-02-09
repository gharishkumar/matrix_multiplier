`include "env_pkg.sv"

package test_pkg;

	import uvm_pkg::*;
	import env_pkg::*;
	import agent_pkg::*;

	typedef class integrated_test;

	`include "integrated_test.sv"

endpackage