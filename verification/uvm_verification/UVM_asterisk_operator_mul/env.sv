class env extends uvm_env;

  `uvm_component_utils(env)

  agent agent1;
  sb sb1;

  function new(string name = "env", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), " BUILD PHASE OF ENVIRONMENT ", UVM_HIGH)
    agent1 = agent::type_id::create("agent1",this);
    sb1 = sb::type_id::create("sb1",this);
  endfunction

  function void connect_phase(uvm_phase phase);
  	super.connect_phase(phase);
  	agent1.mon1.seq_aport_mon2ss.connect(sb1.export_mon);
    agent1.drv1.rsp_port.connect(sb1.export_drv);
  endfunction

endclass