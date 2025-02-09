`ifndef MONITOR_
	`define MONITOR_

class monitor extends uvm_monitor;

	seq_item itm_h;

	uvm_analysis_port #(seq_item) mon_put_port;

	virtual intf vif;

	static int count = 0;

	`uvm_component_utils_begin(monitor)
	`uvm_component_utils_end

	// Constructor
	function new(string name = "monitor", uvm_component parent);
		super.new(name, parent);
		mon_put_port = new("mon_put_port", this);
	endfunction

	// build
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_type_name(), "Build phase of MONITOR", UVM_NONE)		
		if (uvm_config_db #(virtual intf) :: get (this,"","INTF_KEY",vif)) begin 
			`uvm_info(get_type_name(), "RECEIVED in MONITOR",UVM_NONE)
		end else begin 
			`uvm_fatal(get_type_name(), "NOT RECEIVED in MONITOR")
		end
	endfunction

	// run
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever begin 
			// #2;
			if (!vif.rst) begin 
				monitor_data();
			end else begin
				`uvm_info(get_type_name(), "Reset is driving one!", UVM_NONE)
				@(posedge vif.clk);
			end
		end
	endtask

	task monitor_data();
		itm_h=seq_item::type_id::create("itm_h");
			// #1000
		@(posedge vif.clk);
			count++;

			itm_h.load_in       = vif.load_in;

		    itm_h.a11           = vif.a11;
		    itm_h.a12           = vif.a12;
		    itm_h.a21           = vif.a21;
		    itm_h.a22           = vif.a22;
		    
		    itm_h.b11           = vif.b11;
		    itm_h.b12           = vif.b12;
		    itm_h.b21           = vif.b21;
		    itm_h.b22           = vif.b22;

		    itm_h.result_row00  = vif.result_row00;
		    itm_h.result_row01  = vif.result_row01;
		    itm_h.result_row10  = vif.result_row10;
		    itm_h.result_row11  = vif.result_row11;

		    itm_h.valid         = vif.valid;

			mon_put_port.write(itm_h);
			`uvm_info(get_type_name(), "PRINTING VALUES FROM MONITOR", UVM_NONE)
			itm_h.print();

		`uvm_info(get_type_name(), $sformatf("VIFF a11 : %0d , a12 : %0d , result_row00 : %0h",vif.a11 , vif.a12 , vif.result_row00), UVM_NONE)
		`uvm_info(get_type_name(), $sformatf("VIFF a21 : %0d , a22 : %0d , result_row01 : %0h",vif.a21 , vif.a22 , vif.result_row01), UVM_NONE)
		`uvm_info(get_type_name(), $sformatf("VIFF b11 : %0d , b12 : %0d , result_row10 : %0h",vif.b11 , vif.b12 , vif.result_row10), UVM_NONE)
		`uvm_info(get_type_name(), $sformatf("VIFF b21 : %0d , b22 : %0d , result_row11 : %0h",vif.b21 , vif.b22 , vif.result_row11), UVM_NONE)

		`uvm_info(get_type_name(), $sformatf("SEQQ load_in : %0d , a12 : %0d , result_row00 : %0h , result_row10 : %0h",itm_h.load_in , itm_h.a12 , itm_h.result_row00, itm_h.result_row10), UVM_NONE)
	endtask

	function void report_phase (uvm_phase phase);
		super.report_phase(phase);
		`uvm_info(get_type_name(), $sformatf("total number of Transactions from monitor : %0d",count), UVM_NONE)
	endfunction : report_phase

endclass

`endif