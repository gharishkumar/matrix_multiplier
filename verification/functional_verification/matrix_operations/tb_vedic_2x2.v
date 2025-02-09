`timescale 1ns / 1ps

module tb_vedic_2x2();

    reg clk;
    reg arst_n;
    reg [1:0] s_a_tdata;  
    reg [1:0] s_b_tdata;
    reg s_a_tvalid;
    wire s_a_tready;

    reg s_b_tvalid;
    wire s_b_tready;

    wire [3:0] m_result_tdata;
    wire m_tvalid;
    reg m_tready;

    vedic_2x2_try_pipe  inst_vedic_2x2 (
        .clk            (clk),
        .arst_n         (arst_n),
        .s_a_tdata      (s_a_tdata),
        .s_b_tdata      (s_b_tdata),
        .s_a_tvalid     (s_a_tvalid),
        .s_a_tready     (s_a_tready),
        .s_b_tvalid     (s_b_tvalid),
        .s_b_tready     (s_b_tready),
        .m_result_tdata (m_result_tdata),
        .m_tvalid       (m_tvalid),
        .m_tready       (m_tready)
    );

    always #5 clk = ~clk;

   always #100 s_a_tdata = $random();
   always #100 s_b_tdata = $random();




    initial begin
        
        clk = 0;

        arst_n = 1;

        s_a_tdata = 0;
        s_b_tdata = 0;
        s_a_tvalid = 0;
        s_b_tvalid = 0;
        m_tready = 0;

        #20 arst_n = 0;

        #10 arst_n = 1;

        #100;
        s_a_tvalid = 1'b1;
        s_b_tvalid = 1'b1;
        m_tready = 1'b1;
        // s_a_tdata = 'd2;
        // s_b_tdata = 'd3;
        // #100;
        // s_a_tdata = 'd1;
        // s_b_tdata = 'd1;
        // #100;
        // s_a_tdata = 'd2;
        // s_b_tdata = 'd2;
        // #100;
        // s_a_tdata = 'd1;
        // s_b_tdata = 'd0;
        // #100;
        // s_a_tdata = 'd2;
        // s_b_tdata = 'd1;

        // s_a_tdata = $random;
        // s_b_tdata = $random;

        
        // wait ((s_a_tready & s_b_tready) == 1'b1);
        // s_a_tvalid = 0;
        // s_b_tvalid = 0;
        
        // wait(m_tvalid == 1'b1);
        // m_tready = 1'b0;


        //  #20;
        // s_a_tvalid = 1;
        // s_b_tvalid = 1;
        // m_tready = 1;
        // s_a_tdata = $random();
        // s_b_tdata = $random();

        
        // wait ((s_a_tready & s_b_tready) == 1'b1);
        // s_a_tvalid = 0;
        // s_b_tvalid = 0;
        
        // wait(m_tvalid == 1'b1);
        // m_tready = 1'b0;
        
        
        //  #20;
        // s_a_tvalid = 1;
        // s_b_tvalid = 1;
        // m_tready = 1;
        // s_a_tdata = $random();
        // s_b_tdata = $random();

        
        // wait ((s_a_tready & s_b_tready) == 1'b1);
        // s_a_tvalid = 0;
        // s_b_tvalid = 0;
        
        // wait(m_tvalid == 1'b1);
        // m_tready = 1'b0;
        #1000 $finish();
    end

endmodule