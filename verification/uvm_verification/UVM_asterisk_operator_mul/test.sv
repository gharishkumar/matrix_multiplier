class test extends uvm_test;

	`uvm_component_utils_begin(test)
	`uvm_component_utils_end

	env env1;
	usequence seq1;

	function new(string name = "test", uvm_component parent=null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_type_name(), "BUILD PHASE OF TEST", UVM_HIGH)
		env1 = env::type_id::create("env1", this);
		seq1 = usequence :: type_id :: create("seq1",this);
	endfunction

	virtual function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);
		uvm_root::get().print_topology();
	endfunction : end_of_elaboration_phase

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		phase.raise_objection(this);
		seq1.start(env1.agent1.seqr1);
		phase.drop_objection(this);
	endtask

endclass : test