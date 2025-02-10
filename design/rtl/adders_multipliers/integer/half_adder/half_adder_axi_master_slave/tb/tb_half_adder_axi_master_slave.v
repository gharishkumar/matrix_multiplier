`timescale 1ns / 1ps

module tb_half_adder_axi_master_slave;

    // Inputs
    reg clk;
    reg reset;

    // Slave Interface (Input from Master)
    reg s_a_tvalid;
    reg s_a_tdata;
    wire s_a_tready;

    reg s_b_tvalid;
    reg s_b_tdata;
    wire s_b_tready;

    // Master Interface (Output to Slave)
    wire m_sum_tvalid;
    wire m_sum_tdata;
    reg m_sum_tready;

    wire m_carry_tvalid;
    wire m_carry_tdata;
    reg m_carry_tready;

    // Instantiate the Unit Under Test (UUT)
    half_adder_axi_master_slave uut (
        .clk(clk),
        .reset(reset),

        // Slave Interface
        .s_a_tvalid(s_a_tvalid),
        .s_a_tdata(s_a_tdata),
        .s_a_tready(s_a_tready),

        .s_b_tvalid(s_b_tvalid),
        .s_b_tdata(s_b_tdata),
        .s_b_tready(s_b_tready),

        // Master Interface
        .m_sum_tvalid(m_sum_tvalid),
        .m_sum_tdata(m_sum_tdata),
        .m_sum_tready(m_sum_tready),

        .m_carry_tvalid(m_carry_tvalid),
        .m_carry_tdata(m_carry_tdata),
        .m_carry_tready(m_carry_tready)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Toggle clock every 5 time units
    end

    // Testbench logic
    initial begin
        // Initialize inputs
        reset = 1;
        s_a_tvalid = 0;
        s_a_tdata = 0;
        s_b_tvalid = 0;
        s_b_tdata = 0;
        m_sum_tready = 0;
        m_carry_tready = 0;

        // Apply reset
        #20;
        reset = 0;

        // Test case 1: A = 0, B = 0
        #10;
        s_a_tvalid = 1;
        s_a_tdata = 0;
        s_b_tvalid = 1;
        s_b_tdata = 0;
        m_sum_tready = 1;
        m_carry_tready = 1;

        #20;
        s_a_tvalid = 0;
        s_b_tvalid = 0;

        // Wait for the result
        #20;
        if (m_sum_tdata !== 0 || m_carry_tdata !== 0) begin
            $display("Test case 1 failed: Expected Sum = 0, Carry = 0. Got Sum = %b, Carry = %b", m_sum_tdata, m_carry_tdata);
        end else begin
            $display("Test case 1 passed: Sum = 0, Carry = 0");
        end

        // Test case 2: A = 1, B = 0
        #10;
        s_a_tvalid = 1;
        s_a_tdata = 1;
        s_b_tvalid = 1;
        s_b_tdata = 0;
        m_sum_tready = 1;
        m_carry_tready = 1;

        #20;
        s_a_tvalid = 0;
        s_b_tvalid = 0;

        // Wait for the result
        #20;
        if (m_sum_tdata !== 1 || m_carry_tdata !== 0) begin
            $display("Test case 2 failed: Expected Sum = 1, Carry = 0. Got Sum = %b, Carry = %b", m_sum_tdata, m_carry_tdata);
        end else begin
            $display("Test case 2 passed: Sum = 1, Carry = 0");
        end

        // Test case 3: A = 0, B = 1
        #10;
        s_a_tvalid = 1;
        s_a_tdata = 0;
        s_b_tvalid = 1;
        s_b_tdata = 1;
        m_sum_tready = 1;
        m_carry_tready = 1;

        #20;
        s_a_tvalid = 0;
        s_b_tvalid = 0;

        // Wait for the result
        #20;
        if (m_sum_tdata !== 1 || m_carry_tdata !== 0) begin
            $display("Test case 3 failed: Expected Sum = 1, Carry = 0. Got Sum = %b, Carry = %b", m_sum_tdata, m_carry_tdata);
        end else begin
            $display("Test case 3 passed: Sum = 1, Carry = 0");
        end

        // Test case 4: A = 1, B = 1
        #10;
        s_a_tvalid = 1;
        s_a_tdata = 1;
        s_b_tvalid = 1;
        s_b_tdata = 1;
        m_sum_tready = 1;
        m_carry_tready = 1;

        #20;
        s_a_tvalid = 0;
        s_b_tvalid = 0;

        // Wait for the result
        #20;
        if (m_sum_tdata !== 0 || m_carry_tdata !== 1) begin
            $display("Test case 4 failed: Expected Sum = 0, Carry = 1. Got Sum = %b, Carry = %b", m_sum_tdata, m_carry_tdata);
        end else begin
            $display("Test case 4 passed: Sum = 0, Carry = 1");
        end

        // End simulation
        #20;
        $display("Simulation completed.");
        $finish;
    end

endmodule