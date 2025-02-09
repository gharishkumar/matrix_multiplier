`ifndef SEQ_ITEM_P
    `define SEQ_ITEM_P

class seq_item extends uvm_sequence_item;


         bit           load_in;
    rand logic [31:0]  a11;
    rand logic [31:0]  a12;
    rand logic [31:0]  a21;
    rand logic [31:0]  a22;
    rand logic [31:0]  b11;
    rand logic [31:0]  b12;
    rand logic [31:0]  b21;
    rand logic [31:0]  b22;
         logic [64:0]  result_row00;
         logic [64:0]  result_row01;
         logic [64:0]  result_row10;
         logic [64:0]  result_row11;
         logic         valid;

         constraint c1 {
             a11 inside {[0:20]};
             a12 inside {[0:20]};
             a21 inside {[0:20]};
             a22 inside {[0:20]};
             b11 inside {[0:20]};
             b12 inside {[0:20]};
             b21 inside {[0:20]};
             b22 inside {[0:20]};
         }

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
        `uvm_field_int(result_row00, UVM_ALL_ON)
        `uvm_field_int(result_row01, UVM_ALL_ON)
        `uvm_field_int(result_row10, UVM_ALL_ON)
        `uvm_field_int(result_row11, UVM_ALL_ON)
        `uvm_field_int(valid, UVM_ALL_ON)
    `uvm_object_utils_end

    // Constructor
    function new(string name = "seq_item");
        super.new(name);
        `uvm_info(get_type_name(), "SEQUENCE_ITEM_CALLED", UVM_NONE)
    endfunction

endclass

`endif