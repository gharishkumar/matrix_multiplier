`include "agent_pkg.sv"

package env_pkg;

	import uvm_pkg::*;
	import agent_pkg::*;

	typedef class env;
	typedef class scoreboard;
	// typedef class subscriber;

	`include "env.sv"
	// `include "subscriber.sv"
	`include "scoreboard.sv"

endpackage