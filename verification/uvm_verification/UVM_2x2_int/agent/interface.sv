`ifndef INTF_
	`define INTF_

`timescale 1ns/1ps

interface intf ();

    logic        clk;
    logic        rst;
    bit          load_in;
    logic [1:0]  a11;
    logic [1:0]  a12;
    logic [1:0]  a21;
    logic [1:0]  a22;
    logic [1:0]  b11;
    logic [1:0]  b12;
    logic [1:0]  b21;
    logic [1:0]  b22;
    logic [19:0] result_out;
    logic        valid;


endinterface : intf

`endif