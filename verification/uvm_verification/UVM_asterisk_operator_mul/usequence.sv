class usequence extends uvm_sequence #(usequence_item);

    usequence_item seq_item;

    `uvm_object_utils(usequence)


  function new(string name = "usequence");
    super.new(name);
    `uvm_info(get_type_name(), "SEQUENCE HAS BEEN CALLED", UVM_HIGH)
  endfunction

    task body();
    `uvm_info(get_type_name(), " SEQUENCE BODY TASK ", UVM_HIGH)
    repeat (5) begin
    seq_item = usequence_item :: type_id::create("seq_item");
    start_item(seq_item);
    void'(seq_item.randomize());
    finish_item(seq_item);
    get_response(seq_item);
    response_queue_depth = 100;
    end
    endtask

endclass