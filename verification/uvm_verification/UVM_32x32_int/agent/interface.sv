`ifndef INTF_
	`define INTF_

`timescale 1ns/1ps

interface intf ();

    logic         clk;
    logic         rst;
    bit           load_in;
    logic [31:0]  a11;
    logic [31:0]  a12;
    logic [31:0]  a21;
    logic [31:0]  a22;
    logic [31:0]  b11;
    logic [31:0]  b12;
    logic [31:0]  b21;
    logic [31:0]  b22;
    logic [64:0] result_row00;
    logic [64:0] result_row01;
    logic [64:0] result_row10;
    logic [64:0] result_row11;
    logic        valid;


endinterface : intf

`endif