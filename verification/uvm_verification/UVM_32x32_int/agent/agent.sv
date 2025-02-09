`ifndef AGENT_
	`define AGENT_

class agent extends uvm_agent;

	sequencer seqr_h;
	driver    drv_h;
	monitor   mon_h;
	user_config conf_h;


	`uvm_component_utils_begin(agent)
	`uvm_component_utils_end


	// Constructor
	function new(string name = "agent", uvm_component parent);
		super.new(name, parent);
	endfunction


	// build
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_type_name(), "Build phase of AGENT", UVM_NONE)
		seqr_h=sequencer::type_id::create("seqr_h",this);
		drv_h=driver::type_id::create("drv_h",this);
		mon_h=monitor::type_id::create("mon_h",this);

		if (uvm_config_db #(user_config) :: get (this , "" , "CONFIG_KEY" , conf_h)) begin 
			`uvm_info("", "GET IS SUCESSFULL IN AGENT OF CONFIG", UVM_NONE)
		end else begin 
			`uvm_fatal("", "GET IS UN-SUCESSFULL IN AGENT OF CONFIG")
		end
	endfunction

	// connect
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		drv_h.seq_item_port.connect(seqr_h.seq_item_export);
		`uvm_info("", "CONNECTION drv to seq SUCCESSFULL", UVM_NONE)
	endfunction

endclass

`endif