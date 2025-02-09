
class driver extends uvm_driver #(usequence_item);

  usequence_item seq;
  static int count_seq;

  virtual intf_dpu vif;

  `uvm_component_utils(driver)

  function new(string name = "driver", uvm_component parent=null);
    super.new(name, parent);
    this.count_seq = 0;
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), " BUILD PHASE OF DRIVER ", UVM_HIGH)
  
    if (uvm_config_db#(virtual intf_dpu)::get(this, "", "INTF_KEY", vif)) begin
    `uvm_info(get_type_name(), "RECIEVED VIF", UVM_HIGH)
    end else begin
    `uvm_info(get_type_name(), " NOT RECIEVED VIF", UVM_HIGH)
      
    end

  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      seq_item_port.get_next_item (seq);
      `uvm_info(get_type_name(), "DRIVER GOT DATA FROM SEQUNCER ", UVM_HIGH)
      @(posedge vif.clk);
      vif.mat1_11      <= seq.mat1_11;
      vif.mat1_12      <= seq.mat1_12;
      vif.mat1_21      <= seq.mat1_21;
      vif.mat1_22      <= seq.mat1_22;
      vif.mat2_11      <= seq.mat2_11;
      vif.mat2_12      <= seq.mat2_12;
      vif.mat2_21      <= seq.mat2_21;
      vif.mat2_22      <= seq.mat2_22;
      @(posedge vif.clk);
      seq.out_11      = vif.out_11;
      seq.out_12      = vif.out_12;
      seq.out_21      = vif.out_21;
      seq.out_22      = vif.out_22;
      seq_item_port.item_done(seq);
      seq_item_port.put_response(seq);
      rsp_port.write(seq);
      this.count_seq++;
    end

  endtask

   virtual function void report_phase(uvm_phase phase);
   super.report_phase(phase);
   `uvm_info(get_type_name(), $sformatf("TRANSACTIONS SENT FROM DRIVER  :  %0d ", this.count_seq), UVM_NONE)
   endfunction : report_phase


endclass
