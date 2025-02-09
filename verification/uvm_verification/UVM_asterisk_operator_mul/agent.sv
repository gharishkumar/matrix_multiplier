class agent extends uvm_agent ;

  `uvm_component_utils(agent)

  mon mon1;
  driver drv1;
  sequencer seqr1;

  function new(string name = "agent", uvm_component parent=null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), " BUILD PHASE OF AGENT ", UVM_NONE)
    mon1 = mon ::type_id::create("mon1", this);
    drv1 = driver ::type_id::create("drv1", this);
    seqr1 = sequencer ::type_id::create("seqr1", this);
    drv1.print();
    seqr1.print();
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv1.seq_item_port.connect(seqr1.seq_item_export);
  endfunction

endclass