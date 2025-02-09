`ifndef SCOREBOARD_
	`define SCOREBOARD_
	`uvm_analysis_imp_decl(_A)
	`uvm_analysis_imp_decl(_B)

class scoreboard extends uvm_scoreboard;

	uvm_analysis_imp_A #(seq_item, scoreboard) score_imp_mon;
	uvm_analysis_imp_B #(seq_item, scoreboard) score_imp_driver;

	seq_item mon_data;
	seq_item drv_data;

	seq_item mon_to_sb[$];
	seq_item drv_to_sb[$];

	event drv_trigger, mon_trigger;
	static int count=0;

	`uvm_component_utils_begin(scoreboard)
	`uvm_component_utils_end

	// Constructor
	function new(string name = "scoreboard", uvm_component parent);
		super.new(name, parent);
		score_imp_mon    = new("score_imp_mon", this);
		score_imp_driver = new("score_imp_driver", this);
	endfunction

	// Build phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_type_name(), "Build phase of scoreboard", UVM_NONE)
	endfunction

	// Run phase
	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever begin
			#1;
			@(mon_trigger);
			@(drv_trigger);
				mon_data = mon_to_sb.pop_front();
				drv_data = drv_to_sb.pop_front();
						// if (col_1_mul(mon_data.a11,mon_data.b11,mon_data.a12,mon_data.b21) == drv_data.result_out[4:0]  ) begin
						if (mon_data.result_out == drv_data.result_out) begin
							`uvm_info(get_type_name(), "all results matched succesfully sooo Data matched ", UVM_NONE)
						end else begin 
							`uvm_error(get_type_name(), "col 1 DATA not mached ")
						end 

			count++;
		end
	endtask

	// virtual function int col_1_mul(bit [1:0] data1, bit [1:0] data2, bit [1:0] data3, bit [1:0] data4);
	// 	return ((data1*data2) + (data3*data4));
	// endfunction

	
	function void write_A(seq_item itm_h);
		mon_to_sb.push_back(itm_h);
		`uvm_info(get_type_name(), "Data received from Monitor", UVM_NONE)
		-> mon_trigger;
	endfunction

	
	function void write_B(seq_item itm_h);
		drv_to_sb.push_back(itm_h);
		`uvm_info(get_type_name(), "Data received from Driver", UVM_NONE)
		-> drv_trigger;
	endfunction

function void report_phase(uvm_phase phase);
	super.report_phase(phase);
	`uvm_info(get_type_name(),$sformatf("total number of Transactions from scoreboard : %0d",count), UVM_NONE)
endfunction : report_phase 


endclass

`endif
