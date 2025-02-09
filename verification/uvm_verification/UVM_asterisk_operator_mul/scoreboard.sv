`uvm_analysis_imp_decl(_mon)
`uvm_analysis_imp_decl(_drv)

class sb extends uvm_scoreboard ;

  uvm_analysis_imp_mon #(usequence_item, sb) export_mon;
  uvm_analysis_imp_drv #(usequence_item, sb) export_drv;
  
  usequence_item seq_mon_q[$];
  usequence_item seq_drv_q[$];

  usequence_item seq_mon;
  usequence_item seq_drv;

  event monitor_trigger;
  event driver_trigger;

  static int seq_count;
  static int seq_count_drv;
  static int seq_count_mon;
  static int result_match;

  `uvm_component_utils(sb)

  function new(string name = "sb", uvm_component parent=null);
    super.new(name, parent);
    export_mon = new("export_mon", this);
    export_drv = new("export_drv", this);
    this.seq_count = 0;
    this.seq_count_drv = 0;
    this.seq_count_mon = 0;
    this.result_match = 0;
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), " BUILD PHASE OF SCOREBOARD ", UVM_HIGH)
  endfunction


  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      #1;
    wait(seq_mon_q.size() > 0);
      seq_mon = seq_mon_q.pop_front();
    wait(seq_drv_q.size() > 0);
      seq_drv = seq_drv_q.pop_front();
    if (seq_mon.out_11 == seq_drv.out_11 && seq_mon.out_12 == seq_drv.out_12 && seq_mon.out_21 == seq_drv.out_21 && seq_mon.out_22 == seq_drv.out_22) begin
        `uvm_info(get_type_name(), " RESULT MATCH", UVM_NONE)
        this.result_match++;
    end else  begin
        `uvm_info(get_type_name(), " RESULT NOT MATCH", UVM_NONE)
    end
    this.seq_count++;
end

endtask

  function void write_mon (usequence_item seq);
    `uvm_info(get_type_name(), "SCOREBOARD GOT THE SEQ FROM MONITOR", UVM_NONE)
    seq_mon_q.push_back(seq);
    this.seq_count_mon++;
    seq.print();
  endfunction

  function void write_drv (usequence_item seq);
    `uvm_info(get_type_name(), "SCOREBOARD GOT THE SEQ FROM DRIVER", UVM_NONE)
    seq_drv_q.push_back(seq);
    this.seq_count_drv++;
    seq.print();
  endfunction

   virtual function void report_phase(uvm_phase phase);
   super.report_phase(phase);
   `uvm_info(get_type_name(), $sformatf("TRANSACTIONS PROCESSED IN SCOREBOARD  :  %0d ", this.seq_count), UVM_NONE)
   `uvm_info(get_type_name(), $sformatf("TRANSACTIONS RECIEVED IN SCOREBOARD FROM DRIVER :  %0d ", this.seq_count_drv), UVM_NONE)
   `uvm_info(get_type_name(), $sformatf("TRANSACTIONS RECIEVED IN SCOREBOARD FROM MONITOR :  %0d ", this.seq_count_mon), UVM_NONE)
   `uvm_info(get_type_name(), $sformatf("TRANSACTIONS MATCHED IN SCOREBOARD :  %0d ", this.result_match), UVM_NONE)
 endfunction : report_phase

endclass