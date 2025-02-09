
package agent_pkg;

	import uvm_pkg::*;

	typedef class agent;
	typedef class user_config;
	typedef class driver;
	typedef class sequencer;
	typedef class monitor;
	typedef class seqence;
	typedef class seq_item;

	`include "agent.sv"
	`include "config.sv"
	`include "driver.sv"
	`include "sequencer.sv" 
	`include "monitor.sv"
	`include "sequence.sv" 
	`include "seq_item.sv"
endpackage