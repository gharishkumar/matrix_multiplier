`ifndef SEQ_ITEM_P
    `define SEQ_ITEM_P

class seq_item extends uvm_sequence_item;


         bit           load_in;
    rand logic [1:0]  a11;
    rand logic [1:0]  a12;
    rand logic [1:0]  a21;
    rand logic [1:0]  a22;
    rand logic [1:0]  b11;
    rand logic [1:0]  b12;
    rand logic [1:0]  b21;
    rand logic [1:0]  b22;
         logic [19:0]  result_out;
         logic         valid;


    `uvm_object_utils_begin(seq_item)
        `uvm_field_int(a11, UVM_ALL_ON )
        `uvm_field_int(a12, UVM_ALL_ON)
        `uvm_field_int(a21, UVM_ALL_ON)
        `uvm_field_int(a22, UVM_ALL_ON)
        `uvm_field_int(b11, UVM_ALL_ON)
        `uvm_field_int(b12, UVM_ALL_ON)
        `uvm_field_int(b21, UVM_ALL_ON)
        `uvm_field_int(b22, UVM_ALL_ON)
        `uvm_field_int(load_in, UVM_ALL_ON)
        `uvm_field_int(result_out, UVM_ALL_ON)
        `uvm_field_int(valid, UVM_ALL_ON)
    `uvm_object_utils_end

    // Constructor
    function new(string name = "seq_item");
        super.new(name);
        `uvm_info(get_type_name(), "SEQUENCE_ITEM_CALLED", UVM_NONE)
    endfunction

endclass

`endif