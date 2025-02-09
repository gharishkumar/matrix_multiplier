`ifndef CONF_
  `define CONF_
class config_op extends uvm_sequence_item ;

    uvm_active_passive_enum ape_h;

    `uvm_object_utils_begin(config_op)
        `uvm_field_enum (uvm_active_passive_enum, ape_h , UVM_ALL_ON)
    `uvm_object_utils_end


    // Constructor
    function new(string name = "config_op");
        super.new(name);
        `uvm_info("", "config class", UVM_HIGH)
    endfunction

endclass
`endif