class usequence_item extends uvm_sequence_item ;


    rand logic [15:0] mat1_11;
    rand logic [15:0] mat1_12;
    rand logic [15:0] mat1_21;
    rand logic [15:0] mat1_22;
    rand logic [15:0] mat2_11;
    rand logic [15:0] mat2_12;
    rand logic [15:0] mat2_21;
    rand logic [15:0] mat2_22;
         logic [32:0] out_11;
         logic [32:0] out_12;
         logic [32:0] out_21;
         logic [32:0] out_22;
 
 

    `uvm_object_utils_begin(usequence_item)
    	`uvm_field_int(mat1_11,UVM_ALL_ON)
        `uvm_field_int(mat1_12,UVM_ALL_ON)
        `uvm_field_int(mat1_21,UVM_ALL_ON)
        `uvm_field_int(mat1_22,UVM_ALL_ON)
        `uvm_field_int(mat2_11,UVM_ALL_ON)
        `uvm_field_int(mat2_12,UVM_ALL_ON)
        `uvm_field_int(mat2_21,UVM_ALL_ON)
        `uvm_field_int(mat2_22,UVM_ALL_ON)
        `uvm_field_int(out_11,UVM_ALL_ON)
        `uvm_field_int(out_12,UVM_ALL_ON)
        `uvm_field_int(out_21,UVM_ALL_ON)
        `uvm_field_int(out_22,UVM_ALL_ON)
   `uvm_object_utils_end

  function new(string name = "usequence_item");
    super.new(name);
    `uvm_info(get_type_name(), "SEQUENCE_ITEM_CALLED", UVM_NONE)
  endfunction

endclass