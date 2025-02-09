`ifndef TEST_
	`define TEST_

class integrated_test extends uvm_test ;

	env env_h;
	seqence seq_h;

	`uvm_component_utils_begin(integrated_test)
	`uvm_component_utils_end

	// Constructor
	function new(string name = "integrated_test", uvm_component parent);
		super.new(name, parent);
	endfunction


	// build
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env_h =env::type_id::create("env_h",this);
	endfunction

	// end_of_elaboration
	virtual function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);
		uvm_root::get().print_topology();
	endfunction

	// run
	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		phase.raise_objection(this);
			seq_h = seqence::type_id::create("seq_h");
			seq_h.start(env_h.agent_h.seqr_h);
		phase.drop_objection(this);
		endtask

endclass

`endif
