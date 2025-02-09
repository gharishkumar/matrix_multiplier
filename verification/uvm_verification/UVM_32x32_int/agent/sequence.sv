class seqence extends uvm_sequence#(seq_item);

	seq_item itm_h;

	static int count = 0;

	`uvm_object_utils_begin(seqence)
	`uvm_object_utils_end

	function new(string name = "seqence");
		super.new(name);
	endfunction

	task body();
		repeat(5) begin //for matrix count
			itm_h=seq_item::type_id::create("itm_h");

			start_item(itm_h);

			void'(itm_h.randomize());
			`uvm_info("", "RANDOMIZED DATA", UVM_NONE)
			count ++;
			
			finish_item(itm_h);
			get_response(itm_h);
			`uvm_info(get_type_name(), "DATA UPDATED IN SEQUENCE", UVM_NONE)
			// itm_h.print();
		    response_queue_depth = 1001;
		end

	endtask

endclass