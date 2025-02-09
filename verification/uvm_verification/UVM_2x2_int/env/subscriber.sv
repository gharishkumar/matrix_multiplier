`ifndef SUBSCRIBER_
	`define SUBSCRIBER_

class subscriber extends uvm_subscriber #(seq_item);


	`uvm_component_utils_begin(subscriber)
	`uvm_component_utils_end

	
	

	function new(string name = "subscriber", uvm_component parent);
		super.new(name, parent);
	endfunction


	// build
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_type_name(), "Build phase of SUBSCRIBER", UVM_NONE)
	endfunction

	

`endif