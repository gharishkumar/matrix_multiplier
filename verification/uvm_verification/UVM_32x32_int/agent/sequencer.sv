`ifndef SEQUENCER_
	`define SEQUENCER_

class sequencer extends uvm_sequencer  #(seq_item);

    `uvm_component_utils_begin(sequencer)
    `uvm_component_utils_end

    function new(string name = "sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction

endclass

`endif