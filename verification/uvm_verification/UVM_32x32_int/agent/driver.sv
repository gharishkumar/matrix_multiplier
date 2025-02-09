`ifndef DRIVER_
	`define DRIVER_

class driver extends uvm_driver #(seq_item);

	virtual intf vif;

	seq_item seq;
	
	`uvm_component_utils_begin(driver)
	`uvm_component_utils_end

	// Constructor
	function new(string name = "driver", uvm_component parent);
		super.new(name, parent);
	endfunction 

	// build
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_type_name(), "Build phase of DRIVER", UVM_NONE)
		if (uvm_config_db #(virtual intf) :: get (this,"","INTF_KEY",vif)) begin
			`uvm_info(get_type_name(), "RECEIVED in DRIVER",UVM_NONE)
		end else begin 
			`uvm_fatal(get_type_name(), "NOT RECEIVED in DRIVER")
		end
	endfunction

	// run
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever begin 
			// #1;
			if (!vif.rst) begin 
				seq_item_port.get_next_item(seq);
				`uvm_info(get_type_name(), "DATA PRINTING FROM DRIVER", UVM_NONE)
				drive_data(seq);

				seq_item_port.item_done(seq);
				`uvm_info(get_type_name(), "DATA passed to vif", UVM_NONE)
			end else begin 
				`uvm_info(get_type_name(), "Reset is LOW", UVM_NONE)
				@(posedge vif.clk);
			end
		end
	endtask

	task drive_data(seq_item  seq);
			
			@(posedge vif.clk);

		    vif.load_in      <= 1'b1;
		    vif.a11          <= seq.a11;
		    vif.a12          <= seq.a12;
		    vif.a21          <= seq.a21;
		    vif.a22          <= seq.a22;
		    
		    vif.b11          <= seq.b11;
		    vif.b12          <= seq.b12;
		    vif.b21          <= seq.b21;
		    vif.b22          <= seq.b22;
			
			@(posedge vif.clk);

		    vif.load_in      <= 1'b0;

		    // #1000
		    
		    
		    @(posedge vif.clk);

		    seq.result_row00  = vif.result_row00;
		    seq.result_row01  = vif.result_row01;
		    seq.result_row10  = vif.result_row10;
		    seq.result_row11  = vif.result_row11;

		    seq.valid         = vif.valid;

			seq_item_port.put_response(seq);

			rsp_port.write(seq);

			wait(vif.valid);

			`uvm_info(get_type_name(), "PRINTING VALUES FROM DRIVER", UVM_NONE)
			// seq.print();

		// `uvm_info(get_type_name(), $sformatf("load_in : %0d , a12 : %0d",vif.load_in , vif.a12), UVM_NONE)

	endtask : drive_data

endclass

`endif