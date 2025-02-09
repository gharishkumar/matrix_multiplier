

class mon extends uvm_monitor ;

  virtual intf_dpu vif;
  usequence_item seq;
  uvm_analysis_port #(usequence_item) seq_aport_mon2ss;
  int count_seq;
  `uvm_component_utils(mon)

  function new(string name = "mon", uvm_component parent=null);
    super.new(name, parent);
    seq_aport_mon2ss = new("seq_aport_mon2ss", this);
    this.count_seq = 0;
    `uvm_info(get_type_name(), "ANALYSIS PORT CREATED IN MONITOR", UVM_HIGH)
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), " BUILD PHASE OF MONITOR ", UVM_HIGH)

    if (uvm_config_db#(virtual intf_dpu)::get(this, "", "INTF_KEY", vif)) begin
    `uvm_info(get_type_name(), "RECIEVED VIF", UVM_HIGH)
    end else begin
    `uvm_info(get_type_name(), " NOT RECIEVED VIF", UVM_HIGH)
    end

  endfunction


  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      seq = usequence_item::type_id::create("seq");
      @(posedge vif.clk);
      monitor_data();
  end

  endtask

 task monitor_data();
      @(posedge vif.clk);
      seq.mat1_11      = vif.mat1_11;
      seq.mat1_12      = vif.mat1_12;
      seq.mat1_21      = vif.mat1_21;
      seq.mat1_22      = vif.mat1_22;
      seq.mat2_11      = vif.mat2_11;
      seq.mat2_12      = vif.mat2_12;
      seq.mat2_21      = vif.mat2_21;
      seq.mat2_22      = vif.mat2_22;

      seq.out_11      = vif.out_11;
      seq.out_12      = vif.out_12;
      seq.out_21      = vif.out_21;
      seq.out_22      = vif.out_22;
      seq_aport_mon2ss.write(seq);
      count_seq++;
 endtask 

 virtual function void report_phase(uvm_phase phase);
   super.report_phase(phase);
   `uvm_info(get_type_name(), $sformatf("TRANSACTIONS SENT FROM MONITOR  :  %0d ", this.count_seq), UVM_NONE)
 endfunction : report_phase

endclass
